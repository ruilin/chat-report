import 'package:flutter/material.dart';

/// 设计规范落地（见 UI 设计稿 §01 设计语言）。
/// 双人配色不可互换：你 = rose，对方 = blue，头像/条形/图例全局一致。
abstract final class UColors {
  static const paper = Color(0xFFFBF7F4);
  static const screen = Color(0xFFFDFAF8);
  static const ink = Color(0xFF2B1E2E);
  static const ink2 = Color(0xFF5C4B62);
  static const muted = Color(0xFF8A7A8E);
  static const faint = Color(0xFFB49FB8);
  static const line = Color(0xFFEFE6EA);
  static const card = Colors.white;
  static const rose = Color(0xFFE0526E); // You / 品牌
  static const roseSoft = Color(0xFFFFF6F7);
  static const roseBorder = Color(0xFFF4D7DD);
  static const blue = Color(0xFF3D8FBF); // 对方
  static const blueSoft = Color(0xFFEFF6FA);
  static const gold = Color(0xFFC99A3C); // 付费/高光
  static const grid = Color(0xFFF1E7EB);
}

abstract final class UType {
  /// 品牌/情绪标题：衬线斜体（iOS 有 Palatino/Georgia，Android 回退 serif）
  static const serifItalic = TextStyle(
    fontFamily: 'Palatino',
    fontFamilyFallback: ['Georgia', 'serif'],
    fontStyle: FontStyle.italic,
    color: UColors.ink,
  );

  static TextStyle label = const TextStyle(
    fontSize: 10,
    letterSpacing: 1.6,
    fontWeight: FontWeight.w700,
    color: UColors.faint,
  );

  static const num = TextStyle(
    fontFeatures: [FontFeature.tabularFigures()],
    fontWeight: FontWeight.w800,
    color: UColors.ink,
  );
}

ThemeData buildTheme() {
  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: UColors.screen,
    colorScheme: ColorScheme.fromSeed(
      seedColor: UColors.rose,
      primary: UColors.rose,
      surface: UColors.screen,
    ),
    fontFamily: null, // 系统字体
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: UColors.ink, fontSize: 14, height: 1.5),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: UColors.screen,
      foregroundColor: UColors.ink,
      elevation: 0,
      centerTitle: false,
    ),
  );
}

/// 报告/首页通用卡片
class UCard extends StatelessWidget {
  final Widget child;
  final Color? color;
  final Color? borderColor;
  final EdgeInsets padding;
  const UCard({
    super.key,
    required this.child,
    this.color,
    this.borderColor,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? UColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor ?? UColors.line),
        boxShadow: [
          BoxShadow(
            color: UColors.ink.withValues(alpha: .05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

/// 模块小标（全大写 + 字距）
class ULabel extends StatelessWidget {
  final String text;
  final Color? color;
  const ULabel(this.text, {super.key, this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text.toUpperCase(),
          style: UType.label.copyWith(color: color ?? UType.label.color)),
    );
  }
}

/// 双人头像（色彩绑定身份）
class UAvatar extends StatelessWidget {
  final String name;
  final bool isYou;
  final double size;
  const UAvatar(this.name, {super.key, required this.isYou, this.size = 34});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isYou ? UColors.rose : UColors.blue,
        shape: BoxShape.circle,
      ),
      child: Text(
        name.isEmpty ? '?' : name.characters.first.toUpperCase(),
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: size * .4,
        ),
      ),
    );
  }
}

/// 隐私承诺行 —— 首页/确认/分析页复用，措辞各自不同
class PrivacyNote extends StatelessWidget {
  final String text;
  const PrivacyNote(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('🔒', style: TextStyle(fontSize: 12)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text,
              style: const TextStyle(fontSize: 11, color: UColors.muted)),
        ),
      ],
    );
  }
}
