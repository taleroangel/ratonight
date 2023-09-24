import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:ratonight/tools/map_values.dart';

class LightServiceUtils {
  /// Parse byte data into [HSVColor]'s list
  static List<HSVColor> bytesToColors(List<int> data) {
    // Parse byte data
    final parsedData = Uint8List.fromList(data);
    // Where to store data
    final colorData = <HSVColor>[];
    // Iterate over list and construct data
    for (int ii = 0; ii < parsedData.length;) {
      // Data sublist
      colorData.add(HSVColor.fromAHSV(
        1.0,
        mapValues(parsedData[ii++], 0, 255, 0.0, 360.0).toDouble(),
        mapValues(parsedData[ii++], 0, 255, 0.0, 1.0).toDouble(),
        mapValues(parsedData[ii++], 0, 255, 0.0, 1.0).toDouble(),
      ));
    }
    // Return the built data
    return colorData;
  }

  /// Set color with mask into device
  static List<int> colorsToByte(
          bool applyToAll, int currentlySelectedIndex, HSVColor color) =>
      [
        // Select all is last index
        pow(2, applyToAll ? 7 : currentlySelectedIndex).toInt(),
        mapValues(color.hue, 0.0, 360.0, 0, 255).toInt(),
        mapValues(color.saturation, 0.0, 1.0, 0, 255).toInt(),
        mapValues(color.value, 0.0, 1.0, 0, 255).toInt(),
      ];

  static Color averageColor(List<HSVColor> hsvColors) => HSVColor.fromAHSV(
        1.0,
        hsvColors.map((hsvColor) => hsvColor.hue).reduce((a, b) => a + b) /
            hsvColors.length,
        hsvColors
                .map((hsvColor) => hsvColor.saturation)
                .reduce((a, b) => a + b) /
            hsvColors.length,
        hsvColors.map((hsvColor) => hsvColor.value).reduce((a, b) => a + b) /
            hsvColors.length,
      ).toColor();
}
