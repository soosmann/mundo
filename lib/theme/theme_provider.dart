import 'package:flutter/material.dart';
import 'package:mundo/theme/theme.dart';

/// class that provides theme to the app and triggers theme changes
class ThemeProvider with ChangeNotifier {
  ThemeData _themeData = lightMode;

  ThemeData get themeData => _themeData;
  
  set themeData (ThemeData themeData) {
    _themeData = themeData;
    notifyListeners();
  }
  
  /// change theme from light to dark and vice versa
  void toggleTheme() {
    if (_themeData == lightMode) {
      themeData = darkMode;
    }else{
      themeData = lightMode;
    }
  }
}