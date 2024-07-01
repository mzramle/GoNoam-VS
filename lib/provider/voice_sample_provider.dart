import 'dart:io';

import 'package:flutter/material.dart';

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
}

//   String textPassage = """Character A: "Hey, dude! How's it going?"
// Character B: "Not too bad, man. Just chillin'. What about you?"
// Character A: "Oh, you know, same old, same old. Nothing exciting happening."
// Character B: "Ah, bummer. We should plan something fun this weekend!"
// Character A: "Absolutely! Let's hit up that new burger joint everyone's been raving about."
// Character B: "Sounds like a plan! I'm craving a juicy burger and some good company."
// Character A: "You got it, buddy! It's gonna be epic."
// """;