import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: TimelineScreen(),
    );
  }
}

class TimelineScreen extends StatefulWidget {
  @override
  _TimelineScreenState createState() => _TimelineScreenState();
}

class _TimelineScreenState extends State<TimelineScreen> {
  // 初始为空列表，确保进入页面时没有默认瓶子
  final List<Map<String, dynamic>> _bottles = [];

  void _addBottle(Map<String, dynamic> newBottle) {
    setState(() {
      _bottles.add(newBottle);
      _bottles.sort((a, b) => a['time'].compareTo(b['time']));
    });
  }

  void _showAddBottleDialog() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController timeController = TextEditingController();
    final TextEditingController contentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("添加回忆小瓶子"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "瓶子名称（必填）"),
                autofocus: true, // 打开弹窗后自动聚焦输入框
              ),
              TextField(
                controller: contentController,
                decoration: const InputDecoration(labelText: "回忆内容（可选）"),
              ),
              TextField(
                controller: timeController,
                decoration: const InputDecoration(
                  labelText: "时间（格式：YYYY-MM-DD HH:mm，必填）",
                  hintText: "例如：2024-10-25 19:30",
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("取消"),
            ),
            TextButton(
              onPressed: () {
                final name = nameController.text.trim();
                final timeStr = timeController.text.trim();
                final time = DateTime.tryParse(timeStr);

                if (name.isNotEmpty && time != null) {
                  _addBottle({
                    'name': name,
                    'content': contentController.text.trim(),
                    'time': time,
                  });
                  Navigator.of(context).pop();
                }
              },
              child: const Text("添加"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("我们的回忆长河"),
        centerTitle: true,
        backgroundColor: Colors.purpleAccent,
      ),
      // 彻底修复纵向滚动：用LayoutBuilder动态获取可用高度
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Container(
            height: constraints.maxHeight - kToolbarHeight, // 减去AppBar高度
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                children: _bottles.isEmpty
                    ? [
                        const SizedBox(height: 100),
                        const Text(
                          "点击右下角加号，开始记录回忆吧～",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      ]
                    : _bottles.map((bottle) {
                        return Column(
                          children: [
                            Text(
                              "${bottle['time'].year}-${bottle['time'].month.toString().padLeft(2, '0')}-${bottle['time'].day.toString().padLeft(2, '0')} ${bottle['time'].hour.toString().padLeft(2, '0')}:${bottle['time'].minute.toString().padLeft(2, '0')}",
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 8),
                            BottleWidget(
                              name: bottle['name'],
                              content: bottle['content'],
                              color: Colors.blue,
                            ),
                            const SizedBox(height: 20),
                          ],
                        );
                      }).toList(),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddBottleDialog, // 确保方法绑定正确
        backgroundColor: Colors.purpleAccent,
        child: const Icon(Icons.add),
        elevation: 6,
      ),
    );
  }
}

class BottleWidget extends StatelessWidget {
  final String name;
  final String content;
  final Color color;

  const BottleWidget({
    required this.name,
    required this.content,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (content.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                content,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ),
        ],
      ),
    );
  }
}