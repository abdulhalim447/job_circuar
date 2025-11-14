import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:job_circular/models/appsettings.dart';

class SettingsProvider extends ChangeNotifier {
  Box<Appsettings>? _settingsBox;
  Box<Appsettings> get settingsBox {
    _settingsBox ??= Hive.box<Appsettings>('settings');
    return _settingsBox!;
  }

  bool _isDarkMode = false;

  SettingsProvider() {
    // Delay initialization to ensure Hive boxes are open
    Future.microtask(() {
      _loadSettings();
    });
  }

  bool get isDarkMode => _isDarkMode;

  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  void _loadSettings() {
    try {
      if (settingsBox.isNotEmpty) {
        final settings = settingsBox.getAt(0);
        if (settings is Appsettings) {
          _isDarkMode = settings.dark;
          notifyListeners();
        }
      }
    } catch (e) {
      print('Error loading settings: $e');
    }
  }

  void toggleDarkMode() {
    _isDarkMode = !_isDarkMode;
    _saveSettings();
    notifyListeners();
  }

  void setDarkMode(bool value) {
    if (_isDarkMode != value) {
      _isDarkMode = value;
      _saveSettings();
      notifyListeners();
    }
  }

  void _saveSettings() {
    try {
      if (settingsBox.isEmpty) {
        settingsBox.add(Appsettings(dark: _isDarkMode));
      } else {
        settingsBox.putAt(0, Appsettings(dark: _isDarkMode));
      }
    } catch (e) {
      print('Error saving settings: $e');
    }
  }
}
