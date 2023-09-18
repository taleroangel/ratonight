import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ratonight/provider/device_connection_provider.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Grab the device
    final device = context.read<DeviceConnectionProvider>().currentDevice!;

    return Scaffold(
      appBar: AppBar(
        title: Text(device.localName),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: IconButton.outlined(
              icon: const Row(
                children: [
                  Icon(Icons.outlet),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.0),
                    child: Text("Disconnect"),
                  )
                ],
              ),
              onPressed: () => device.disconnect(),
            ),
          )
        ],
      ),
      body: Center(
        child: FutureBuilder(
          future: context.read<DeviceConnectionProvider>().deviceServices,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return Text(snapshot.data!.toString());
            } else {
              return const CircularProgressIndicator();
            }
          },
        ),
      ),
    );
  }
}
