import 'package:awesome_flutter_extensions/awesome_flutter_extensions.dart';
import 'package:flutter/material.dart';

class AmbientCharasteristicTile extends StatelessWidget {
  const AmbientCharasteristicTile({
    required this.value,
    required this.unit,
    required this.icon,
    super.key,
  });

  final double value;
  final String unit;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Icon(
              icon,
              color: context.colors.scheme.primaryContainer,
              size: 40.0,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Text(
              "${value.toStringAsFixed(1)}°C",
              textAlign: TextAlign.left,
              style: context.themes.text.displayMedium?.copyWith(
                color: context.colors.scheme.primaryContainer,
              ),
            ),
          ),
        ],
      );
}
