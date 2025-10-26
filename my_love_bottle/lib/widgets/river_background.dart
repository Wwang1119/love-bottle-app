import 'package:flutter/material.dart';
import 'dart:ui' as ui; // 导入dart:ui，用于Canvas.drawShadow

class RiverBackground extends StatelessWidget {
  const RiverBackground({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return SizedBox(
      width: double.infinity,
      height: screenHeight,
      child: CustomPaint(
        painter: _StaticSShapedRiverPainter(
          screenWidth: screenWidth,
          screenHeight: screenHeight,
          riverWidth: 20,
          curveAmplitude: 25,
        ),
      ),
    );
  }
}

class _StaticSShapedRiverPainter extends CustomPainter {
  final double screenWidth;
  final double screenHeight;
  final double riverWidth;
  final double curveAmplitude;

  _StaticSShapedRiverPainter({
    required this.screenWidth,
    required this.screenHeight,
    required this.riverWidth,
    required this.curveAmplitude,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. 背景底色
    final backgroundPaint = Paint()
      ..color = Colors.blue[50]!;
    canvas.drawRect(Rect.fromLTWH(0, 0, screenWidth, screenHeight), backgroundPaint);

    // 2. 计算河流中心线
    final centerX = screenWidth / 2;
    final segmentHeight = screenHeight / 4;

    // 3. 构建河流路径（左边界+右边界，闭合）
    final riverPath = Path();

    // -------------------------- 左边界（从顶到底） --------------------------
    riverPath.moveTo(centerX - riverWidth / 2, 0); // 顶部起点
    // 第一段：轻微向右弯
    riverPath.cubicTo(
      centerX - riverWidth / 2 + curveAmplitude * 0.8, segmentHeight * 0.5,
      centerX - riverWidth / 2 + curveAmplitude * 0.5, segmentHeight * 1.5,
      centerX - riverWidth / 2, segmentHeight * 2,
    );
    // 第二段：轻微向左弯
    riverPath.cubicTo(
      centerX - riverWidth / 2 - curveAmplitude * 0.8, segmentHeight * 2.5,
      centerX - riverWidth / 2 - curveAmplitude * 0.5, segmentHeight * 3.5,
      centerX - riverWidth / 2, screenHeight, // 底部左终点
    );

    // -------------------------- 右边界（从底到顶，替代reverse） --------------------------
    // 核心修复2：删除Path.reverse()，手动从底部往顶部画右边界，实现闭合
    riverPath.lineTo(centerX + riverWidth / 2, screenHeight); // 底部右起点
    // 第一段：轻微向右弯（与左边界对称）
    riverPath.cubicTo(
      centerX + riverWidth / 2 + curveAmplitude * 0.5, segmentHeight * 3.5,
      centerX + riverWidth / 2 + curveAmplitude * 0.8, segmentHeight * 2.5,
      centerX + riverWidth / 2, segmentHeight * 2,
    );
    // 第二段：轻微向左弯（与左边界对称）
    riverPath.cubicTo(
      centerX + riverWidth / 2 - curveAmplitude * 0.5, segmentHeight * 1.5,
      centerX + riverWidth / 2 - curveAmplitude * 0.8, segmentHeight * 0.5,
      centerX + riverWidth / 2, 0, // 顶部右终点
    );

    // 闭合路径
    riverPath.close();

    // 4. 河流填充（渐变，无shadow属性）
    final riverPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Colors.blue[300]!,
          Colors.blue[500]!,
        ],
      ).createShader(Rect.fromLTWH(
        centerX - riverWidth / 2,
        0,
        riverWidth,
        screenHeight,
      ))
      ..style = PaintingStyle.fill;

    // 核心修复3：用Canvas.drawShadow给路径加阴影（替代Paint的shadow属性）
    canvas.drawShadow(
      riverPath,
      Colors.blue[600]!.withOpacity(0.2), // 阴影颜色
      8, // 模糊半径
      true, // 是否透明通道
    );

    // 5. 绘制河流
    canvas.drawPath(riverPath, riverPaint);

    // 6. 河流高光
    final highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final highlightPath = Path();
    highlightPath.moveTo(centerX - riverWidth / 2 + 3, 0);
    highlightPath.cubicTo(
      centerX - riverWidth / 2 + curveAmplitude * 0.8 + 3, segmentHeight * 0.5,
      centerX - riverWidth / 2 + curveAmplitude * 0.5 + 3, segmentHeight * 1.5,
      centerX - riverWidth / 2 + 3, segmentHeight * 2,
    );
    highlightPath.cubicTo(
      centerX - riverWidth / 2 - curveAmplitude * 0.8 + 3, segmentHeight * 2.5,
      centerX - riverWidth / 2 - curveAmplitude * 0.5 + 3, segmentHeight * 3.5,
      centerX - riverWidth / 2 + 3, screenHeight,
    );
    canvas.drawPath(highlightPath, highlightPaint);
  }

  @override
  bool shouldRepaint(covariant _StaticSShapedRiverPainter oldDelegate) {
    return screenWidth != oldDelegate.screenWidth ||
        screenHeight != oldDelegate.screenHeight ||
        riverWidth != oldDelegate.riverWidth ||
        curveAmplitude != oldDelegate.curveAmplitude;
  }
}