import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:ratonight/application/bluetooth_state_builder.dart';
import 'package:ratonight/application/connection_state_builder.dart';
import 'package:ratonight/screens/bluetooth_alert_screen.dart';
import 'package:ratonight/tools/request_bluetooth_permissions.dart';

class BluetoothApplication extends StatefulWidget {
  const BluetoothApplication({super.key});

  @override
  State<BluetoothApplication> createState() => _BluetoothApplicationState();
}

class _BluetoothApplicationState extends State<BluetoothApplication> {
  /// Current state of permissions
  late final Future<bool> permissions;

  @override
  void initState() {
    // Initialize asking for permissions
    permissions = requestBluetoothPermissions();
    super.initState();
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<bool>(
        future: permissions,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return snapshot.data!
                ? const BluetoothStateBuilder(
                    onReadyScreen: ConnectionStateBuilder(),
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
