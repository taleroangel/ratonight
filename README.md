# 🏕️ Ratonight
Smart camping night-light using **BLE** (Bluetooth Low-Energy)

## 🏮 Device
### Firmware
Build it and upload it with PlatformIO to an ESP32 board, use _env:DEBUG_ or ```#define DEBUG``` ir order to active Logging through Serial port with 115200 baud

## 📱 Application
Build with Flutter for Android, go to directory _/app_

### 🏗️ Code generation and compilation

The following commands are required before building the application in order to generate static assets:

```sh
flutter pub get
dart run build_runner build
dart run flutter_native_splash:create
dart run icons_launcher:create
```

### Release Build
In order to relese build the app you need to precompile the SKSL shaders, you can use the provided __'flutter_01.sksl.json'__ file or provide your own via the command:
```sh
flutter run --profile --cache-sksl --purge-persistent-cache --dump-skp-on-shader-compilation
```
Trigger as much animations as you can and then press __M__ inside the command-line to export the __'flutter_01.sksl.json'__ file

Then compile the __.apk__ application using the following command
```sh
flutter build apk --obfuscate --split-debug-info=build/app/output/symbols --no-track-widget-creation --release --bundle-sksl-path flutter_01.sksl.json --no-tree-shake-icons -v
```