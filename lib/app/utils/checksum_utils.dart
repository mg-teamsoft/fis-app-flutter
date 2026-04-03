import 'dart:convert';
import 'dart:typed_data';

String crc32Base64(Uint8List bytes) {
  const poly = 0xEDB88320;
  final table = List<int>.generate(256, (i) {
    var c = i;
    for (var j = 0; j < 8; j++) {
      c = (c & 1) != 0 ? (poly ^ (c >> 1)) : (c >> 1);
    }
    return c;
  });

  var crc = 0xFFFFFFFF;
  for (final b in bytes) {
    crc = (crc >> 8) ^ table[(crc ^ b) & 0xFF];
  }
  crc = crc ^ 0xFFFFFFFF;

  final buff = ByteData(4)..setUint32(0, crc);
  return base64Encode(buff.buffer.asUint8List());
}
