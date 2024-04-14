import 'package:flutter/material.dart';

/// MiMundo light mode theme
ThemeData lightMode = ThemeData( 
  useMaterial3: true,
  brightness: Brightness.light,
  colorScheme: ColorScheme.light(
    background: Colors.grey.shade100, 
    primary: Colors.grey.shade200,
    secondary: Colors.grey.shade300,
    tertiary: Colors.grey.shade500,
  ),
  textTheme: const TextTheme(
    labelLarge: TextStyle(
      color: Colors.black
    ),
  ),
  buttonTheme: ButtonThemeData(
    colorScheme: ColorScheme.light(
      primary: Colors.grey.shade300,
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.grey.shade300,
    hintStyle: const TextStyle(
      color: Colors.black
    ),
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    foregroundColor: Colors.black,
    backgroundColor: Colors.grey.shade300,
  )
);

/// MiMundo dark mode theme
ThemeData darkMode = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark, 
  colorScheme: ColorScheme.dark(
    background: Colors.grey.shade900, 
    primary: Colors.grey.shade800,
    secondary: Colors.grey.shade700,
    tertiary: Colors.grey.shade500,
  ),
  textTheme: const TextTheme(
    labelLarge: TextStyle(
      color: Colors.white
    ),
  ),
  buttonTheme: ButtonThemeData(
    colorScheme: ColorScheme.dark(
      primary: Colors.grey.shade700,
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.grey.shade700,
    hintStyle: const TextStyle(
      color: Colors.white
    ),
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    foregroundColor: Colors.white,
    backgroundColor: Colors.grey.shade700,
  )
);