import 'package:flutter/material.dart';
import 'package:weather_animation/weather_animation.dart';

class AmbientAnimation extends StatelessWidget {
  const AmbientAnimation({
    required this.canvasSize,
    required this.humidity,
    required this.temperature,
    super.key,
  });

  final Size canvasSize;
  final double humidity;
  final double temperature;

  @override
  Widget build(BuildContext context) {
    final currentDate = DayMoment.fromDateTime(DateTime.now());

    /// Wrapper
    return WrapperScene(
      sizeCanvas: canvasSize,
      clip: Clip.none,
      colors: switch (currentDate) {
        DayMoment.morning => const [
            Color(0xFFFFA616),
            Color(0xFFFBE160),
            Color(0xFFF7E1AC),
            Color(0xFFB3EDFD),
            Color(0xFF73B7E2)
          ],
        DayMoment.afternoon => const [
            Color(0xFFFF0808),
            Color(0xFFFF6E0E),
            Color(0xFFFFA504),
            Color(0xFFFFF50C),
          ],
        DayMoment.evening => const [
            Color(0xFF0C237D),
            Color(0xFF5C99F9),
            Color(0xFFCDA7FF),
            Color(0xFFFFB5C4),
          ],
        DayMoment.night => const [
            Color(0xFF0C237D),
            Color(0xFF3755CD),
            Color(0xFF8969C5),
            Color(0xFF7C66D4),
          ],
      },
      children: switch (currentDate) {
        DayMoment.morning || DayMoment.afternoon => [
            if (humidity > 70.0)
              const RainWidget(
                rainConfig: RainConfig(color: Colors.blue),
              ),
            if (temperature > 20.0) const SunWidget() else const CloudWidget(),
          ],
        DayMoment.evening || DayMoment.night => [
            if (humidity > 70.0)
              const RainWidget(
                rainConfig: RainConfig(color: Colors.blue),
              ),
            if (temperature < 20.0)
              const WindWidget(
                windConfig: WindConfig(color: Colors.white),
              ),
            const CloudWidget(),
          ],
      },
    );
  }
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
