import 'package:flutter_tts/flutter_tts.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class TTSManager {
  FlutterTts flutterTts;

  TTSManager() : flutterTts = FlutterTts();

  Future<String> synthesizeText(String text) async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.setVolume(1.0);
    await flutterTts.setPitch(1.0);

    final directory = await getApplicationDocumentsDirectory();
    final filePath = '/storage/5A02-42D6/voicemodels/tts_output.wav';

    final result = await flutterTts.synthesizeToFile(text, filePath);
    if (result == 1) {
      return filePath;
    } else {
      throw Exception("Failed to generate TTS audio");
    }
  }
}
