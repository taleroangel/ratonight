import 'dart:math';

import 'package:flutter/material.dart';

const itemSeparation = 10.0;
const itemSize = 64.0;
const itemsPerRow = 3;

class ColorContainer extends StatelessWidget {
  const ColorContainer({
    required this.color,
    required this.onTap,
    required this.selected,
    super.key,
  });

  final Color color;
  final void Function() onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          height: itemSize,
          width: itemSize,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: selected
                ? Border.all(
                    color: color.computeLuminance() > 0.5
                        ? Colors.black
                        : Colors.white,
                    width: 3.0,
                  )
                : null,
          ),
        ),
      );
}

class ColorFlowDelegate extends FlowDelegate {
  const ColorFlowDelegate({required this.childCount});
  final int childCount;

  @override
  void paintChildren(FlowPaintingContext context) {
    // Get the count of elements
    final currentCount = (childCount - 1);

    // Show the childCount
    for (var i = 0; i < currentCount; i++) {
      // Calculate position of dots
      final angle = 2 * pi * (i / currentCount);
      final radius = itemSeparation + context.getChildSize(i)!.height;
      final x = radius * cos(angle) + radius;
      final y = radius * sin(angle) + radius;

      // Create the transform matrix
      final transformMatrix = Matrix4.translationValues(x, y, 0.0);

      // Paint the child
      context.paintChild(i, transform: transformMatrix);
    }

    // Paint the final size
    final radius = itemSeparation + context.getChildSize(currentCount)!.height;
    context.paintChild(
      currentCount,
      transform: Matrix4.translationValues(
        radius,
        radius,
        0.0,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant FlowDelegate oldDelegate) => false;

  @override
  Size getSize(BoxConstraints constraints) => const Size.square(
      (itemSize * itemsPerRow) + (itemSeparation * (itemsPerRow - 1)));
}
