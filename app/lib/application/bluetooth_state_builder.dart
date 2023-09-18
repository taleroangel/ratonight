import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:ratonight/screens/bluetooth_alert_screen.dart';

class BluetoothStateBuilder extends StatelessWidget {
  const BluetoothStateBuilder({required this.onReadyScreen, super.key});
  final Widget onReadyScreen;

  @override
  Widget build(BuildContext context) => StreamBuilder<BluetoothAdapterState>(
        stream: FlutterBluePlus.adapterState.asBroadcastStream(),
        initialData: BluetoothAdapterState.unknown,
        builder: (context, snapshot) => switch (snapshot.data!) {
          // Adapter is in unknown state
          BluetoothAdapterState.unknown => BluetoothAlertScreen(
              text: "Initializing Bluetooth",
              state: snapshot.data!,
              actions: const [CircularProgressIndicator()],
            ),
          // Adapter is Off
          BluetoothAdapterState.off ||
          BluetoothAdapterState.turningOff =>
            BluetoothAlertScreen(
              text: "Bluetooth is Disabled",
              state: snapshot.data!,
              actions: [
                ElevatedButton(
                  onPressed: () => FlutterBluePlus.turnOn(),
                  child: const Text("Enable Bluetooth"),
                ),
              ],
            ),
          // No adapter was found
          BluetoothAdapterState.unauthorized ||
          BluetoothAdapterState.unavailable =>
            BluetoothAlertScreen(
              text: "Failed to use Bluetooth",
              state: snapshot.data!,
              actions: const [
                Text(
                  "A Bluetooth device is required for stablishing a connection",
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          BluetoothAdapterState.turningOn => BluetoothAlertScreen(
              state: snapshot.data!,
              text: "Turning on Bluetooth",
              actions: const [CircularProgressIndicator()],
            ),
          BluetoothAdapterState.on => onReadyScreen,
        },
      );
}
