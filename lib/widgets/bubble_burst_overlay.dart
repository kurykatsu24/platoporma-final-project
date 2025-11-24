import 'package:flutter/material.dart';
import 'dart:math';

class BubbleBurstOverlay extends StatefulWidget {
  final Offset center;
  final VoidCallback onComplete;

  const BubbleBurstOverlay({super.key, required this.center, required this.onComplete});

  @override
  State<BubbleBurstOverlay> createState() => _BubbleBurstOverlayState();
}

class _BubbleBurstOverlayState extends State<BubbleBurstOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> radiusAnim;
  late Animation<double> opacityAnim;

  final int bubbleCount = 12;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 680),
    );

    radiusAnim = Tween<double>(begin: 0, end: 40).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeOut),
    );

    opacityAnim = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeIn),
    );

    controller.forward().then((_) => widget.onComplete());
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: controller,
        builder: (_, __) {
          return Stack(
            children: List.generate(bubbleCount, (i) {
              final angle = (i / bubbleCount) * 6.283; // 360 rad
              final dx = cos(angle) * radiusAnim.value;
              final dy = sin(angle) * radiusAnim.value;

              return Positioned(
                left: widget.center.dx + dx,
                top: widget.center.dy + dy,
                child: Opacity(
                  opacity: opacityAnim.value,
                  child: Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF06644),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}