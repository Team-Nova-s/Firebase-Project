import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ThemeProvider extends ChangeNotifier {
  static final seedColor = Colors.primaries[Random().nextInt(Colors.primaries.length)];
  static final DynamicSchemeVariant dynamicSchemeVariant = DynamicSchemeVariant.rainbow;
  static final textTheme = GoogleFonts.ralewayTextTheme();

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
