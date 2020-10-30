import 'dart:convert';
import 'dart:math';
import 'generated/l10n.dart';

class Utils {
  static const wallThickness = 1.0;
  static const borderWallThickness = 1.3;
  static var easy = S.current.easy;
  static var hard = S.current.hard;
  static var tough = S.current.tough;

  static const animDurationMilliSeconds = 700;

  static final Random _random = Random.secure();

  /// code taken from https://www.scottbrady91.com/Dart/Generating-a-Crypto-Random-String-in-Dart

  static String createCryptoRandomString([int length = 32]) {
    var values = List<int>.generate(length, (i) => _random.nextInt(256));
    return base64Url.encode(values);
  }
}
