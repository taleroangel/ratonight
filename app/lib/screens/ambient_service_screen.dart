import 'dart:async';

import 'package:awesome_flutter_extensions/awesome_flutter_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:ratonight/environment.g.dart';
import 'package:ratonight/provider/device_connection_provider.dart';
import 'package:ratonight/tools/parset_float_bytes.dart';
import 'package:ratonight/widgets/ambient_animation.dart';
import 'package:ratonight/widgets/ambient_charasteristic_tile.dart';

class AmbientServiceScreen extends StatefulWidget {
  const AmbientServiceScreen({super.key});

  @override
  State<AmbientServiceScreen> createState() => _AmbientServiceScreenState();
}

class _AmbientServiceScreenState extends State<AmbientServiceScreen> {
  /// Current bluetooth device
  late final BluetoothDevice device;
  late final BluetoothService ambienceService;
  late final BluetoothCharacteristic temperatureCharacteristic;
  late final BluetoothCharacteristic humidityCharacteristic;

  /// Value request timer
  late final Timer requestTimer;

  double? temperature;
  double? humidity;

  /// Request 'ambience' information to device
  void request() async {
    GetIt.I.get<Logger>().i("Requesting ambience information");
    // Read the values from the characteristic
    final temperatureValues = await temperatureCharacteristic.read();
    final humidityValues = await humidityCharacteristic.read();
    GetIt.I
        .get<Logger>()
        .d("Temperature: $temperatureValues\nHumidity: $humidityValues");
    // Parse float bytes into double and set the state
    setState(() {
      temperature = parseFloatBytes(temperatureValues);
      humidity = parseFloatBytes(humidityValues);
    });
    GetIt.I.get<Logger>().i("Temperature: $temperature\nHumidity: $humidity");
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Request when content is available
      GetIt.I.get<Logger>().t("Created: $runtimeType");

      // Get the device
      final provider = context.read<DeviceConnectionProvider>();
      device = provider.currentDevice!;

      // Request the service
      ambienceService = (await provider.deviceServices)!.firstWhere(
        (service) =>
            service.serviceUuid.toString() ==
            EnvironmentUuid.servicesAmbience.uuid,
      );

      GetIt.I.get<Logger>().d(
            "AmbienceService characteristics: ${device.servicesList}",
          );

      // Request the temperature
      temperatureCharacteristic = ambienceService.characteristics.firstWhere(
        (characteristic) =>
            characteristic.characteristicUuid.toString() ==
            EnvironmentUuid.servicesAmbienceTemperature.uuid,
      );

      // Request the humidity
      humidityCharacteristic = ambienceService.characteristics.firstWhere(
        (characteristic) =>
            characteristic.characteristicUuid.toString() ==
            EnvironmentUuid.servicesAmbienceHumidity.uuid,
      );

      request(); // First time request
      // Initialize the timer
      requestTimer = Timer.periodic(
        const Duration(seconds: 30),
        (_) => request(),
      );
    });

    super.initState();
  }

  @override
  void dispose() {
    GetIt.I.get<Logger>().t("Destroyed: $runtimeType");
    // Cancel the timer
    requestTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      (temperature == null || humidity == null)
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.bottomLeft,
              children: [
                LayoutBuilder(
                  builder: (context, constraints) => AmbientAnimation(
                    humidity: humidity!,
                    temperature: temperature!,
                    canvasSize: Size(
                      constraints.maxWidth,
                      constraints.maxHeight,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Card(
                    color:
                        context.colors.scheme.onPrimaryContainer.withAlpha(128),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AmbientCharasteristicTile(
                            value: temperature!,
                            unit: "°C",
                            icon: Icons.thermostat,
                          ),
                          AmbientCharasteristicTile(
                            value: humidity!,
                            unit: "%",
                            icon: Icons.water_drop_rounded,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
}
