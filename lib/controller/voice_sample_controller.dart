// import 'dart:async';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../helper/toast.dart';

// class VoiceSampleController {
  // final AudioRecorder _recorder = AudioRecorder();
  // final AudioPlayer _audioPlayer = AudioPlayer();
  // final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ValueChanged<String> setRecordingTime = (String value) {};
  // String? _recordedFilePath;
  // Timer? _recordingTimer;

  // Future<void> startRecording(
  //     String voiceSampleName,
  //     ValueChanged<bool> setRecordingStatus,
  //     ValueChanged<String> setRecordingTime) async {
  //   // Request microphone permission
  //   var status = await Permission.microphone.request();
  //   if (status == PermissionStatus.denied) {
  //     // Permission denied but not permanently. You can ask the user to grant permission again.
  //     // Here, you might want to return or handle it differently instead of throwing an exception.
  //     showToast(
  //         message:
  //             "Microphone permission denied. Please grant permission to record audio.");
  //     return; // Return from the function, giving the user another chance later.
  //   } else if (status == PermissionStatus.permanentlyDenied) {
  //     // The user opted to never again see the permission request dialog for this app.
  //     throw Exception(
  //         "Microphone permission permanently denied. Please enable it in app settings.");
  //   } else if (status != PermissionStatus.granted) {
  //     // Handle other statuses if necessary (e.g., restricted).
  //     throw Exception("Unable to access the microphone. Status: $status");
  //   }

  //   // If permission is granted, proceed with recording
  //   final directory = await getApplicationDocumentsDirectory();
  //   String fileName = 'recording_${DateTime.now().millisecondsSinceEpoch}.m4a';
  //   _recordedFilePath = '${directory.path}/$fileName';
  //   const config = RecordConfig(
  //     encoder: AudioEncoder.aacLc,
  //     sampleRate: 44100,
  //     bitRate: 128000,
  //   );
  //   await _recorder.start(config, path: _recordedFilePath!);
  //   setRecordingStatus(true);
  //   showToast(message: 'Starts recording now');

  //   _recordingTimer =
  //       Timer.periodic(const Duration(seconds: 1), (Timer timer) async {
  //     if (!await _recorder.isRecording()) {
  //       timer.cancel();
  //     }
  //     final duration = Duration(seconds: timer.tick);
  //     final minutes = duration.inMinutes.toString().padLeft(2, '0');
  //     final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
  //     setRecordingTime('$minutes:$seconds');
  //   });
  // }

  // // Future<void> stopRecording(ValueChanged<bool> setRecordingStatus,
  // //     String voiceSampleName, String chosenLanguage, String textPassage) async {
  // //   // Check if the recorder is currently recording before attempting to stop
  // //   if (await _recorder.isRecording()) {
  // //     final path = await _recorder.stop();
  // //     // await _recorder.dispose();
  // //     _recordingTimer?.cancel(); // Cancel the timer
  // //     setRecordingStatus(false);
  // //     if (path != null) {
  // //       File audioFile = File(path);
  // //       await saveVoiceSample(audioFile, voiceSampleName, chosenLanguage,
  // //           textPassage); // Updated to pass additional parameters
  // //       showToast(message: 'Voice Sample Saved Successfully');
  // //     } else {
  // //       showToast(message: 'Failed to save voice sample');
  // //     }
  // //   } else {
  // //     showToast(
  // //         message: 'Recorder is not active or has already been disposed.');
  // //   }
  // // }

  // Future<void> pauseRecording(
  //     ValueChanged<bool> setRecordingStatus, VoidCallback showToast) async {
  //   _recordingTimer?.cancel();
  //   setRecordingStatus(false);
  //   await _recorder.pause();
  //   showToast();
  // }

  // Future<void> resumeRecording(
  //     ValueChanged<bool> setRecordingStatus, VoidCallback showToast) async {
  //   _recordingTimer =
  //       Timer.periodic(const Duration(seconds: 1), (Timer timer) async {
  //     if (!await _recorder.isRecording()) {
  //       timer.cancel();
  //     }
  //     final duration = Duration(seconds: timer.tick);
  //     final minutes = duration.inMinutes.toString().padLeft(2, '0');
  //     final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
  //     setRecordingTime('$minutes:$seconds');
  //   });
  //   setRecordingStatus(true);
  //   await _recorder.resume();
  //   showToast();
  // }

  // Future<void> playAudio(String filePath) async {
  //   await _audioPlayer.play(DeviceFileSource(filePath));
  // }

  // Future<void> pauseAudio() async {
  //   await _audioPlayer.pause();
  // }

  // Future<void> stopAudio() async {
  //   await _audioPlayer.stop();
  // }

  // Future<void> seekAudio(Duration position) async {
  //   await _audioPlayer.seek(position);
  // }

//   Future<void> _storeVoiceSampleData(
//       String voiceSampleName, String chosenLanguage, String audioPath) async {
//     try {
//       final user = FirebaseAuth.instance.currentUser;
//       if (user == null) throw Exception('User not logged in');
//       final voiceSampleData = {
//         'voiceSampleName': voiceSampleName,
//         'chosenLanguage': chosenLanguage,
//         'audioPath': audioPath,
//         'userId': user.uid,
//         'timeCreated': FieldValue.serverTimestamp(), // Add time created
//       };
//       await FirebaseFirestore.instance
//           .collection('voice_samples')
//           .add(voiceSampleData);
//       showSuccessToast('Voice sample saved successfully!');
//     } catch (e) {
//       showErrorToast('Failed to save voice sample: $e');
//     }
//   }

//   Future<void> getStoreVoiceSample(
//       String voiceSampleName, String chosenLanguage, String audioPath) async {
//     _storeVoiceSampleData(voiceSampleName, chosenLanguage, audioPath);
//   }
// }
