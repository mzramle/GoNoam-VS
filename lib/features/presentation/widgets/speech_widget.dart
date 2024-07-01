import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:avatar_glow/avatar_glow.dart';

import '../../../helper/toast.dart';

class SpeechWidget extends StatefulWidget {
  final Function(String) onResult;

  const SpeechWidget({required this.onResult, super.key});

  @override
  State<SpeechWidget> createState() => _SpeechWidgetState();
}

class _SpeechWidgetState extends State<SpeechWidget> {
  late stt.SpeechToText _speechToText;
  bool _isListening = false;
  String _lastWords = '';
  static const int _silenceTimeout = 20; // Timeout in seconds for silence

  @override
  void initState() {
    _speechToText = stt.SpeechToText();
    super.initState();
  }

  void _startListening() async {
    bool available = await _speechToText.initialize();
    if (available) {
      setState(() {
        _isListening = true;
        showToast(message: 'Listening...');
      });
      await _speechToText.listen(
        onResult: _onSpeechResult,
        listenFor: const Duration(minutes: 2),
        pauseFor: const Duration(seconds: _silenceTimeout),
        onSoundLevelChange: _onSoundLevelChange,
        // ignore: deprecated_member_use
        cancelOnError: true,
        // ignore: deprecated_member_use
        partialResults: true,
      );
    } else {
      setState(() {
        _isListening = false;
        showErrorToast('Speech recognition unavailable');
      });
    }
  }

  void _stopListening() async {
    await _speechToText.stop();
    setState(() {
      _isListening = false;
      showSuccessToast('Recording stopped');
    });
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {});
    });
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _lastWords = result.recognizedWords;
      widget.onResult(_lastWords);
      if (result.finalResult) {
        _stopListening();
      }
    });
  }

  void disposeSpeechRecognition() {
    _speechToText.cancel();
  }

  void _onSoundLevelChange(double level) {
    if (_isListening && level == 0.0) {
      // If no sound is detected for a while, stop listening
      Future.delayed(const Duration(seconds: _silenceTimeout), () {
        if (_isListening = false) {
          _stopListening();
          setState(() {
            showToast(message: 'No voice detected, stopped recording');
          });
        }
      });
    }
  }

  @override
  void dispose() {
    disposeSpeechRecognition();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AvatarGlow(
          animate: _isListening,
          glowColor: Colors.purple,
          duration: const Duration(milliseconds: 1000),
          repeat: true,
          child: FloatingActionButton(
            backgroundColor:
                _isListening ? Colors.amberAccent : Colors.deepOrange,
            onPressed: () {
              if (_isListening) {
                _stopListening();
              } else {
                _startListening();
              }
            },
            child: Icon(
              _isListening ? Icons.mic : Icons.mic_none,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
