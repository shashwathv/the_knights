import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider with ChangeNotifier {
  static const String _languageKey = 'language';
  late SharedPreferences _prefs;
  bool _isEnglish = true;

  LanguageProvider() {
    _loadLanguage();
  }

  bool get isEnglish => _isEnglish;

  Future<void> _loadLanguage() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      _isEnglish = _prefs.getString(_languageKey) != 'kn';
      notifyListeners();
    } catch (e) {
      print('Error loading language preference: $e');
    }
  }

  Future<void> setLanguage(String languageCode) async {
    try {
      await _prefs.setString(_languageKey, languageCode);
      _isEnglish = languageCode != 'kn';
      notifyListeners();
    } catch (e) {
      print('Error saving language preference: $e');
    }
  }

  bool get isKannada => !_isEnglish;

  void toggleLanguage() {
    _isEnglish = !_isEnglish;
    notifyListeners();
  }
} 