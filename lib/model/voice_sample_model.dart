// models/voice_sample.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class VoiceSample {
  String name;
  String language;
  String textPassage;
  String audioPath;
  Timestamp creationDate;

  VoiceSample({
    required this.name,
    required this.language,
    required this.textPassage,
    required this.audioPath,
    required this.creationDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'language': language,
      'textPassage': textPassage,
      'audioPath': audioPath,
      'creationDate': creationDate,
    };
  }
}
