import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ratonight/screens/bluetooth_alert_screen.dart';
import 'package:ratonight/screens/device_selection_screen.dart';

class BluetoothApplication extends StatefulWidget {
  const BluetoothApplication({super.key});

  /// Request all permissions
  Future<bool> requestBluetoothPermissions() async => (await [
        Permission.location,
        Permission.bluetooth,
        Permission.bluetoothConnect,
        Permission.bluetoothScan
      ].request())
          .values
          .every((element) => element.isGranted);

  @override
  State<BluetoothApplication> createState() => _BluetoothApplicationState();
}

class _BluetoothApplicationState extends State<BluetoothApplication> {
  /// Current state of permissions
  late final Future<bool> permissions;

  @override
  void initState() {
    // Initialize asking for permissions
    permissions = widget.requestBluetoothPermissions();
    super.initState();
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<bool>(
        future: permissions,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return snapshot.data!
                ? const BluetoothStateBuilder(
                    onReadyScreen: DeviceSelectionScreen(),
                  )
                : const BluetoothAlertScreen(
                    text: "Missing bluetooth authorization",
                    state: BluetoothAdapterState.unauthorized,
                    actions: [
                      Text(
                        "Bluetooth and Location permissions are required for stablishing a connection",
                        textAlign: TextAlign.center,
                      ),
                    ],
                  );
          } else {
            return const BluetoothAlertScreen(
              text: "Requesting Bluetooth permissions",
              state: BluetoothAdapterState.unavailable,
            );
          }
        },
      );
}

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
