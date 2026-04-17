import 'dart:typed_data';

import 'package:crypto/crypto.dart';

String crytoSHA256Hex(Uint8List bytes) => sha256.convert(bytes).toString();
