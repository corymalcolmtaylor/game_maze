/// code taken from https://www.scottbrady91.com/Dart/Generating-a-Crypto-Random-String-in-Dart

import 'dart:convert';
import 'dart:math';

class Utils {
  static const WALLTHICKNESS = 1.0;
  static const EASY = 'Easy';
  static const HARD = 'Hard';
  static const TITLE = 'Alice and the Hedge Maze';
  static const TITLE_ios = 'Alice and the\nHedge Maze';
  static const animDurationMilliSeconds = 700;

  static final Random _random = Random.secure();

  static String createCryptoRandomString([int length = 32]) {
    var values = List<int>.generate(length, (i) => _random.nextInt(256));
    return base64Url.encode(values);
  }
}
