// controllers/voice_sample_controller.dart
import 'dart:io';

import 'package:flutter_sound/flutter_sound.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

import '../model/voice_sample_model.dart';

class VoiceSampleController extends GetxController {
  var voiceSampleName = ''.obs;
  var chosenLanguage = ''.obs;
  var textPassage = ''.obs;
  var isRecording = false.obs;
  late FlutterSoundRecorder _recorder;
  String? audioFilePath;

  @override
  void onInit() {
    super.onInit();
    _recorder = FlutterSoundRecorder();
    _recorder.openRecorder();
  }

  void setVoiceSampleName(String name) {
    voiceSampleName.value = name;
  }

  void setTextPassage(String text) {
    textPassage.value = text;
  }

  void toggleRecording() async {
    if (isRecording.value) {
      await _recorder.stopRecorder();
      isRecording.value = false;
    } else {
      Directory tempDir = await getTemporaryDirectory();
      audioFilePath = path.join(
          tempDir.path, '${DateTime.now().millisecondsSinceEpoch}.mp3');
      await _recorder.startRecorder(
        toFile: audioFilePath,
        codec: Codec.aacMP4,
      );
      isRecording.value = true;
    }
  }

  Future<void> saveVoiceSample() async {
    final newVoiceSample = VoiceSample(
      name: voiceSampleName.value,
      language: chosenLanguage.value,
      textPassage: textPassage.value,
      audioPath: audioFilePath ?? '',
      creationDate: Timestamp.now(),
    );

    await FirebaseFirestore.instance
        .collection('voice_samples')
        .add(newVoiceSample.toMap());
  }
}
