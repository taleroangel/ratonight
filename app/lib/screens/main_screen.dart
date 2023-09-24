import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ratonight/provider/device_connection_provider.dart';
import 'package:ratonight/screens/ambient_service_screen.dart';
import 'package:ratonight/screens/lighting_service_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();

  final paging = const [
    AmbientServiceScreen(),
    LightingServiceScreen(),
  ];
}

class _MainScreenState extends State<MainScreen> {
  /// Currently selected page
  int currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    // Grab the device
    final device = context.read<DeviceConnectionProvider>().currentDevice!;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
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
          ),
        ],
      ),
      body: Center(
        child: FutureBuilder(
          future: context.read<DeviceConnectionProvider>().deviceServices,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return widget.paging[currentPageIndex];
            } else {
              return const CircularProgressIndicator();
            }
          },
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        useLegacyColorScheme: false,
        currentIndex: currentPageIndex,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.thermostat_rounded),
            label: "Ambient",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.lightbulb),
            label: "Light",
          ),
        ],
        onTap: (value) => setState(() {
          currentPageIndex = value;
        }),
      ),
    );
  }
}
