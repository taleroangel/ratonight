import 'package:awesome_flutter_extensions/awesome_flutter_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BluetoothIcon extends StatelessWidget {
  const BluetoothIcon(
      {required this.size,
      this.state = BluetoothAdapterState.unknown,
      super.key});
  final double size;
  final BluetoothAdapterState state;

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: context.colors.scheme.primary,
        ),
        child: Padding(
          padding: EdgeInsets.all(size / 3),
          child: Icon(
            switch (state) {
              BluetoothAdapterState.unknown => Icons.bluetooth_rounded,
              BluetoothAdapterState.off ||
              BluetoothAdapterState.turningOff ||
              BluetoothAdapterState.unavailable ||
              BluetoothAdapterState.unauthorized =>
                Icons.bluetooth_disabled_rounded,
              BluetoothAdapterState.turningOn =>
                Icons.bluetooth_connected_rounded,
              BluetoothAdapterState.on => Icons.bluetooth_audio_rounded,
            },
            color: context.colors.scheme.onPrimary,
            size: size,
          ),
        ),
      );
}
