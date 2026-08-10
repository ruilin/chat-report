import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/report.dart';
import '../theme.dart';

/// 双人分段条：中间 2px 缝、端头 4px 圆角、百分比段内直标（图表纪律见设计稿 §04）。
class SplitBar extends StatelessWidget {
  final double leftShare; // 0–1，左段 = You（rose）
  const SplitBar({super.key, required this.leftShare});

  @override
  Widget build(BuildContext context) {
    final left = (leftShare * 100).round();
    final right = 100 - left;
    return SizedBox(
      height: 16,
      child: Row(
        children: [
          Expanded(
            flex: left.clamp(1, 99),
            child: _segment(UColors.rose, '$left%', Alignment.centerLeft),
          ),
          const SizedBox(width: 2),
          Expanded(
            flex: right.clamp(1, 99),
            child: _segment(UColors.blue, '$right%', Alignment.centerRight),
          ),
        ],
      ),
    );
  }

  Widget _segment(Color color, String label, Alignment align) {
    return Container(
      alignment: align,
      padding: const EdgeInsets.symmetric(horizontal: 7),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 9,
            fontWeight: FontWeight.w700,
            fontFeatures: [FontFeature.tabularFigures()],
          )),
    );
  }
}

/// 月度情绪曲线：2px 折线 + 8% 面积填充 + 浅网格，只标注峰/谷两点。
class EmotionCurve extends StatelessWidget {
  final List<MonthMood> points;
  const EmotionCurve({super.key, required this.points});

  @override
  Widget build(BuildContext context) {
    if (points.length < 2) {
      return SizedBox(
        height: 60,
        child: Center(
          child: Text(L.of(context).curveNotEnough,
              style: const TextStyle(fontSize: 11, color: UColors.muted)),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 132,
          child: CustomPaint(
            size: Size.infinite,
            painter: _CurvePainter(points),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _axisLabel(points.first.label),
            if (points.length > 2)
              _axisLabel(points[points.length ~/ 2].label),
            _axisLabel(points.last.label),
          ],
        ),
      ],
    );
  }

  Widget _axisLabel(String s) => Text(s,
      style: const TextStyle(
        fontSize: 9,
        color: UColors.faint,
        fontFeatures: [FontFeature.tabularFigures()],
      ));
}

class _CurvePainter extends CustomPainter {
  final List<MonthMood> points;
  _CurvePainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    // 上下留出一行注释文字的空间，避免峰/谷标注顶到模块标题或月份轴
    const padTop = 22.0, padBottom = 22.0;
    final h = size.height - padTop - padBottom;

    // 浅网格
    final grid = Paint()
      ..color = UColors.grid
      ..strokeWidth = 1;
    for (final f in [0.25, 0.5, 0.75]) {
      final y = padTop + h * f;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }

    Offset pos(int i) {
      final x = points.length == 1
          ? size.width / 2
          : i * size.width / (points.length - 1);
      final norm = ((points[i].sentiment - 1) / 9).clamp(0.0, 1.0);
      return Offset(x, padTop + h * (1 - norm));
    }

    final line = Path()..moveTo(pos(0).dx, pos(0).dy);
    final area = Path()..moveTo(pos(0).dx, size.height - padBottom);
    area.lineTo(pos(0).dx, pos(0).dy);
    for (var i = 1; i < points.length; i++) {
      line.lineTo(pos(i).dx, pos(i).dy);
      area.lineTo(pos(i).dx, pos(i).dy);
    }
    area
      ..lineTo(pos(points.length - 1).dx, size.height - padBottom)
      ..close();

    canvas.drawPath(
        area, Paint()..color = UColors.rose.withValues(alpha: .08));
    canvas.drawPath(
      line,
      Paint()
        ..color = UColors.rose
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    // 峰/谷标注 + 终点强调
    var minI = 0, maxI = 0;
    for (var i = 1; i < points.length; i++) {
      if (points[i].sentiment < points[minI].sentiment) minI = i;
      if (points[i].sentiment > points[maxI].sentiment) maxI = i;
    }

    void dot(int i, Color fill, Color ring) {
      canvas.drawCircle(pos(i), 4.5, Paint()..color = ring);
      canvas.drawCircle(pos(i), 3, Paint()..color = fill);
    }

    void note(int i, String text, Color color, {bool above = false}) {
      final tp = TextPainter(
        text: TextSpan(
            text: text,
            style: TextStyle(
                fontSize: 8.5, color: color, fontWeight: FontWeight.w600)),
        textDirection: TextDirection.ltr,
        maxLines: 1,
        ellipsis: '…',
      )..layout(maxWidth: size.width * .6);
      final p = pos(i);
      final x = (p.dx - tp.width / 2).clamp(0.0, size.width - tp.width);
      // 首选方向放不下就翻到另一侧，最后钳制在画布内
      var y = above ? p.dy - tp.height - 8 : p.dy + 8;
      if (y < 0) y = p.dy + 8;
      if (y + tp.height > size.height) y = p.dy - tp.height - 8;
      y = y.clamp(0.0, size.height - tp.height);
      tp.paint(canvas, Offset(x, y));
    }

    if (minI != maxI) {
      dot(minI, UColors.screen, UColors.muted);
      final noteMin = points[minI].note;
      note(minI, noteMin ?? points[minI].label, UColors.muted);
    }
    dot(maxI, UColors.rose, Colors.white);
    final noteMax = points[maxI].note;
    note(maxI, noteMax ?? points[maxI].label, UColors.rose, above: true);
  }

  @override
  bool shouldRepaint(_CurvePainter old) => old.points != points;
}

/// 话题横条：长度编码量级，同一玫瑰色按位次递减透明度（颜色不承担类别信息）。
class TopicBars extends StatelessWidget {
  final List<TopicShare> topics;
  const TopicBars({super.key, required this.topics});

  @override
  Widget build(BuildContext context) {
    if (topics.isEmpty) return const SizedBox.shrink();
    final total =
        topics.fold<int>(0, (a, t) => a + t.weight).clamp(1, 1 << 30);
    final maxW = topics.first.weight;
    const alphas = [1.0, .8, .62, .46, .32];

    return Column(
      children: [
        for (var i = 0; i < topics.length; i++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(topics[i].topic,
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor:
                            (topics[i].weight / maxW).clamp(.08, 1.0),
                        child: Container(
                          height: 8,
                          decoration: BoxDecoration(
                            color: UColors.rose.withValues(
                                alpha: alphas[i % alphas.length]),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('${(topics[i].weight * 100 / total).round()}%',
                        style: const TextStyle(
                          fontSize: 10.5,
                          color: UColors.muted,
                          fontFeatures: [FontFeature.tabularFigures()],
                        )),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }
}
