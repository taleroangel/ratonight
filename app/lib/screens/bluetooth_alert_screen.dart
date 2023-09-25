import 'package:awesome_flutter_extensions/awesome_flutter_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:ratonight/screens/about_screen.dart';
import 'package:ratonight/widgets/bluetooth_icon.dart';

/// Show a Bluetooth logo with an alert indicating the adapter state
class BluetoothAlertScreen extends StatelessWidget {
  const BluetoothAlertScreen(
      {required this.text,
      this.state = BluetoothAdapterState.unknown,
      this.actions = const [],
      super.key});
  final String text;
  final BluetoothAdapterState state;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Stack(
          children: [
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: FilledButton.tonalIcon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const AboutScreen(),
                    ),
                  ),
                  icon: const Icon(Icons.help),
                  label: const Text("About"),
                ),
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(64.0),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    BluetoothIcon(
                      size: 42.0,
                      state: state,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        text,
                        style: context.themes.text.displaySmall,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox.square(
                      dimension: 24.0,
                    ),
                    ...actions
                  ],
                ),
              ),
            ),
          ],
        ),
      );
}
