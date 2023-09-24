import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:ratonight/exceptions/bluetooth_exception.dart';

class CharacteristicException extends BluetoothException {
  CharacteristicException(
      {required super.device,
      required this.characteristic,
      required super.message});

  final BluetoothCharacteristic characteristic;
}
