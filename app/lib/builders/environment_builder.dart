import 'dart:async';
import 'package:build/build.dart';
import 'package:ini/ini.dart';

/// Factory method for creating [EnvironmentBuilder]
Builder environmentBuilder(BuilderOptions options) => EnvironmentBuilder();

/// Builder for parsing environment.ini into Dart constants
class EnvironmentBuilder extends Builder {
  // Read TOML values and parse them
  @override
  FutureOr<void> build(BuildStep buildStep) async {
    // Read file contents
    final contents = await buildStep.readAsString(buildStep.inputId);
    // Parse contents as config
    final config = Config.fromString(contents);
    // Output buffers
    final outputBuffer = StringBuffer("// Generated 'environment.ini' file\n");

    // Transform snake_case with either _ or . into pascalCase
    String snakeCaseToCamelCase(String input) {
      // To PascalCase
      final upperSnakeCase = input
          .split(RegExp(r'[_\.]'))
          .map((word) => word[0].toUpperCase() + word.substring(1))
          .join();
      // To camelCase
      return upperSnakeCase[0].toLowerCase() + upperSnakeCase.substring(1);
    }

    // Write first part of the enum
    outputBuffer.writeln("enum EnvironmentUuid {");

    config.sections().forEach((section) {
      // Get the UUID value
      final uuidValue = config.get(section, "uuid");
      // Write the enum value
      outputBuffer
          .writeln("\t${snakeCaseToCamelCase(section)}(\"$uuidValue\"),");
    });

    // Write bottom part of the enum
    outputBuffer.writeln("\n\t;");
    outputBuffer.writeln("\tfinal String uuid;");
    outputBuffer.writeln("\tconst EnvironmentUuid(this.uuid);");
    outputBuffer.writeln("}");

    // Write output
    await buildStep.writeAsString(
        buildStep.allowedOutputs.first, outputBuffer.toString());
  }

  @override
  Map<String, List<String>> get buildExtensions => const {
        '^assets/{{}}.ini': ['lib/{{}}.g.dart']
      };
}
