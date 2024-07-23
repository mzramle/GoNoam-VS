import 'package:cloud_firestore/cloud_firestore.dart';

class VoiceProfile {
  String id;
  String modelName;
  String modelLanguage;
  Map<dynamic, dynamic> additionalFields;

  VoiceProfile({
    required this.id,
    required this.modelName,
    required this.modelLanguage,
    required this.additionalFields,
  });

  factory VoiceProfile.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return VoiceProfile(
      id: doc.id,
      modelName: data['model_name'] ?? '',
      modelLanguage: data['model_language'] ?? '',
      additionalFields: data,
    );
  }
}
