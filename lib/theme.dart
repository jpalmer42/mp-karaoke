import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MyTheme {
  ThemeData buildTheme(BuildContext context) {
    return theme;
  }

  ThemeData get theme {
    final textTheme = TextTheme(
      // ========================================
      headlineLarge: GoogleFonts.kronaOne(),
      headlineMedium: GoogleFonts.kronaOne(),
      headlineSmall: GoogleFonts.kronaOne(),
      // ========================================
      displayLarge: GoogleFonts.kronaOne(),
      displayMedium: GoogleFonts.kronaOne(),
      displaySmall: GoogleFonts.kronaOne(),
      // ========================================
      titleLarge: GoogleFonts.audiowide(),
      titleMedium: GoogleFonts.audiowide(),
      titleSmall: GoogleFonts.audiowide(),
      // ========================================
      labelLarge: GoogleFonts.kronaOne(),
      labelMedium: GoogleFonts.kronaOne(),
      labelSmall: GoogleFonts.kronaOne(),
      // ========================================
      // bodyLarge: GoogleFonts.kronaOne(),
      // bodyMedium: GoogleFonts.kronaOne(),
      // bodySmall: GoogleFonts.kronaOne(),
      // ========================================
    );

    ThemeData response = ThemeData(
      useMaterial3: true,
      colorSchemeSeed: Colors.red,
      brightness: Brightness.dark,
      textTheme: textTheme,
      //
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(4)),
          borderSide: BorderSide(width: 1),
        ),
      ),
    );

    response = response.copyWith(
      //
      dialogTheme: DialogThemeData(
        backgroundColor: response.colorScheme.surface,
        alignment: Alignment.topCenter,
        titleTextStyle: response.textTheme.labelLarge,
        contentTextStyle: response.textTheme.labelMedium,
      ),
    );

    return response;
  }
}
