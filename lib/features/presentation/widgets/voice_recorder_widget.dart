// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'audio_player.dart';
// import 'audio_recorder.dart';

// class VoiceRecorderWidget extends StatefulWidget {
//   final void Function(String path) onRecordingComplete;
//   const VoiceRecorderWidget({super.key, required this.onRecordingComplete});

//   @override
//   State<VoiceRecorderWidget> createState() => _VoiceRecorderWidgetState();
// }

// class _VoiceRecorderWidgetState extends State<VoiceRecorderWidget> {
//   bool showPlayer = false;
//   String? audioPath;

//   @override
//   void initState() {
//     showPlayer = false;
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: showPlayer
//           ? Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 25),
//               child: AudioPlayer(
//                 source: audioPath!,
//                 onDelete: () {
//                   setState(() => showPlayer = false);
//                 },
//                 voiceSampleName:
//                     "Sample Name", // This should come from user input or your app's state
//                 chosenLanguage:
//                     "English", // This should come from user selection or your app's state
//                 onSave: (voiceSampleName, chosenLanguage, audioPath) {
//                   // Implement the save functionality here, possibly in the parent widget or a separate class
//                   _storeVoiceSampleData(
//                       voiceSampleName, chosenLanguage, audioPath);
//                 },
//               ))
//           : Recorder(
//               onStop: (path) {
//                 if (kDebugMode) print('Recorded file path: $path');
//                 setState(() {
//                   audioPath = path;
//                   showPlayer = true;
//                 });
//               },
//             ),
//     );
//   }
// }
