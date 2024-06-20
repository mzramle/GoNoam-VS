import 'package:flutter/material.dart';

class VoiceSampleProvider extends ChangeNotifier {
  String voiceSampleName = "";
  String textPassage = """Character A: "Hey, dude! How's it going?"
Character B: "Not too bad, man. Just chillin'. What about you?"
Character A: "Oh, you know, same old, same old. Nothing exciting happening."
Character B: "Ah, bummer. We should plan something fun this weekend!"
Character A: "Absolutely! Let's hit up that new burger joint everyone's been raving about."
Character B: "Sounds like a plan! I'm craving a juicy burger and some good company."
Character A: "You got it, buddy! It's gonna be epic."
""";
  String chosenLanguage = "";
  bool isRecording = false;
  String recordingTime = '00:00';
  bool isEditing = false;

  void setChosenLanguage(String language) {
    chosenLanguage = language;
    notifyListeners();
  }

  void setVoiceSampleName(String name) {
    voiceSampleName = name;
    notifyListeners();
  }

  void setTextPassage(String text) {
    textPassage = text;
    notifyListeners();
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
