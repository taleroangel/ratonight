import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:ratonight/application/bluetooth_application.dart';

void main() {
  // Dependency injection registration
  GetIt.I.registerSingleton<Logger>(
    Logger(printer: PrettyPrinter()),
  );

  // Run the application
  runApp(const Application());
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
