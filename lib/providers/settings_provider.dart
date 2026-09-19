import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class SettingsProvider extends ChangeNotifier {
  final StorageService _storage = StorageService();

  bool _isPresentationMode = false;
  bool _isDemoMode = true;

  bool get isPresentationMode => _isPresentationMode;
  bool get isDemoMode => _isDemoMode;

  SettingsProvider() {
    _loadSettings();
  }

  void _loadSettings() {
    _isPresentationMode = _storage.isPresentationMode();
    _isDemoMode = _storage.isDemoMode();
    notifyListeners();
  }

  Future<void> togglePresentationMode(bool value) async {
    _isPresentationMode = value;
    await _storage.setPresentationMode(value);
    notifyListeners();
  }

  Future<void> toggleDemoMode(bool value) async {
    _isDemoMode = value;
    await _storage.setDemoMode(value);
    notifyListeners();
  }

  Future<void> resetAllData() async {
    await _storage.resetToDefaults();
    _loadSettings();
  }
}
