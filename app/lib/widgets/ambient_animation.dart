import 'package:flutter/material.dart';
import 'package:weather_animation/weather_animation.dart';

class AmbientAnimation extends StatelessWidget {
  const AmbientAnimation({
    required this.canvasSize,
    super.key,
  });

  final Size canvasSize;

  @override
  Widget build(BuildContext context) => WrapperScene(
        sizeCanvas: canvasSize,
        clip: Clip.none,
        colors: switch (DayMoment.fromDateTime(DateTime.now())) {
          DayMoment.morning => [],
          DayMoment.afternoon => [],
          DayMoment.evening => [],
          DayMoment.night => [],
        },
        children: switch (DayMoment.fromDateTime(DateTime.now())) {
          DayMoment.morning => [],
          DayMoment.afternoon => [],
          DayMoment.evening => [],
          DayMoment.night => [],
        },
      );
}

enum DayMoment {
  morning,
  afternoon,
  evening,
  night;

  factory DayMoment.fromDateTime(DateTime time) => switch (time.hour) {
        > 5 && < 10 => DayMoment.morning,
        < 18 => DayMoment.afternoon,
        < 20 => DayMoment.evening,
        _ => DayMoment.night,
      };
}
