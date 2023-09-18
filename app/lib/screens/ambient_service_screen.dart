import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:ratonight/environment.g.dart';
import 'package:ratonight/provider/device_connection_provider.dart';
import 'package:ratonight/tools/parset_float_bytes.dart';

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
    // Parse float bytes into double
    temperature = parseFloatBytes(temperatureValues);
    humidity = parseFloatBytes(humidityValues);
    GetIt.I.get<Logger>().i("Temperature: $temperature\nHumidity: $humidity");
  }

  @override
  void initState() {
    // Request when contect is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      GetIt.I.get<Logger>().d("Created: $runtimeType");
      // Request the bluetooth device
      device = context.read<DeviceConnectionProvider>().currentDevice!;

      // Request the service
      ambienceService = device.servicesList!.firstWhere(
        (service) =>
            service.serviceUuid.toString() ==
            EnvironmentUuid.servicesAmbience.uuid,
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
    GetIt.I.get<Logger>().d("Destroyed: $runtimeType");
    // Cancel the timer
    requestTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
