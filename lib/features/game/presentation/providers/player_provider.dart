// lib/features/game/presentation/providers/player_setup_provider.dart
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class PlayerSetupProvider extends ChangeNotifier {
  int _selectedPlayerCount = 2;
  final List<String> _playerNames = List.filled(6, '');
  final List<String?> _selectedColors = List.filled(6, null);
  bool _isValidating = false;

  // Available colors
  final List<Color> availableColors = [
    const Color(0xFF000000), // Black
    const Color(0xFF2196F3), // Blue
    const Color(0xFFFF4081), // Pink
    const Color(0xFF9C27B0), // Purple
    const Color(0xFF4CAF50), // Green
    const Color(0xFFFFEB3B), // Yellow
  ];

  // Getters
  int get selectedPlayerCount => _selectedPlayerCount;

  List<String> get playerNames => _playerNames;

  List<String?> get selectedColors => _selectedColors;

  bool get isValidating => _isValidating;

  void setPlayerCount(int count) {
    _selectedPlayerCount = count;

    // Clear data for unused players
    for (int i = count; i < 6; i++) {
      _playerNames[i] = '';
      _selectedColors[i] = null;
    }

    notifyListeners();
  }

  void setPlayerName(int index, String name) {
    if (index < _playerNames.length) {
      _playerNames[index] = name;
      notifyListeners();
    }
  }

  void setPlayerColor(int index, Color color) {
    if (index < _selectedColors.length) {
      final colorHex = '#${color.value.toRadixString(16).substring(2)}';
      _selectedColors[index] = colorHex;
      notifyListeners();
    }
  }

  bool isColorUnique(Color color, int currentIndex) {
    final colorHex = '#${color.value.toRadixString(16).substring(2)}';
    for (int i = 0; i < _selectedPlayerCount; i++) {
      if (i != currentIndex && _selectedColors[i] == colorHex) {
        return false;
      }
    }
    return true;
  }

  bool isNameValid(String name) {
    return name.trim().isNotEmpty;
  }

  bool isNameUnique(String name, int currentIndex) {
    for (int i = 0; i < _selectedPlayerCount; i++) {
      if (i != currentIndex &&
          _playerNames[i].trim().toLowerCase() == name.trim().toLowerCase()) {
        return false;
      }
    }
    return true;
  }

  String? validatePlayerName(String name, int index) {
    if (!isNameValid(name)) {
      return 'Name cannot be empty';
    }
    if (!isNameUnique(name, index)) {
      return 'Name must be unique';
    }
    return null;
  }

  List<String> getValidPlayerNames() {
    final validNames = <String>[];
    for (int i = 0; i < _selectedPlayerCount; i++) {
      final name = _playerNames[i].trim();
      if (isNameValid(name) && isNameUnique(name, i)) {
        validNames.add(name);
      }
    }
    return validNames;
  }

  List<String> getValidPlayerColors() {
    final validColors = <String>[];
    for (int i = 0; i < _selectedPlayerCount; i++) {
      final color = _selectedColors[i];
      if (color != null) {
        validColors.add(color);
      }
    }
    return validColors;
  }

  bool canStartGame() {
    final validNames = getValidPlayerNames();
    final validColors = getValidPlayerColors();
    return validNames.length >= 2 &&
        validNames.length == validColors.length &&
        validNames.length == _selectedPlayerCount;
  }

  void reset() {
    _selectedPlayerCount = 2;
    for (int i = 0; i < 6; i++) {
      _playerNames[i] = '';
      _selectedColors[i] = null;
    }
    _isValidating = false;
    notifyListeners();
  }
}
