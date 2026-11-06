import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/report.dart';
import 'analytics.dart';
import 'report_store.dart';

/// 商店操作的最小接口，测试时替换成假的
abstract class StoreGateway {
  Stream<List<PurchaseDetails>> get purchases;
  Future<ProductDetails?> product(String id);
  Future<bool> buy(ProductDetails product);
  Future<void> restore();

  /// 交付完成后通知商店；Android 上同时消耗掉，之后才能再买
  Future<void> finish(PurchaseDetails details);
}

class PlayStoreGateway implements StoreGateway {
  InAppPurchase get _iap => InAppPurchase.instance;

  @override
  Stream<List<PurchaseDetails>> get purchases => _iap.purchaseStream;

  @override
  Future<ProductDetails?> product(String id) async {
    if (!await _iap.isAvailable()) return null;
    final resp = await _iap.queryProductDetails({id});
    return resp.productDetails.isEmpty ? null : resp.productDetails.first;
  }

  @override
  Future<bool> buy(ProductDetails product) => _iap.buyConsumable(
      purchaseParam: PurchaseParam(productDetails: product),
      // 自动消耗发生在交付之前，崩溃就会收了钱没给东西，所以交付后手动消耗
      autoConsume: false);

  @override
  Future<void> restore() => _iap.restorePurchases();

  @override
  Future<void> finish(PurchaseDetails details) async {
    if (Platform.isAndroid) {
      await _iap
          .getPlatformAddition<InAppPurchaseAndroidPlatformAddition>()
          .consumePurchase(details);
    }
    if (details.pendingCompletePurchase) {
      await _iap.completePurchase(details);
    }
  }
}

enum PurchaseState { idle, buying, pending, failed }

/// 唯一的一次性商品：按份解锁报告的专题分析、AI 教练和给你的建议。
/// 没有后端，解锁状态和免费提问次数只在本机。
///
/// 收款和交付之间可能被打断（杀进程、延迟付款），所以：
/// - 购买前把目标报告记到本地，到账时无论是否换过进程都能找到它；
/// - 先记账再消耗，消耗失败下次启动会重放，靠已交付列表防止重复发放；
/// - 目标报告已被删除时转成一次额度，钱不会白付。
class Purchases extends ChangeNotifier {
  static const productId = 'deep_report_unlock';

  /// 发布包收费，调试包免费，方便开发时直接看付费内容。
  /// 打开后才有付费墙和提问次数限制
  static bool paywallEnabled = kReleaseMode;

  /// 这份报告的付费内容能不能看。到账时写盘的是另一个对象，
  /// 这里同步到内存，否则之后保存这份报告会把解锁状态写回去
  static bool isUnlocked(RelationshipReport report) {
    if (instance.lastUnlockedId == report.id) report.deepDiveUnlocked = true;
    return !paywallEnabled || report.deepDiveUnlocked;
  }

  /// 每台设备可以免费问的次数，让用户先试过再决定买不买
  static const freeQuestions = 3;

  static const _targetKey = 'unlock_target_report';
  static const _creditsKey = 'unlock_credits';
  static const _grantedKey = 'unlock_granted_purchases';
  static const _freeUsedKey = 'coach_free_used';
  static const _pendingAtKey = '${productId}_pending_at';

  /// 延迟付款多久后不再阻止新的购买（到期未付的订单 Google 会自行取消）
  static const _pendingExpiry = Duration(days: 7);

  static Purchases instance = Purchases(PlayStoreGateway(), ReportStore());

  final StoreGateway _store;
  final ReportStore _reports;

  Purchases(this._store, this._reports);

  ProductDetails? _details;
  PurchaseState state = PurchaseState.idle;
  StreamSubscription<List<PurchaseDetails>>? _sub;
  Future<void> _queue = Future.value();
  bool _started = false;

  int credits = 0;
  int _freeUsed = 0;

  /// 最近一次到账解锁的报告，报告页据此刷新
  String? lastUnlockedId;

  /// 商店返回的本地化价格；取不到说明商店不可用或商品未上架
  String? get price => _details?.price;

  int get freeQuestionsLeft =>
      (freeQuestions - _freeUsed).clamp(0, freeQuestions);

  /// 启动时调用：接上购买事件，并补发上次没走完的订单
  Future<void> start() async {
    if (_started) return;
    _started = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      _loadBalances(prefs);
      if (_pendingFresh(prefs)) state = PurchaseState.pending;
      _sub = _store.purchases.listen(
        (list) => _queue = _queue.then((_) => _handleAll(list)),
        onError: (Object e) {
          // ignore: avoid_print
          print('[iap] stream error: $e');
        },
      );
      await _store.restore();
    } catch (e) {
      // ignore: avoid_print
      print('[iap] start failed: $e');
    }
    notifyListeners();
  }

  void _loadBalances(SharedPreferences prefs) {
    credits = prefs.getInt(_creditsKey) ?? 0;
    _freeUsed = prefs.getInt(_freeUsedKey) ?? 0;
  }

  /// 教练页打开时读一次，不依赖 [start] 是否跑完
  Future<void> loadBalances() async {
    final prefs = await SharedPreferences.getInstance();
    _loadBalances(prefs);
    notifyListeners();
  }

  Future<void> loadProduct() async {
    if (_details != null) return;
    try {
      _details = await _store.product(productId);
      notifyListeners();
    } catch (e) {
      // ignore: avoid_print
      print('[iap] product query failed: $e');
    }
  }

  Future<void> buy(String reportId) async {
    if (state == PurchaseState.buying) return;
    final prefs = await SharedPreferences.getInstance();
    if (_pendingFresh(prefs)) {
      // 还有一笔在等付款，再买会被商店拒绝，而且到账时分不清归属
      _set(PurchaseState.pending);
      return;
    }
    await loadProduct();
    final details = _details;
    if (details == null) {
      _set(PurchaseState.failed);
      return;
    }
    Analytics.purchaseStart(productId);
    await prefs.setString(_targetKey, reportId);
    _set(PurchaseState.buying);
    try {
      if (!await _store.buy(details)) _set(PurchaseState.failed);
    } catch (e) {
      // ignore: avoid_print
      print('[iap] buy failed: $e');
      Analytics.purchaseResult('error', productId);
      _set(PurchaseState.failed);
    }
  }

  /// 用额度解锁。报告存盘失败时仍在内存里解锁，这次能看到
  Future<void> useCredit(RelationshipReport report) async {
    if (credits <= 0) return;
    final prefs = await SharedPreferences.getInstance();
    credits--;
    await prefs.setInt(_creditsKey, credits);
    report.deepDiveUnlocked = true;
    lastUnlockedId = report.id;
    Analytics.purchaseResult('credit_used', productId);
    try {
      await _reports.save(report);
    } catch (e) {
      // ignore: avoid_print
      print('[iap] save after credit failed: $e');
    }
    notifyListeners();
  }

  /// 没解锁的报告每问一次扣一次免费额度。回答成功后才调用，失败不扣
  Future<void> spendFreeQuestion() async {
    final prefs = await SharedPreferences.getInstance();
    if (_freeUsed < freeQuestions) {
      _freeUsed++;
      await prefs.setInt(_freeUsedKey, _freeUsed);
    }
    notifyListeners();
  }

  Future<void> _handleAll(List<PurchaseDetails> list) async {
    for (final d in list) {
      if (d.productID != productId) continue;
      try {
        await _handle(d);
      } catch (e) {
        // ignore: avoid_print
        print('[iap] handle failed: $e');
      }
    }
  }

  Future<void> _handle(PurchaseDetails d) async {
    final prefs = await SharedPreferences.getInstance();
    switch (d.status) {
      case PurchaseStatus.pending:
        await prefs.setInt(
            _pendingAtKey, DateTime.now().millisecondsSinceEpoch);
        Analytics.purchaseResult('pending', productId);
        _set(PurchaseState.pending);
      case PurchaseStatus.canceled:
        await _clearInFlight(prefs);
        Analytics.purchaseResult('canceled', productId);
        _set(PurchaseState.idle);
      case PurchaseStatus.error:
        Analytics.purchaseResult('error', productId);
        if (d.error?.message.contains('AlreadyOwned') ?? false) {
          // 之前付过款但没消耗掉：让商店重放，走正常交付
          await _store.restore();
          return;
        }
        await _clearInFlight(prefs);
        _set(PurchaseState.failed);
      case PurchaseStatus.purchased:
      case PurchaseStatus.restored:
        await _grant(d, prefs);
    }
  }

  Future<void> _grant(PurchaseDetails d, SharedPreferences prefs) async {
    final key = d.purchaseID ?? d.verificationData.serverVerificationData;
    final granted = prefs.getStringList(_grantedKey) ?? <String>[];
    if (!granted.contains(key)) {
      final result = await _grantUnlock(prefs);
      await prefs.setStringList(_grantedKey, [...granted, key]);
      await _clearInFlight(prefs);
      Analytics.purchaseResult(result, productId);
    }
    _set(PurchaseState.idle);
    try {
      await _store.finish(d);
    } catch (e) {
      // 下次启动 restore 会重放，已交付列表保证不会重复发放
      // ignore: avoid_print
      print('[iap] finish failed: $e');
    }
  }

  Future<String> _grantUnlock(SharedPreferences prefs) async {
    final target = prefs.getString(_targetKey);
    var unlocked = false;
    if (target != null) {
      try {
        unlocked = await _reports.markUnlocked(target);
      } catch (e) {
        // ignore: avoid_print
        print('[iap] mark unlocked failed: $e');
      }
    }
    if (unlocked) {
      lastUnlockedId = target;
      return 'purchased';
    }
    credits++;
    await prefs.setInt(_creditsKey, credits);
    return 'credited';
  }

  Future<void> _clearInFlight(SharedPreferences prefs) async {
    await prefs.remove(_targetKey);
    await prefs.remove(_pendingAtKey);
  }

  bool _pendingFresh(SharedPreferences prefs) {
    final at = prefs.getInt(_pendingAtKey);
    if (at == null) return false;
    final age = DateTime.now()
        .difference(DateTime.fromMillisecondsSinceEpoch(at));
    return age < _pendingExpiry;
  }

  void _set(PurchaseState s) {
    state = s;
    notifyListeners();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
