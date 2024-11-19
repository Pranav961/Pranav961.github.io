import 'package:flutter/material.dart';
import 'dart:ui';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Dock(
            items: [
              {'icon': Icons.folder, 'color': Colors.blue},
              {'icon': Icons.grid_view, 'color': Colors.red},
              {'icon': Icons.music_note, 'color': Colors.purple},
              {'icon': Icons.camera, 'color': Colors.green},
              {'icon': Icons.photo, 'color': Colors.orange},
            ],
          ),
        ),
      ),
    );
  }
}

class Dock extends StatefulWidget {
  const Dock({super.key, required this.items});

  final List<Map<String, dynamic>> items;

  @override
  State<Dock> createState() => _DockState();
}

class _DockState extends State<Dock> {
  late List<Map<String, dynamic>> _items;

  int? _hoveredIndex;

  @override
  void initState() {
    super.initState();
    _items = List.from(widget.items);
  }

  double _getScaledSize(int index) {
    if (_hoveredIndex == null) return 48.0;

    final difference = (_hoveredIndex! - index).abs();
    const maxScale = 64.0;
    const minScale = 48.0;
    const effectRange = 2;

    if (difference == 0) {
      return maxScale;
    } else if (difference <= effectRange) {
      final ratio = (effectRange - difference) / effectRange;
      return lerpDouble(minScale, maxScale, ratio)!;
    } else {
      return minScale;
    }
  }

  double _getTranslationY(int index) {
    if (_hoveredIndex == null) return 0.0;

    final difference = (_hoveredIndex! - index).abs();
    const maxTranslation = -10.0;
    const effectRange = 2;

    if (difference == 0) {
      return maxTranslation;
    } else if (difference <= effectRange) {
      final ratio = (effectRange - difference) / effectRange;
      return lerpDouble(0.0, maxTranslation, ratio)!;
    } else {
      return 0.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(_items.length, (index) {
            return GestureDetector(
              onPanStart: (_) {
                setState(() {
                  _hoveredIndex = null;
                });
              },
              child: Draggable<Map<String, dynamic>>(
                data: _items[index],
                onDragStarted: () {
                  setState(() {
                    _hoveredIndex = null;
                  });
                },
                onDragCompleted: () {},
                onDraggableCanceled: (_, __) {
                  setState(() {});
                },
                feedback: Material(
                    color: Colors.transparent,
                    child: Transform.scale(
                      scale: 1.0,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        height: _getScaledSize(index),
                        width: _getScaledSize(index),
                        child: _buildIcon(
                          _items[index],
                          _getScaledSize(index),
                        ),
                      ),
                    )),
                childWhenDragging: const SizedBox(width: 48, height: 48),
                child: DragTarget<Map<String, dynamic>>(
                  onAcceptWithDetails: (details) {
                    setState(() {
                      final receivedItem = details.data;
                      final draggedIndex = _items.indexOf(receivedItem);
                      final targetIndex = index;

                      _items.removeAt(draggedIndex);
                      _items.insert(targetIndex, receivedItem);
                    });
                  },
                  builder: (context, candidateData, rejectedData) {
                    return MouseRegion(
                      onEnter: (_) {
                        setState(() {
                          _hoveredIndex = index;
                        });
                      },
                      onExit: (_) {
                        setState(() {
                          _hoveredIndex = null;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        transform: Matrix4.identity()
                          ..translate(
                            0.0,
                            _getTranslationY(index),
                            0.0,
                          ),
                        height: _getScaledSize(index),
                        width: _getScaledSize(index),
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        child: _buildIcon(_items[index], _getScaledSize(index)),
                      ),
                    );
                  },
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildIcon(Map<String, dynamic> item, double size,
      {bool isDragging = false}) {
    return Container(
      decoration: BoxDecoration(
        color: item['color'],
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDragging
                ? Colors.black.withOpacity(0.5)
                : Colors.black.withOpacity(0.3),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Center(
        child: Icon(
          item['icon'],
          color: Colors.white,
          size: size / 2,
        ),
      ),
    );
  }
}
