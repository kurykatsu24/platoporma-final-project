import 'package:flutter/material.dart';
import 'package:platoporma/widgets/bubble_burst_overlay.dart';

//triggers a bubble burst animation at the center of a widget identified by [key].
void showBubbleBurst({
  required BuildContext context,
  required GlobalKey key,
  Offset offset = const Offset(0, 0),
}) {
  final RenderBox? box = key.currentContext?.findRenderObject() as RenderBox?;
  if (box == null) return;

  final Offset center = box.localToGlobal(
    Offset(box.size.width / 2, box.size.height / 2),
  ) + offset; 

  final OverlayState overlay = Overlay.of(context);
  late OverlayEntry entry;

  entry = OverlayEntry(
    builder: (_) => BubbleBurstOverlay(
      center: center,
      onComplete: () => entry.remove(),
    ),
  );

  overlay.insert(entry);
}