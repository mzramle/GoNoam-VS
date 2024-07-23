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
  String chosenLanguage = '';
  bool isRecording = false;
  String recordingTime = '00:00';
  bool isEditing = false;
  final File _recordedFile = File('');
  File get recordedFile => _recordedFile;
  bool get hasRecordedSample => recordedFile.existsSync();
  String directoryPath = '/storage/emulated/0/Download/voice_samples/';

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
        'timeCreated': FieldValue.serverTimestamp(),
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

  Future<List<QueryDocumentSnapshot>> fetchVoiceSamples() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('User not logged in');
    final data = await FirebaseFirestore.instance
        .collection('voice_samples')
        .where('userId', isEqualTo: user.uid)
        .get();
    return data.docs;
  }

  Future<void> deleteVoiceSample(String docId) async {
    try {
      await FirebaseFirestore.instance
          .collection('voice_samples')
          .doc(docId)
          .delete();
      showSuccessToast('Voice sample deleted successfully');
      notifyListeners();
    } catch (e) {
      showErrorToast('Cannot delete voice sample. ERROR: $e');
    }
  }
}
