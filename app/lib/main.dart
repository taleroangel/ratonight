import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:ratonight/application/bluetooth_application.dart';
import 'package:ratonight/provider/device_connection_provider.dart';

void main() {
  // Dependency injection registration
  GetIt.I.registerSingleton<Logger>(
    Logger(printer: PrettyPrinter()),
  );

  // Run the application
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider<DeviceConnectionProvider>(
        create: (context) => DeviceConnectionProvider(),
      ),
    ],
    builder: (context, child) => const Application(),
  ));
}

class Application extends StatelessWidget {
  const Application({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ratonight',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const BluetoothApplication(),
    );
  }
}
