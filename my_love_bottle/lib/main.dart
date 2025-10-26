import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'widgets/river_background.dart';
import 'widgets/bottle_item.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:html' as html;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '爱情回忆长河',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.blue[50],
        cardTheme: CardThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 3,
          margin: const EdgeInsets.symmetric(vertical: 8),
        ),
      ),
      home: const TimelineScreen(),
    );
  }
}

class TimelineScreen extends StatefulWidget {
  const TimelineScreen({super.key});

  @override
  _TimelineScreenState createState() => _TimelineScreenState();
}

class _TimelineScreenState extends State<TimelineScreen> {
  // 核心修复：显式声明为List<String>，避免dynamic类型
  final List<Map<String, dynamic>> _bottles = [];
  final ImagePicker _picker = ImagePicker();
  List<String> selectedMediaPaths = <String>[];
  List<String> selectedMediaTypes = <String>[];

  void _addBottle(Map<String, dynamic> newBottle) {
    setState(() {
      _bottles.add(newBottle);
      _bottles.sort((a, b) => (b['time'] as DateTime).compareTo(a['time'] as DateTime));
    });
  }

  Map<String, List<Map<String, dynamic>>> _groupBottlesByDate() {
    final Map<String, List<Map<String, dynamic>>> grouped = {};
    for (final bottle in _bottles) {
      final dateKey = DateFormat('yyyy-MM-dd').format(bottle['time'] as DateTime);
      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(bottle);
    }
    return Map.fromEntries(
      grouped.entries.toList()..sort((a, b) => b.key.compareTo(a.key)),
    );
  }

  Future<void> _pickMultiMedia() async {
    try {
      final List<XFile> files = await _picker.pickMultiImage(
        maxWidth: 800,
        maxHeight: 800,
      );
      if (files.isNotEmpty && files.length <= 9) {
        final List<String> paths = <String>[];
        for (final file in files) {
          if (kIsWeb) {
            final blobBytes = await file.readAsBytes();
            final blob = html.Blob([blobBytes]);
            final blobUrl = html.Url.createObjectUrlFromBlob(blob);
            paths.add(blobUrl);
          } else {
            paths.add(file.path);
          }
        }
        setState(() {
          selectedMediaPaths = paths;
          selectedMediaTypes = List.filled(paths.length, 'image');
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('成功选择 ${paths.length} 张图片')),
        );
      } else if (files.length > 9) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('最多可选择9张图片')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('已取消图片选择')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('选择图片失败: $e')),
      );
    }
  }

  void _showAddBottleDialog() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController contentController = TextEditingController();
    DateTime selectedDate = DateTime.now();
    TimeOfDay selectedTime = TimeOfDay.now();
    selectedMediaPaths = <String>[];
    selectedMediaTypes = <String>[];

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("添加回忆小瓶子"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: "瓶子标题（必填）",
                        border: OutlineInputBorder(),
                      ),
                      autofocus: true,
                      maxLength: 20,
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: contentController,
                      decoration: const InputDecoration(
                        labelText: "回忆内容（可选）",
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 4,
                      minLines: 2,
                      maxLength: 200,
                    ),
                    const SizedBox(height: 8),
                    ListTile(
                      title: Text("日期: ${DateFormat('yyyy-MM-dd').format(selectedDate)}"),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          setState(() => selectedDate = picked);
                        }
                      },
                    ),
                    ListTile(
                      title: Text("时间: ${selectedTime.format(context)}"),
                      trailing: const Icon(Icons.access_time),
                      onTap: () async {
                        final TimeOfDay? picked = await showTimePicker(
                          context: context,
                          initialTime: selectedTime,
                        );
                        if (picked != null) {
                          setState(() => selectedTime = picked);
                        }
                      },
                    ),
                    const SizedBox(height: 8),
                    Column(
                      children: [
                        TextButton.icon(
                          onPressed: () => _pickMultiMedia(),
                          icon: const Icon(Icons.add_photo_alternate),
                          label: const Text("选择图片（最多9张）"),
                        ),
                        if (selectedMediaPaths.isNotEmpty)
                          SizedBox(
                            width: double.infinity,
                            height: 120,
                            child: GridView.count(
                              crossAxisCount: 3,
                              crossAxisSpacing: 4,
                              mainAxisSpacing: 4,
                              children: selectedMediaPaths
                                  .asMap()
                                  .entries
                                  .map((entry) {
                                final index = entry.key;
                                final path = entry.value;
                                return Stack(
                                  children: [
                                    kIsWeb
                                        ? Image.network(
                                            path,
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                            height: double.infinity,
                                            errorBuilder: (_, __, ___) => const Icon(
                                              Icons.broken_image,
                                              color: Colors.grey,
                                            ),
                                          )
                                        : Image.file(
                                            File(path),
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                            height: double.infinity,
                                            errorBuilder: (_, __, ___) => const Icon(
                                              Icons.broken_image,
                                              color: Colors.grey,
                                            ),
                                          ),
                                    Positioned(
                                      top: 2,
                                      right: 2,
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            selectedMediaPaths.removeAt(index);
                                            selectedMediaTypes.removeAt(index);
                                          });
                                        },
                                        child: Container(
                                          color: Colors.black54,
                                          child: const Icon(
                                            Icons.close,
                                            size: 16,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text("取消"),
                ),
                ElevatedButton(
                  onPressed: () {
                    final title = nameController.text.trim();
                    if (title.isNotEmpty) {
                      final DateTime finalDateTime = DateTime(
                        selectedDate.year,
                        selectedDate.month,
                        selectedDate.day,
                        selectedTime.hour,
                        selectedTime.minute,
                      );
                      // 核心修复：显式声明类型为List<String>
                      final newBottle = {
                        'title': title,
                        'content': contentController.text.trim(),
                        'time': finalDateTime,
                        'mediaPaths': List<String>.from(selectedMediaPaths),
                        'mediaTypes': List<String>.from(selectedMediaTypes),
                      };
                      _addBottle(newBottle);
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('回忆小瓶子添加成功！已显示在时间轴上')),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('请填写瓶子标题（必填）')),
                      );
                    }
                  },
                  child: const Text("添加"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final groupedBottles = _groupBottlesByDate();

    return Scaffold(
      appBar: AppBar(
        title: const Text("我们的回忆长河"),
        centerTitle: true,
        backgroundColor: Colors.blue[600],
        elevation: 4,
      ),
      body: Stack(
        children: [
          const RiverBackground(),
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              children: [
                if (groupedBottles.isEmpty)
                  Column(
                    children: [
                      const SizedBox(height: 100),
                      const Icon(
                        Icons.inbox_outlined,
                        size: 60,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "时间轴还是空的～",
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "点击右下角「+」添加你的第一个回忆小瓶子吧",
                        style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                      ),
                    ],
                  )
                else
                  Column(
                    children: groupedBottles.entries.map((entry) {
                      final date = entry.key;
                      final bottles = entry.value;

                      return Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue[600],
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 2,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                            child: Text(
                              date,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Column(
                            children: bottles.asMap().entries.map((bottleEntry) {
                              final index = bottleEntry.key;
                              final bottle = bottleEntry.value;
                              final isRight = index % 2 == 1;

                              return Padding(
                                padding: EdgeInsets.only(
                                  left: isRight ? 50 : 20,
                                  right: isRight ? 20 : 50,
                                  bottom: 16,
                                ),
                                child: Align(
                                  alignment: isRight
                                      ? Alignment.centerRight
                                      : Alignment.centerLeft,
                                  child: BottleItem(
                                    bottle: bottle,
                                    isRight: isRight,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 24),
                        ],
                      );
                    }).toList(),
                  ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddBottleDialog,
        backgroundColor: Colors.blue[600],
        child: const Icon(Icons.add),
        elevation: 6,
        tooltip: "添加回忆小瓶子",
      ),
    );
  }
}