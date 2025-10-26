import 'package:flutter/material.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class BottleItem extends StatefulWidget {
  final Map<String, dynamic> bottle;
  final bool isRight;

  const BottleItem({
    Key? key,
    required this.bottle,
    required this.isRight,
  }) : super(key: key);

  @override
  State<BottleItem> createState() => _BottleItemState();
}

class _BottleItemState extends State<BottleItem> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final bottle = widget.bottle;
    final title = bottle['title'] as String;
    final content = bottle['content'] as String;
    final time = bottle['time'] as DateTime;
    // 核心修复：显式转换为List<String>
    final mediaPaths = List<String>.from(bottle['mediaPaths'] as List<dynamic>);
    final fullTimeStr = DateFormat('yyyy-MM-dd HH:mm').format(time);

    return Column(
      crossAxisAlignment: widget.isRight
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            setState(() => _isExpanded = !_isExpanded);
          },
          child: Container(
            width: 220,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.blue[400]!, width: 2),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(12),
                topRight: const Radius.circular(12),
                bottomLeft: widget.isRight
                    ? const Radius.circular(12)
                    : const Radius.circular(0),
                bottomRight: widget.isRight
                    ? const Radius.circular(0)
                    : const Radius.circular(12),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 3,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  Icons.wine_bar_outlined,
                  color: Colors.blue[500],
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  _isExpanded
                      ? Icons.arrow_upward
                      : Icons.arrow_downward,
                  color: Colors.blue[500],
                  size: 16,
                ),
              ],
            ),
          ),
        ),
        if (_isExpanded)
          Container(
            width: 280,
            margin: EdgeInsets.only(
              top: 4,
              left: widget.isRight ? 0 : 12,
              right: widget.isRight ? 12 : 0,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: widget.isRight
                    ? const Radius.circular(12)
                    : const Radius.circular(0),
                topRight: widget.isRight
                    ? const Radius.circular(0)
                    : const Radius.circular(12),
                bottomLeft: const Radius.circular(12),
                bottomRight: const Radius.circular(12),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 3,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fullTimeStr,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
                const SizedBox(height: 8),
                if (content.isNotEmpty)
                  Column(
                    children: [
                      Text(
                        content,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                if (mediaPaths.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "回忆照片（${mediaPaths.length}张）",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.blue[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      GridView.count(
                        crossAxisCount: 3,
                        crossAxisSpacing: 6,
                        mainAxisSpacing: 6,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        children: mediaPaths.map((path) {
                          return Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.grey[200]!,
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: kIsWeb
                                ? Image.network(
                                    path,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity,
                                    errorBuilder: (context, error, stackTrace) =>
                                        const Icon(
                                      Icons.broken_image,
                                      color: Colors.grey,
                                    ),
                                  )
                                : Image.file(
                                    File(path),
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity,
                                    errorBuilder: (context, error, stackTrace) =>
                                        const Icon(
                                      Icons.broken_image,
                                      color: Colors.grey,
                                    ),
                                  ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
              ],
            ),
          ),
      ],
    );
  }
}