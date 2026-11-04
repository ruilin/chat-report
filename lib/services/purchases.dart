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

/// 两种一次性商品：按份解锁专题分析、AI 教练提问次数包。
/// 没有后端，解锁状态和剩余次数只在本机。
///
/// 收款和交付之间可能被打断（杀进程、延迟付款），所以：
/// - 购买前把目标报告记到本地，到账时无论是否换过进程都能找到它；
/// - 先记账再消耗，消耗失败下次启动会重放，靠已交付列表防止重复发放；
/// - 目标报告已被删除时转成一次额度，钱不会白付。
class Purchases extends ChangeNotifier {
  static const productId = 'deep_report_unlock';
  static const questionPackId = 'coach_questions_20';
  static const questionPackSize = 20;

  /// 专题分析先全部免费，看效果后再决定。打开后才有付费墙
  static bool deepDivePaywallEnabled = false;

  /// 教练先不收费、不限次数，看效果后再决定。打开后才有次数限制和付费墙
  static bool coachPaywallEnabled = false;

  static bool isDeepDiveOpen(RelationshipReport report) =>
      !deepDivePaywallEnabled || report.deepDiveUnlocked;

  /// 每台设备可以免费问的次数，让用户先试过再决定买不买
  static const freeQuestions = 3;

  static const _products = {productId, questionPackId};
  static const _targetKey = 'unlock_target_report';
  static const _creditsKey = 'unlock_credits';
  static const _grantedKey = 'unlock_granted_purchases';
  static const _freeUsedKey = 'coach_free_used';
  static const _paidQuestionsKey = 'coach_paid_questions';
  static String _pendingAtKey(String id) => '${id}_pending_at';

  /// 延迟付款多久后不再阻止新的购买（到期未付的订单 Google 会自行取消）
  static const _pendingExpiry = Duration(days: 7);

  static Purchases instance = Purchases(PlayStoreGateway(), ReportStore());

  final StoreGateway _store;
  final ReportStore _reports;

  Purchases(this._store, this._reports);

  final _details = <String, ProductDetails>{};
  final _states = <String, PurchaseState>{};
  StreamSubscription<List<PurchaseDetails>>? _sub;
  Future<void> _queue = Future.value();
  bool _started = false;

  int credits = 0;
  int _freeUsed = 0;
  int _paidQuestions = 0;

  /// 最近一次到账解锁的报告，报告页据此刷新
  String? lastUnlockedId;

  PurchaseState stateOf(String id) => _states[id] ?? PurchaseState.idle;

  /// 专题分析的购买状态
  PurchaseState get state => stateOf(productId);

  /// 商店返回的本地化价格；取不到说明商店不可用或商品未上架
  String? priceOf(String id) => _details[id]?.price;
  String? get price => priceOf(productId);

  int get questionsLeft =>
      (freeQuestions - _freeUsed).clamp(0, freeQuestions) + _paidQuestions;

  /// 启动时调用：接上购买事件，并补发上次没走完的订单
  Future<void> start() async {
    if (_started) return;
    _started = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      _loadBalances(prefs);
      for (final id in _products) {
        if (_pendingFresh(prefs, id)) _states[id] = PurchaseState.pending;
      }
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
    _paidQuestions = prefs.getInt(_paidQuestionsKey) ?? 0;
  }

  /// 教练页打开时读一次，不依赖 [start] 是否跑完
  Future<void> loadBalances() async {
    final prefs = await SharedPreferences.getInstance();
    _loadBalances(prefs);
    notifyListeners();
  }

  Future<void> loadProduct([String id = productId]) async {
    if (_details.containsKey(id)) return;
    try {
      final details = await _store.product(id);
      if (details != null) _details[id] = details;
      notifyListeners();
    } catch (e) {
      // ignore: avoid_print
      print('[iap] product query failed: $e');
    }
  }

  Future<void> buy(String reportId) => _buy(productId,
      beforeBuy: (prefs) => prefs.setString(_targetKey, reportId));

  Future<void> buyQuestions() => _buy(questionPackId);

  Future<void> _buy(String id,
      {Future<void> Function(SharedPreferences)? beforeBuy}) async {
    if (stateOf(id) == PurchaseState.buying) return;
    final prefs = await SharedPreferences.getInstance();
    if (_pendingFresh(prefs, id)) {
      // 还有一笔在等付款，再买会被商店拒绝，而且到账时分不清归属
      _set(id, PurchaseState.pending);
      return;
    }
    await loadProduct(id);
    final details = _details[id];
    if (details == null) {
      _set(id, PurchaseState.failed);
      return;
    }
    Analytics.purchaseStart(id);
    await beforeBuy?.call(prefs);
    _set(id, PurchaseState.buying);
    try {
      if (!await _store.buy(details)) _set(id, PurchaseState.failed);
    } catch (e) {
      // ignore: avoid_print
      print('[iap] buy failed: $e');
      Analytics.purchaseResult('error', id);
      _set(id, PurchaseState.failed);
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

  /// 扣一次提问：先用免费的。回答成功后才调用，失败不扣
  Future<void> spendQuestion() async {
    final prefs = await SharedPreferences.getInstance();
    if (_freeUsed < freeQuestions) {
      _freeUsed++;
      await prefs.setInt(_freeUsedKey, _freeUsed);
    } else if (_paidQuestions > 0) {
      _paidQuestions--;
      await prefs.setInt(_paidQuestionsKey, _paidQuestions);
    }
    notifyListeners();
  }

  Future<void> _handleAll(List<PurchaseDetails> list) async {
    for (final d in list) {
      if (!_products.contains(d.productID)) continue;
      try {
        await _handle(d);
      } catch (e) {
        // ignore: avoid_print
        print('[iap] handle failed: $e');
      }
    }
  }

  Future<void> _handle(PurchaseDetails d) async {
    final id = d.productID;
    final prefs = await SharedPreferences.getInstance();
    switch (d.status) {
      case PurchaseStatus.pending:
        await prefs.setInt(
            _pendingAtKey(id), DateTime.now().millisecondsSinceEpoch);
        Analytics.purchaseResult('pending', id);
        _set(id, PurchaseState.pending);
      case PurchaseStatus.canceled:
        await _clearInFlight(prefs, id);
        Analytics.purchaseResult('canceled', id);
        _set(id, PurchaseState.idle);
      case PurchaseStatus.error:
        Analytics.purchaseResult('error', id);
        if (d.error?.message.contains('AlreadyOwned') ?? false) {
          // 之前付过款但没消耗掉：让商店重放，走正常交付
          await _store.restore();
          return;
        }
        await _clearInFlight(prefs, id);
        _set(id, PurchaseState.failed);
      case PurchaseStatus.purchased:
      case PurchaseStatus.restored:
        await _grant(d, prefs);
    }
  }

  Future<void> _grant(PurchaseDetails d, SharedPreferences prefs) async {
    final id = d.productID;
    final key = d.purchaseID ?? d.verificationData.serverVerificationData;
    final granted = prefs.getStringList(_grantedKey) ?? <String>[];
    if (!granted.contains(key)) {
      final result = id == questionPackId
          ? await _grantQuestions(prefs)
          : await _grantUnlock(prefs);
      await prefs.setStringList(_grantedKey, [...granted, key]);
      await _clearInFlight(prefs, id);
      Analytics.purchaseResult(result, id);
    }
    _set(id, PurchaseState.idle);
    try {
      await _store.finish(d);
    } catch (e) {
      // 下次启动 restore 会重放，已交付列表保证不会重复发放
      // ignore: avoid_print
      print('[iap] finish failed: $e');
    }
  }

  Future<String> _grantQuestions(SharedPreferences prefs) async {
    _paidQuestions = (prefs.getInt(_paidQuestionsKey) ?? 0) + questionPackSize;
    await prefs.setInt(_paidQuestionsKey, _paidQuestions);
    return 'purchased';
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

  Future<void> _clearInFlight(SharedPreferences prefs, String id) async {
    if (id == productId) await prefs.remove(_targetKey);
    await prefs.remove(_pendingAtKey(id));
  }

  bool _pendingFresh(SharedPreferences prefs, String id) {
    final at = prefs.getInt(_pendingAtKey(id));
    if (at == null) return false;
    final age = DateTime.now()
        .difference(DateTime.fromMillisecondsSinceEpoch(at));
    return age < _pendingExpiry;
  }

  void _set(String id, PurchaseState s) {
    _states[id] = s;
    notifyListeners();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
