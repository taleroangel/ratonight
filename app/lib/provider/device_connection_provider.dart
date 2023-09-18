import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';

class DeviceConnectionProvider extends ChangeNotifier {
  /// Stores the [BluetoothDevice.connect] future result
  Future<void> connectionRequestFinished = Future.value();

  /// Stores the current device services
  Future<List<BluetoothService>>? deviceServices;

  /// Currently selected device
  BluetoothDevice? _currentDevice;

  BluetoothDevice? get currentDevice => _currentDevice;
  set currentDevice(BluetoothDevice? device) {
    // If new device is null, try disconnect first
    if (device == null) {
      _currentDevice?.disconnect();
    }
    // Set the value
    _currentDevice = device;
    // Attempt connection to device
    if (_currentDevice != null) {
      // Connect to the device
      connectionRequestFinished = _currentDevice!.connect()
        // Discover services when connected
        ..then((value) => deviceServices = _currentDevice!.discoverServices()
          // Discover services logging
          ..then((value) {
            GetIt.I
                .get<Logger>()
                .i("${value.length} services where discovered");
          }).catchError((error) {
            GetIt.I.get<Logger>().e("Error during service discovery: $error");
          }))
        // Log values when connected
        ..then((_) {
          GetIt.I.get<Logger>().i("Connected to device");
        }).onError((FlutterBluePlusException error, stacktrace) {
          GetIt.I
              .get<Logger>()
              .e("Error during connection: $error\n$stacktrace");
        });
    }
    notifyListeners();
  }
}
