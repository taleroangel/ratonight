import 'package:awesome_flutter_extensions/awesome_flutter_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:ratonight/tools/is_valid_device.dart';

class BluetoothDeviceTile extends StatelessWidget {
  const BluetoothDeviceTile({
    required this.result,
    required this.onDeviceSelection,
    super.key,
  });

  final ScanResult result;
  final void Function(BluetoothDevice) onDeviceSelection;

  @override
  Widget build(BuildContext context) => ListTile(
        enabled: isValidDevice(result),
        title: Text(result.device.localName),
        subtitle: Text(result.device.remoteId.toString()),
        leading: Column(
          children: [
            Icon(switch (result.rssi) {
              > -60 => Icons.wifi_rounded,
              > -70 => Icons.wifi_2_bar_rounded,
              _ => Icons.wifi_1_bar_rounded,
            }),
            Text(
              "${result.rssi}\nRSSI",
              textAlign: TextAlign.center,
            ),
          ],
        ),
        trailing: isValidDevice(result)
            ? Icon(
                Icons.lightbulb,
                color: context.colors.scheme.primary,
              )
            : null,
        onTap: () => onDeviceSelection(result.device),
        onLongPress: () => showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(result.device.localName),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(result.advertisementData.toString()),
                Text(result.device.toString()),
              ] // Wrap every value in a Card
                  .map((e) => Card(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: e,
                        ),
                      ))
                  .separatedBy(const SizedBox(
                    height: 8.0,
                  )),
            ),
            actions: [
              TextButton(
                onPressed: context.navigator.pop,
                child: const Text("Ok"),
              ),
            ],
          ),
        ),
      );
}
