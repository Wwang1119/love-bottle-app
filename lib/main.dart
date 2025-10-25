import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        // 顶部标题栏
        appBar: AppBar(
          title: const Text("我们的回忆长河"),
          centerTitle: true,
          backgroundColor: Colors.purpleAccent,
        ),
        // 页面主体（时间长河+瓶子）
        body: SingleChildScrollView(
          scrollDirection: Axis.horizontal, // 允许左右滑动
          child: Container(
            width: MediaQuery.of(context).size.width * 2, // 长河宽度设为2倍屏幕（方便滑动）
            padding: const EdgeInsets.symmetric(vertical: 80), // 上下留白
            child: CustomPaint(
              // 画弯曲的时间长河
              painter: RiverPainter(),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 瓶子1：红色（甜蜜类）
                  BottleWidget(
                    color: Colors.red,
                    name: "第一次约会",
                    hasUnread: true,
                    leftMargin: 50, // 距离左侧的位置
                  ),
                  // 瓶子2：粉色（约会类）
                  BottleWidget(
                    color: Colors.pink,
                    name: "看电影",
                    hasUnread: false,
                    leftMargin: 250,
                  ),
                  // 瓶子3：黑色（矛盾类）
                  BottleWidget(
                    color: Colors.black,
                    name: "吵架和解",
                    hasUnread: false,
                    leftMargin: 450,
                  ),
                ],
              ),
            ),
          ),
        ),
        // 右下角“+”按钮
        floatingActionButton: FloatingActionButton(
          onPressed: () {}, // 暂不实现功能，仅显示
          backgroundColor: Colors.purpleAccent,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

// 自定义画笔：画弯曲的时间长河
class RiverPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey[300]!
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke;

    // 画弯曲曲线（起点→两个控制点→终点）
    final path = Path()
      ..moveTo(0, size.height / 2) // 起点（最左侧）
      ..quadraticBezierTo(
        size.width / 4, size.height / 2 - 50, // 第一个控制点（向上弯）
        size.width / 2, size.height / 2, // 中间点
      )
      ..quadraticBezierTo(
        size.width * 3 / 4, size.height / 2 + 50, // 第二个控制点（向下弯）
        size.width, size.height / 2, // 终点（最右侧）
      );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// 瓶子组件（复用）
class BottleWidget extends StatelessWidget {
  final Color color;
  final String name;
  final bool hasUnread;
  final double leftMargin;

  const BottleWidget({
    super.key,
    required this.color,
    required this.name,
    required this.hasUnread,
    required this.leftMargin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: leftMargin, bottom: 40), // 与长河对齐
      child: Column(
        children: [
          // 瓶子图标（带未读红点）
          Stack(
            children: [
              Icon(Icons.liquor, size: 80, color: color),
              if (hasUnread)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
          // 瓶子名称
          SizedBox(height: 8),
          Text(name, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}