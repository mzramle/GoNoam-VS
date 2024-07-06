import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../api/api.dart';
import '../helper/my_dialog.dart';
import '../model/languages_list_model.dart';
import '../model/translation_model.dart';

enum Status { none, loading, complete }

class TranslateProvider with ChangeNotifier {
  final textC = TextEditingController();
  final resultC = TextEditingController();

  String _from = '';
  String get from => _from;
  set from(String value) {
    _from = value;
    notifyListeners();
  }

  String _to = '';
  String get to => _to;
  set to(String value) {
    _to = value;
    notifyListeners();
  }

  Status _status = Status.none;
  Status get status => _status;
  set status(Status value) {
    _status = value;
    notifyListeners();
  }

  String _sourceCountry = '';
  String get sourceCountry => _sourceCountry;
  set sourceCountry(String value) {
    _sourceCountry = value;
    notifyListeners();
  }

  String _targetCountry = '';
  String get targetCountry => _targetCountry;
  set targetCountry(String value) {
    _targetCountry = value;
    notifyListeners();
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> translate() async {
    if (textC.text.trim().isNotEmpty && to.isNotEmpty) {
      status = Status.loading;

      String prompt = '';

      if (from.isNotEmpty) {
        prompt =
            'Can you translate given text from $from to $to:\n${textC.text}';
      } else {
        prompt = 'Can you translate given text to $to:\n${textC.text}';
      }

      final res = await APIs.getAnswer(prompt);
      resultC.text = utf8.decode(res.codeUnits);

      // Save translation to Firebase
      await _saveTranslationToFirebase(
        originalText: textC.text,
        translatedText: resultC.text,
        sourceLanguage: from,
        targetLanguage: to,
        sourceCountry: sourceCountry,
        targetCountry: targetCountry,
      );

      status = Status.complete;
    } else {
      status = Status.none;
      if (to.isEmpty) MyDialog.info('Select To Language!');
      if (textC.text.isEmpty) MyDialog.info('Type Something to Translate!');
    }
  }

  Future<void> _saveTranslationToFirebase({
    required String originalText,
    required String translatedText,
    required String sourceLanguage,
    required String targetLanguage,
    required String sourceCountry,
    required String targetCountry,
  }) async {
    try {
      final translation = TranslationModel(
        originalText: originalText,
        translatedText: translatedText,
        sourceLanguage: sourceLanguage,
        targetLanguage: targetLanguage,
        sourceCountry: sourceCountry,
        targetCountry: targetCountry,
        creationTime: DateTime.now(),
      );

      await _firestore
          .collection('history_translation')
          .add(translation.toMap());
    } catch (e) {
      if (kDebugMode) {
        print('Error saving translation: $e');
      }
    }
  }

  void swapLanguages() {
    if (to.isNotEmpty && from.isNotEmpty) {
      final temp = to;
      to = from;
      from = temp;

      final tempCountry = sourceCountry;
      sourceCountry = targetCountry;
      targetCountry = tempCountry;

      final tempText = textC.text;
      textC.text = resultC.text;
      resultC.text = tempText;
    }
  }

  void autoDetectSourceLanguage() {
    final detectedLanguage = detectLanguage(textC.text);
    if (detectedLanguage.isNotEmpty) {
      from = detectedLanguage;
    }
  }

  String detectLanguage(String text) {
    return text.isEmpty ? '' : 'en';
  }

  Future<void> googleTranslate() async {
    if (textC.text.trim().isNotEmpty && to.isNotEmpty) {
      status = Status.loading;

      resultC.text = await APIs.googleTranslate(
          from: jsonLang[from] ?? 'auto',
          to: jsonLang[to] ?? 'en',
          text: textC.text);

      await _saveTranslationToFirebase(
        originalText: textC.text,
        translatedText: resultC.text,
        sourceLanguage: from,
        targetLanguage: to,
        sourceCountry: sourceCountry,
        targetCountry: targetCountry,
      );

      status = Status.complete;
    } else {
      status = Status.none;
      if (to.isEmpty) MyDialog.info('Select To Language!');
      if (textC.text.isEmpty) {
        MyDialog.info('Type Something to Translate!');
      }
    }
  }

  late final lang = jsonLang.keys.toList();
}
