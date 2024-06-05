// import 'package:cloud_firestore/cloud_firestore.dart';

// class TranslationModel {
//   final String id;
//   final String originalText;
//   final String translatedText;
//   bool favorite;

//   TranslationModel({
//     this.id = '',
//     required this.originalText,
//     required this.translatedText,
//     this.favorite = false,
//   });

//   factory TranslationModel.fromDocument(DocumentSnapshot doc) {
//     final data = doc.data() as Map<String, dynamic>;
//     return TranslationModel(
//       id: doc.id,
//       originalText: data['originalText'] ?? '',
//       translatedText: data['translatedText'] ?? '',
//       favorite: data['favorite'] ?? false,
//     );
//   }

//   Map<String, dynamic> toMap() {
//     return {
//       'originalText': originalText,
//       'translatedText': translatedText,
//       'favorite': favorite,
//     };
//   }
// }

// class TranslationService {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   Future<List<TranslationModel>> getTranslationSets() async {
//     try {
//       final querySnapshot = await _firestore.collection('translations').get();
//       return querySnapshot.docs
//           .map((doc) => TranslationModel.fromDocument(doc))
//           .toList();
//     } catch (e) {
//       print('Error fetching translation sets: $e');
//       return [];
//     }
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';

class TranslationModel {
  final String id;
  final String originalText;
  final String translatedText;
  final String sourceLanguage;
  final String targetLanguage;
  final String sourceCountry;
  final String targetCountry;
  final DateTime creationTime;
  bool favorite;

  TranslationModel({
    this.id = '',
    required this.originalText,
    required this.translatedText,
    required this.sourceLanguage,
    required this.targetLanguage,
    required this.sourceCountry,
    required this.targetCountry,
    required this.creationTime,
    this.favorite = false,
  });

  factory TranslationModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TranslationModel(
      id: doc.id,
      originalText: data['originalText'] ?? '',
      translatedText: data['translatedText'] ?? '',
      sourceLanguage: data['sourceLanguage'] ?? '',
      targetLanguage: data['targetLanguage'] ?? '',
      sourceCountry: data['sourceCountry'] ?? '',
      targetCountry: data['targetCountry'] ?? '',
      creationTime: (data['creationTime'] as Timestamp).toDate(),
      favorite: data['favorite'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'originalText': originalText,
      'translatedText': translatedText,
      'sourceLanguage': sourceLanguage,
      'targetLanguage': targetLanguage,
      'sourceCountry': sourceCountry,
      'targetCountry': targetCountry,
      'creationTime': creationTime,
      'favorite': favorite,
    };
  }
}
