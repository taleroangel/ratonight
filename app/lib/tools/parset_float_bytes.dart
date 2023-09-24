import 'dart:typed_data';

/// Parse float bytes (IEEE 754) into a [double]
double parseFloatBytes(List<int> bytes) =>
    ByteData.sublistView(Uint8List.fromList(bytes))
        .getFloat32(0, Endian.little);
