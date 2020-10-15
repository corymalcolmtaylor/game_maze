import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

final theme = ThemeData(
  textTheme: GoogleFonts.robotoTextTheme().copyWith(
    headline1: const TextStyle(fontSize: 30),
    headline2: const TextStyle(fontSize: 28),
    headline3: const TextStyle(fontSize: 26),
    headline4: const TextStyle(fontSize: 24),
    headline5: const TextStyle(fontSize: 22),
    headline6: const TextStyle(fontSize: 18),
    bodyText1: const TextStyle(
      fontSize: 24,
      color: Colors.cyanAccent,
    ),
    bodyText2: const TextStyle(
      fontSize: 22,
    ),
  ),
  brightness: Brightness.dark,
  primaryColorDark: const Color(0xFF0097A7),
  primaryColorLight: const Color(0xFFB2EBF2),
  primaryColor: const Color(0xFF00BCD4),
  accentColor: const Color(0xFF009688),
  scaffoldBackgroundColor: const Color(0x00000000),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  ),
);
