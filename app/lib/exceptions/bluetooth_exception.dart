import 'dart:io';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BluetoothException extends IOException {
  BluetoothException({
    required this.device,
    required this.message,
  }) : super();

  final BluetoothDevice device;
  final String message;

  @override
  String toString() =>
      "$runtimeType: on device '${device.localName}', message: $message\nDevice: $device";
}
