// // controllers/voice_sample_controller.dart
// import 'dart:io';

// import 'package:flutter_sound/flutter_sound.dart';
// import 'package:get/get.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:path/path.dart' as path;

// import '../model/voice_sample_model.dart';

// class VoiceSampleController extends GetxController {
//   var voiceSampleName = ''.obs;
//   var chosenLanguage = ''.obs;
//   var textPassage = ''.obs;
//   var isRecording = false.obs;
//   late FlutterSoundRecorder _recorder;
//   String? audioFilePath;

//   @override
//   void onInit() {
//     super.onInit();
//     _recorder = FlutterSoundRecorder();
//     _recorder.openRecorder();
//   }

//   void setVoiceSampleName(String name) {
//     voiceSampleName.value = name;
//   }

//   void setTextPassage(String text) {
//     textPassage.value = text;
//   }

//   void toggleRecording() async {
//     if (isRecording.value) {
//       await _recorder.stopRecorder();
//       isRecording.value = false;
//     } else {
//       Directory tempDir = await getTemporaryDirectory();
//       audioFilePath = path.join(
//           tempDir.path, '${DateTime.now().millisecondsSinceEpoch}.mp3');
//       await _recorder.startRecorder(
//         toFile: audioFilePath,
//         codec: Codec.aacMP4,
//       );
//       isRecording.value = true;
//     }
//   }

//   Future<void> saveVoiceSample() async {
//     final newVoiceSample = VoiceSample(
//       name: voiceSampleName.value,
//       language: chosenLanguage.value,
//       textPassage: textPassage.value,
//       audioPath: audioFilePath ?? '',
//       creationDate: Timestamp.now(),
//     );

//     await FirebaseFirestore.instance
//         .collection('voice_samples')
//         .add(newVoiceSample.toMap());
//   }
// }

import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import '../helper/toast.dart';
import '../model/voice_sample_model.dart';

class VoiceSampleController {
  final AudioRecorder _recorder = AudioRecorder();
  String? _recordedFilePath;

  Future<void> startRecording(
      String voiceSampleName,
      ValueChanged<bool> setRecordingStatus,
      ValueChanged<String> setRecordingTime) async {
    final bool isPermissionGranted = await _recorder.hasPermission();
    if (!isPermissionGranted) {
      throw Exception("Microphone permission denied");
    }

    final directory = await getApplicationDocumentsDirectory();
    String fileName = 'recording_${DateTime.now().millisecondsSinceEpoch}.m4a';
    _recordedFilePath = '${directory.path}/$fileName';

    const config = RecordConfig(
      encoder: AudioEncoder.aacLc,
      sampleRate: 44100,
      bitRate: 128000,
    );

    await _recorder.start(config, path: _recordedFilePath!);
    setRecordingStatus(true);
    showToast(message: 'Starts recording now');

    Timer.periodic(const Duration(seconds: 1), (Timer timer) async {
      if (!await _recorder.isRecording()) {
        timer.cancel();
      }
      final duration = Duration(seconds: timer.tick);
      final minutes = duration.inMinutes.toString().padLeft(2, '0');
      final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
      setRecordingTime('$minutes:$seconds');
    });
  }

  Future<void> stopRecording(
      ValueChanged<bool> setRecordingStatus,
      Function(File) saveVoiceSample,
      VoidCallback showSuccessToast,
      VoidCallback showErrorToast) async {
    final path = await _recorder.stop();
    setRecordingStatus(false);
    showToast(message: 'Recording Stopped.');
    if (path != null) {
      File audioFile = File(path);
      await saveVoiceSample(audioFile);
      showSuccessToast();
    } else {
      showErrorToast();
    }
  }

  Future<void> saveVoiceSample(File audioFile, String voiceSampleName,
      String chosenLanguage, String textPassage) async {
    try {
      DateTime now = DateTime.now();
      String fileName = "${voiceSampleName}_${now.toIso8601String()}.m4a";
      String fileType = 'm4a';

      Reference storageRef =
          FirebaseStorage.instance.ref().child('voice_samples/$fileName');
      UploadTask uploadTask = storageRef.putFile(audioFile);
      TaskSnapshot snapshot = await uploadTask;

      String audioUrl = await snapshot.ref.getDownloadURL();

      VoiceSampleModel voiceSample = VoiceSampleModel(
        id: '',
        name: voiceSampleName,
        language: chosenLanguage,
        textPassage: textPassage,
        audioUrl: audioUrl,
        fileType: fileType,
        creationDate: now,
      );

      DocumentReference docRef = await FirebaseFirestore.instance
          .collection('voice_samples')
          .add(voiceSample.toJson());
      await docRef.update({'id': docRef.id});
    } on FirebaseException catch (e) {
      throw Exception('Error saving voice sample: $e');
    }
  }
}
