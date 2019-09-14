/**
 * code taken from https://www.scottbrady91.com/Dart/Generating-a-Crypto-Random-String-in-Dart
 */

import 'dart:convert';
import 'dart:math';

class Utils {
  static const WALLTHICKNESS = 2.0;

  static final Random _random = Random.secure();

  static String createCryptoRandomString([int length = 32]) {
    var values = List<int>.generate(length, (i) => _random.nextInt(256));

    return base64Url.encode(values);
  }
}
