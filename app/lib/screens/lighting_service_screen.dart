import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_hsvcolor_picker/flutter_hsvcolor_picker.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:ratonight/environment.g.dart';
import 'package:ratonight/exceptions/characteristic_exception.dart';
import 'package:ratonight/provider/device_connection_provider.dart';
import 'package:ratonight/tools/light_service_utils.dart';
import 'package:ratonight/widgets/color_container.dart';

class LightingServiceScreen extends StatefulWidget {
  const LightingServiceScreen({super.key});

  @override
  State<LightingServiceScreen> createState() => _LightingServiceScreenState();
}

class _LightingServiceScreenState extends State<LightingServiceScreen> {
  /// Bluetooth device definition
  late final BluetoothDevice device;
  late final BluetoothService lightService;
  late final BluetoothCharacteristic pushCharacteristic;
  late final BluetoothCharacteristic pullCharacteristic;

  /// Index of the currently selected color [0-6]
  int currentlySelectedColorIndex = 0;

  /// Select all colors as if they where one
  bool selectColorsIndividually = false;

  /// Previous color for undo action
  List<HSVColor>? previousColor;

  /// Current colors being shown in the device
  List<HSVColor>? colors;

  /// Fetch the Bluetooth initial data
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      GetIt.I.get<Logger>().d("Created: $runtimeType");

      // Request the bluetooth device
      device = context.read<DeviceConnectionProvider>().currentDevice!;

      // Request the service
      lightService = device.servicesList!.firstWhere((service) =>
          service.serviceUuid.toString() == EnvironmentUuid.servicesLight.uuid);

      // Request the push characteristic
      pushCharacteristic = lightService.characteristics.firstWhere(
        (characteristic) =>
            characteristic.characteristicUuid.toString() ==
            EnvironmentUuid.servicesLightPush.uuid,
      );

      // Request the pull characteristic
      pullCharacteristic = lightService.characteristics.firstWhere(
        (characteristic) =>
            characteristic.characteristicUuid.toString() ==
            EnvironmentUuid.servicesLightPull.uuid,
      );

      // Get the content
      pullContent();
    });
    super.initState();
  }

  @override
  void dispose() {
    GetIt.I.get<Logger>().d("Destroyed: $runtimeType");
    super.dispose();
  }

  /// Fetch the color content from the device
  void pullContent() async {
    try {
      // Get bytes from the device
      final bytes = await pullCharacteristic.read();
      GetIt.I.get<Logger>().i("Pulled light values from device");

      // Transform bytes into colors
      GetIt.I.get<Logger>().d("Pulled values (bytes): $bytes");
      final hslcolors = LightServiceUtils.bytesToColors(bytes);

      GetIt.I.get<Logger>().d("Pulled values (hsl): $hslcolors");
      // Set content
      setState(() {
        // New colors
        colors = hslcolors;
        // If all colors are equial set 'selectColorsIndividually' to false
        selectColorsIndividually = !(colors!.every(
          (element) => (element == colors!.first),
        ));
      });
      // Store previous colors
      previousColor = List.unmodifiable(colors!);
    } on FlutterBluePlusException catch (_) {
      // On characteristic read throw an exception
      throw CharacteristicException(
          device: device,
          characteristic: pullCharacteristic,
          message: "During 'pullContent' on $runtimeType");
    }
  }

  /// Push values into device
  Future<void> pushContent() async {
    GetIt.I
        .get<Logger>()
        .d("Selected color value: ${colors![currentlySelectedColorIndex]}");

    // Get the color bytes
    final bytes = LightServiceUtils.colorsToByte(!selectColorsIndividually,
        currentlySelectedColorIndex, colors![currentlySelectedColorIndex]);

    try {
      // Push the value to device
      pushCharacteristic.write(bytes);
      GetIt.I.get<Logger>().i("Pushed light values to device");
    } on FlutterBluePlusException catch (_) {
      // On characteristic read throw an exception
      throw CharacteristicException(
          device: device,
          characteristic: pullCharacteristic,
          message: "During 'pushContent' on $runtimeType");
    }

    // Update if no change was prompted
    if (!selectColorsIndividually) {
      setState(() {
        // Set the individual color
        colors = List.filled(colors!.length, colors!.first);
      });
    }

    // Create a copy of state
    previousColor = List.unmodifiable(colors!);
  }

  /// Call when value is changed
  void onColorChangeCallback(HSVColor color) {
    // Set new application state
    setState(() {
      if (selectColorsIndividually) {
        // Set the individual color
        colors![currentlySelectedColorIndex] = color;
      } else {
        // Set all colors
        colors = List.filled(colors!.length, color);
      }
    });
  }

  @override
  Widget build(BuildContext context) => (colors == null)
      ? const Center(child: CircularProgressIndicator())
      : Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // selectColorsIndividually toggle button
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text("Select individually"),
                    Switch(
                      value: selectColorsIndividually,
                      onChanged: (value) => setState(() {
                        // Undo previous actions
                        colors = List.from(previousColor!);
                        // Set individual value
                        selectColorsIndividually = value;
                      }),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Colors indicators
                    Container(
                      decoration: const BoxDecoration(
                        color: Colors.black12,
                        shape: BoxShape.circle,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Flow(
                          delegate: ColorFlowDelegate(
                            childCount: colors!.length,
                          ),
                          children: colors!
                              .asMap()
                              .entries
                              .map((e) => ColorContainer(
                                    color: e.value.toColor(),
                                    selected: (e.key ==
                                            currentlySelectedColorIndex) &&
                                        selectColorsIndividually,
                                    onTap: () => setState(() {
                                      // Undo previous actions
                                      colors = List.from(previousColor!);
                                      // Set the current index
                                      currentlySelectedColorIndex = e.key;
                                    }),
                                  ))
                              .toList(),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 24.0),
                      child: FilledButton.icon(
                        onPressed: () => pushContent(), // Push to device
                        icon: const Icon(Icons.light),
                        label: const Text("Update"),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32.0,
                  ),
                  child: HSVPicker(
                    color: colors![currentlySelectedColorIndex],
                    onChanged: (value) {
                      // Set the new color
                      onColorChangeCallback(value);
                    },
                  ),
                ),
              ]
                  // Wrap every widget in a padding
                  .map((e) => Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: e,
                      ))
                  .toList(),
            ),
          ),
        );
}
