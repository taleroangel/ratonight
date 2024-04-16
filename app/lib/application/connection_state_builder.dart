import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:provider/provider.dart';
import 'package:ratonight/provider/device_connection_provider.dart';
import 'package:ratonight/screens/device_disconnected_screen.dart';
import 'package:ratonight/screens/device_selection_screen.dart';
import 'package:ratonight/screens/main_screen.dart';

/// Show a list of available devices to connect, when connection is completed shows main screen
class ConnectionStateBuilder extends StatelessWidget {
  const ConnectionStateBuilder({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DeviceConnectionProvider>();
    return (provider.currentDevice == null)
        ? const DeviceSelectionScreen()
        : StreamBuilder(
            stream: provider.currentDevice!.connectionState,
            initialData: BluetoothConnectionState.disconnected,
            builder: (context, snapshot) => switch (snapshot.data!) {
              BluetoothConnectionState.disconnected =>
                const DeviceDisconnectedScreen(),
              BluetoothConnectionState.connected => const MainScreen(),
              _ =>
                throw TypeError() // Should never be in another state since other states are deprecated
            }, // When connected
          );
  }
}
