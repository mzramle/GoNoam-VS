import 'package:flutter/material.dart';
import '../model/languages_list_model.dart';

class LanguageProvider with ChangeNotifier {
  final List<String> languages = jsonLang.keys.toList();

  String _chosenLanguage = "English";
  String get chosenLanguage => _chosenLanguage;

  void setChosenLanguage(String language) {
    _chosenLanguage = language;
    notifyListeners();
  }
}
