import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ThemeProvider extends ChangeNotifier {
  static final seedColor = Colors.primaries[Random().nextInt(Colors.primaries.length)];
  static final DynamicSchemeVariant dynamicSchemeVariant = DynamicSchemeVariant.rainbow;
  static final textTheme = GoogleFonts.ralewayTextTheme();

  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  void toggleTheme(bool isDark) {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  static final lightTheme = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: seedColor,
      dynamicSchemeVariant: dynamicSchemeVariant,
    ),
    textTheme: textTheme,
  );

  static final darkTheme = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.dark,
      dynamicSchemeVariant: dynamicSchemeVariant,
    ),
    textTheme: textTheme,
  );
}
