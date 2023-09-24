import 'package:permission_handler/permission_handler.dart';

/// Request all permissions
Future<bool> requestPermissions() async => (await [
      Permission.location,
      Permission.bluetooth,
      Permission.bluetoothConnect,
      Permission.bluetoothScan
    ].request())
        .values
        .every((element) => element.isGranted);
