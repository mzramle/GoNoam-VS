import 'package:cloud_firestore/cloud_firestore.dart';

class TranslationModel {
  final String id;
  final String originalText;
  final String translatedText;
  bool favorite;

  TranslationModel({
    this.id = '',
    required this.originalText,
    required this.translatedText,
    this.favorite = false,
  });

  factory TranslationModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TranslationModel(
      id: doc.id,
      originalText: data['originalText'] ?? '',
      translatedText: data['translatedText'] ?? '',
      favorite: data['favorite'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'originalText': originalText,
      'translatedText': translatedText,
      'favorite': favorite,
    };
  }
}

class TranslationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<TranslationModel>> getTranslationSets() async {
    try {
      final querySnapshot = await _firestore.collection('translations').get();
      return querySnapshot.docs
          .map((doc) => TranslationModel.fromDocument(doc))
          .toList();
    } catch (e) {
      print('Error fetching translation sets: $e');
      return [];
    }
  }
}
