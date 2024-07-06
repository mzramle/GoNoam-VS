import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:audioplayers/audioplayers.dart';
import 'tts_manager.dart';
import 'voice_converter.dart';

class OnnxFlutterTts extends StatefulWidget {
  const OnnxFlutterTts({super.key});

  @override
  State<OnnxFlutterTts> createState() => _OnnxFlutterTtsState();
}

class _OnnxFlutterTtsState extends State<OnnxFlutterTts> {
  final TTSManager ttsManager = TTSManager();
  final VoiceConverter voiceConverter = VoiceConverter();

  String? modelPath;
  String? outputPath;

  Future<void> _pickModel() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null && result.files.single.path != null) {
      setState(() {
        modelPath = result.files.single.path!;
      });
      await voiceConverter.initializeModel(modelPath!);
    } else {
      print("Model not selected");
    }
  }

  Future<void> _pickOutputPath() async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

    if (selectedDirectory != null) {
      setState(() {
        outputPath = selectedDirectory;
      });
    } else {
      print("Output path not selected");
    }
  }

  Future<void> _processTts(String text) async {
    try {
      if (modelPath == null || outputPath == null) {
        print("Model path or output path not selected");
        return;
      }

      final ttsFilePath = await ttsManager.synthesizeText(text);
      print("TTS file path: $ttsFilePath");

      // Check if the TTS file exists
      if (await File(ttsFilePath).exists()) {
        final outputAudio = await voiceConverter.runInference(ttsFilePath);

        final outputFilePath = '$outputPath/final_output.wav';
        final outputFile = File(outputFilePath);
        await outputFile
            .writeAsBytes(outputAudio.map((e) => e.toInt()).toList());

        final audioPlayer = AudioPlayer();
        await audioPlayer.play(DeviceFileSource(outputFilePath));
      } else {
        print("Error: TTS file does not exist at path: $ttsFilePath");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('ONNX TTS Example')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _pickModel,
              child: Text('Pick Model: $modelPath'),
            ),
            ElevatedButton(
              onPressed: _pickOutputPath,
              child: Text('Pick Output Path: $outputPath'),
            ),
            ElevatedButton(
              onPressed: () async {
                await _processTts('Hello, this is a test.');
              },
              child: Text('Run TTS'),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: OnnxFlutterTts(),
  ));
}
