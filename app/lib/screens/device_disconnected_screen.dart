import 'package:awesome_flutter_extensions/awesome_flutter_extensions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ratonight/provider/device_connection_provider.dart';

/// Show currently disconnected devices (device is already selected) or
/// Show device as currently connecting
class DeviceDisconnectedScreen extends StatelessWidget {
  const DeviceDisconnectedScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Spacer(),
                  Icon(
                    Icons.lightbulb,
                    color: context.colors.scheme.primary,
                    size: 64.0,
                  ),

                  // Show actions depending on state
                  FutureBuilder(
                    future: context
                        .read<DeviceConnectionProvider>()
                        .connectionRequestFinished,
                    builder: (context, snapshot) {
                      final currentDevice = context
                          .read<DeviceConnectionProvider>()
                          .currentDevice!;
                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              snapshot.connectionState == ConnectionState.done
                                  ? "Not connected to ${currentDevice.platformName}"
                                  : "Connecting to ${currentDevice.platformName}",
                              style: context.themes.text.headlineLarge,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          if (snapshot.connectionState == ConnectionState.done)
                            ElevatedButton(
                                onPressed: () {
                                  context // Set the device again
                                      .read<DeviceConnectionProvider>()
                                      .currentDevice = currentDevice;
                                },
                                child: const Text("Reconnect"))
                          else
                            const CircularProgressIndicator()
                        ],
                      );
                    },
                  ),
                  const Spacer(),

                  // Cancel connection button
                  TextButton(
                    onPressed: () {
                      context.read<DeviceConnectionProvider>().currentDevice =
                          null;
                    },
                    child: const Text("Select other device"),
                  )
                ].separatedBy(const SizedBox(
                  height: 16.0,
                ))),
          ),
        ),
      );
}
