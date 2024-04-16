import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:ratonight/environment.g.dart';

/// Check if a device is valid for connection
bool isValidDevice(ScanResult result) =>
    ((result.advertisementData.serviceUuids.singleOrNull?.str ?? "") ==
        EnvironmentUuid.device.uuid);
