import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_hsvcolor_picker/flutter_hsvcolor_picker.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:ratonight/environment.g.dart';
import 'package:ratonight/exceptions/characteristic_exception.dart';
import 'package:ratonight/provider/application_color_provider.dart';
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

  // Should animate the transition
  bool shouldAnimateTransition = false;

  /// Current colors being shown in the device
  List<HSVColor>? colors;

  void syncColorWithApplication() {
    // Set the application color
    context.read<ApplicationColorProvider>().color =
        LightServiceUtils.averageColor(colors!);
  }

  /// Fetch the Bluetooth initial data
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      GetIt.I.get<Logger>().t("Created: $runtimeType");

      // Get the device
      final provider = context.read<DeviceConnectionProvider>();
      device = provider.currentDevice!;

      // Request the service
      lightService = (await provider.deviceServices)!.firstWhere((service) =>
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

      // Get the content and set the color
      pullContent();
    });

    super.initState();
  }

  @override
  void dispose() {
    GetIt.I.get<Logger>().t("Destroyed: $runtimeType");
    super.dispose();
  }

  /// Fetch the color content from the device
  Future<void> pullContent() async {
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
        // Create animation for new value
        shouldAnimateTransition = true;
        // New colors
        colors = hslcolors;
        // If all colors are equial set 'selectColorsIndividually' to false
        selectColorsIndividually = !(colors!.every(
          (element) => (element == colors!.first),
        ));
      });
    } on FlutterBluePlusException catch (_) {
      // On characteristic read throw an exception
      throw CharacteristicException(
          device: null,
          characteristic: pullCharacteristic,
          message: "During 'pullContent' on $runtimeType");
    }

    syncColorWithApplication();
  }

  /// Push values into device
  Future<void> pushContent() async {
    GetIt.I
        .get<Logger>()
        .t("Selected color value: ${colors![currentlySelectedColorIndex]}");

    // If every color is the same then apply to all elements
    if (colors!.every((element) => element == colors!.first)) {
      // Get the color bytes
      final bytes = LightServiceUtils.colorsToByte(true,
          currentlySelectedColorIndex, colors![currentlySelectedColorIndex]);

      try {
        // Push the value to device
        await pushCharacteristic.write(bytes);
        GetIt.I.get<Logger>().i("Pushed light values to device");
      } on FlutterBluePlusException catch (_) {
        // On characteristic read throw an exception
        throw CharacteristicException(
            device: null,
            characteristic: pullCharacteristic,
            message: "During 'pushContent' on $runtimeType");
      }
    } else {
      // Push every value to the device
      try {
        // Push the value to device
        await Future.wait(colors!.asMap().map((index, color) {
          // Get the color bytes
          final bytes = LightServiceUtils.colorsToByte(
            false,
            index,
            color,
          );

          // Return the bytes
          return MapEntry(index, pushCharacteristic.write(bytes));
        }).values);

        GetIt.I.get<Logger>().i("Pushed light values to device");
      } on FlutterBluePlusException catch (_) {
        // On characteristic read throw an exception
        throw CharacteristicException(
            device: null,
            characteristic: pullCharacteristic,
            message: "During 'pushContent' on $runtimeType");
      }
    }

    syncColorWithApplication();
  }

  /// Call when value is changed
  void onColorChangeCallback(HSVColor color) {
    // Set new application state
    setState(() {
      // Do not animate transition (causes lag)
      shouldAnimateTransition = false;

      // Change the actual color
      if (selectColorsIndividually) {
        // Set the individual color
        colors![currentlySelectedColorIndex] = color;
      } else {
        // Set all colors
        colors = List.filled(colors!.length, color);
      }
    });
  }

  /// Turn off the light
  void reduceLevel() {
    GetIt.I.get<Logger>().i("LIGHT OFF - Reduce Level");
    // Reduce the Value of every color
    setState(() {
      shouldAnimateTransition = true;
      selectColorsIndividually = false;
      colors = List.filled(
        colors!.length,
        colors![currentlySelectedColorIndex].withValue(0.0),
      );
    });

    // Push changes
    pushContent();
  }

  /// Turn on the light to maximum levels
  void increaseLevel() {
    GetIt.I.get<Logger>().i("LIGHT ON - Increase Level");
    // Reduce the Value of every color
    setState(() {
      shouldAnimateTransition = true;
      selectColorsIndividually = false;
      colors = List.filled(
        colors!.length,
        colors![currentlySelectedColorIndex].withValue(1.0),
      );
    });
    // Push changes
    pushContent();
  }

  @override
  Widget build(BuildContext context) {
    return (colors == null)
        ? const Center(child: CircularProgressIndicator())
        : Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Select individually toggle
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text("Select individually"),
                      Switch(
                        value: selectColorsIndividually,
                        onChanged: (value) => setState(
                          () => (selectColorsIndividually = value),
                        ),
                      )
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
                                      animationLength:
                                          shouldAnimateTransition ? 400 : 0,
                                      key: ValueKey(e.key),
                                      color: e.value.toColor(),
                                      selected: (e.key ==
                                              currentlySelectedColorIndex) &&
                                          selectColorsIndividually,
                                      onTap: () => setState(() {
                                        // Set the current index
                                        currentlySelectedColorIndex = e.key;
                                      }),
                                    ))
                                .toList(),
                          ),
                        ),
                      ),
                      // Action buttons
                      Padding(
                        padding: const EdgeInsets.only(top: 24.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            IconButton.filledTonal(
                              onPressed: () => reduceLevel(),
                              icon: const Icon(Icons.lightbulb_outline),
                            ),
                            IconButton.filled(
                              onPressed: () => pullContent(),
                              icon: const Icon(Icons.replay_rounded),
                            ),
                            FilledButton.icon(
                              onPressed: () => pushContent(), // Push to device
                              icon: const Icon(Icons.light),
                              label: const Text("Update"),
                            ),
                            IconButton.filledTonal(
                              onPressed: () => increaseLevel(),
                              icon: const Icon(Icons.lightbulb),
                            ),
                          ],
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
}
