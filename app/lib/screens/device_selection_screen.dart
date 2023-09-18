import 'package:awesome_flutter_extensions/awesome_flutter_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:provider/provider.dart';
import 'package:ratonight/provider/device_connection_provider.dart';
import 'package:ratonight/widgets/bluetooth_device_tile.dart';

/// Show a list of available devices to connect to
class DeviceSelectionScreen extends StatefulWidget {
  const DeviceSelectionScreen({super.key});

  @override
  State<DeviceSelectionScreen> createState() => _DeviceSelectionScreenState();
}

class _DeviceSelectionScreenState extends State<DeviceSelectionScreen> {
  @override
  void initState() {
    FlutterBluePlus.startScan();
    super.initState();
  }

  @override
  void dispose() {
    FlutterBluePlus.stopScan();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text("Device connection"),
        ),
        body: StreamBuilder(
          stream: FlutterBluePlus.scanResults,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              // Filter devices
              final devices = snapshot.data!
                  // Filter by Bluetooth LE and non-empty name
                  .where((element) => (element.advertisementData.connectable &&
                      element.advertisementData.localName.isNotEmpty))
                  .toList()
                // Sort by RSSI intensity
                ..sort(
                  (a, b) => (-1) * a.rssi.compareTo(b.rssi),
                );

              // Build list of devices
              return ListView.separated(
                itemCount: devices.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) => BluetoothDeviceTile(
                  result: devices[index],
                  onDeviceSelection: (device) {
                    // Currently selected device
                    context.read<DeviceConnectionProvider>().currentDevice =
                        device;
                  },
                ),
              );
            } else {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        "Loading available devices",
                        textAlign: TextAlign.center,
                        style: context.themes.text.bodyLarge,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 64.0),
                      child: LinearProgressIndicator(),
                    )
                  ],
                ),
              );
            }
          },
        ),
      );
}
