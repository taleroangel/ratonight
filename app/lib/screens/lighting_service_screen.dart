import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:ratonight/environment.g.dart';
import 'package:ratonight/provider/device_connection_provider.dart';

class LightingServiceScreen extends StatefulWidget {
  const LightingServiceScreen({super.key});

  @override
  State<LightingServiceScreen> createState() => _LightingServiceScreenState();
}

class _LightingServiceScreenState extends State<LightingServiceScreen> {
  /// Bluetooth device definition
  late final BluetoothDevice device;
  late final BluetoothService lightService;
  late final BluetoothCharacteristic pushCharacteristic;
  late final BluetoothCharacteristic pullCharacteristic;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      GetIt.I.get<Logger>().d("Created: $runtimeType");

      // Request the bluetooth device
      device = context.read<DeviceConnectionProvider>().currentDevice!;

      // Request the service
      lightService = device.servicesList!.firstWhere((service) =>
          service.serviceUuid.toString() == EnvironmentUuid.servicesLight.uuid);

      // Request the push characteristic
      pushCharacteristic = lightService.characteristics.firstWhere(
        (characteristic) =>
            characteristic.characteristicUuid.toString() ==
            EnvironmentUuid.servicesLightPush.uuid,
      );

      // Request the pull characteristic
      pullCharacteristic = lightService.characteristics.firstWhere(
        (characteristic) =>
            characteristic.characteristicUuid.toString() ==
            EnvironmentUuid.servicesLightPull.uuid,
      );
    });
    super.initState();
  }

  @override
  void dispose() {
    GetIt.I.get<Logger>().d("Destroyed: $runtimeType");
    super.dispose();
  }

  void requestStatus() {}

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
