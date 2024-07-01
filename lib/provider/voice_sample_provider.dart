import 'dart:io';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../helper/toast.dart';
import '../model/text_passages_model.dart';

class VoiceSampleProvider extends ChangeNotifier {
  String voiceSampleName = "";
  String textPassage =
      """You can fool all of the people some of the time, and some of the people all of the time, but you can't fool all of the people all of the time. 
  — Abraham Lincoln""";
  String chosenLanguage = "";
  bool isRecording = false;
  String recordingTime = '00:00';
  bool isEditing = false;
  final File _recordedFile = File(
      ''); // Assuming _recordedFile is the private variable holding the recorded file.
  File get recordedFile => _recordedFile;
  bool get hasRecordedSample => recordedFile.existsSync();

  void setChosenLanguage(String language) {
    chosenLanguage = language;
    notifyListeners();
  }

  void getChosenLanguage(String language) {
    chosenLanguage = language;
    notifyListeners();
  }

  void setVoiceSampleName(String name) {
    voiceSampleName = name;
    notifyListeners();
  }

  void getVoiceSampleName(String name) {
    voiceSampleName = name;
    notifyListeners();
  }

  void setTextPassage(String text) {
    if (textPassage != text) {
      // Check if the value is different
      textPassage = text;
      notifyListeners();
    }
  }

  void setRecordingStatus(bool status) {
    isRecording = status;
    notifyListeners();
  }

  void setRecordingTime(String time) {
    recordingTime = time;
    notifyListeners();
  }

  void toggleEditing() {
    isEditing = !isEditing;
    notifyListeners();
  }

  Future<void> _storeVoiceSampleData(
      String voiceSampleName, String chosenLanguage, String audioPath) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not logged in');
      final voiceSampleData = {
        'voiceSampleName': voiceSampleName,
        'chosenLanguage': chosenLanguage,
        'audioPath': audioPath,
        'userId': user.uid,
        'timeCreated': FieldValue.serverTimestamp(), // Add time created
      };
      await FirebaseFirestore.instance
          .collection('voice_samples')
          .add(voiceSampleData);
      showSuccessToast('Voice sample saved successfully!');
    } catch (e) {
      showErrorToast('Failed to save voice sample: $e');
    }
  }

  Future<void> getStoreVoiceSample(
      String voiceSampleName, String chosenLanguage, String audioPath) async {
    _storeVoiceSampleData(voiceSampleName, chosenLanguage, audioPath);
  }

  Future<void> saveTextPassage(String textPassage) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not logged in');

      final textPassageModel = TextPassageModel(
        id: '',
        userId: user.uid,
        content: textPassage,
      );

      DocumentReference docRef = await FirebaseFirestore.instance
          .collection('text_passages')
          .add(textPassageModel.toJson());

      await docRef.update({'id': docRef.id});
      showSuccessToast('Text passage saved successfully!');
    } catch (e) {
      showErrorToast('Failed to save text passage: $e');
    }
  }

  // Method to fetch voice samples
  Future<List<QueryDocumentSnapshot>> fetchVoiceSamples() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('User not logged in');
    final data = await FirebaseFirestore.instance
        .collection('voice_samples')
        .where('userId', isEqualTo: user.uid)
        .get();
    return data.docs;
  }

// Updated deleteVoiceSample method to notify listeners
  Future<void> deleteVoiceSample(String docId) async {
    try {
      await FirebaseFirestore.instance
          .collection('voice_samples')
          .doc(docId)
          .delete();
      showSuccessToast('Voice sample deleted successfully');
      notifyListeners(); // Notify listeners to refresh the UI
    } catch (e) {
      showErrorToast('Cannot delete voice sample. ERROR: $e');
    }
  }
}

//   String textPassage = """Character A: "Hey, dude! How's it going?"
// Character B: "Not too bad, man. Just chillin'. What about you?"
// Character A: "Oh, you know, same old, same old. Nothing exciting happening."
// Character B: "Ah, bummer. We should plan something fun this weekend!"
// Character A: "Absolutely! Let's hit up that new burger joint everyone's been raving about."
// Character B: "Sounds like a plan! I'm craving a juicy burger and some good company."
// Character A: "You got it, buddy! It's gonna be epic."
// """;