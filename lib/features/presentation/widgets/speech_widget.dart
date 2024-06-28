import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class SpeechWidget extends StatefulWidget {
  final Function(String) onResult;
  final Icon icon;

  const SpeechWidget({required this.onResult, required this.icon, super.key});

  @override
  State<SpeechWidget> createState() => _SpeechWidgetState();
}

class _SpeechWidgetState extends State<SpeechWidget> {
  final SpeechToText _speechToText = SpeechToText();
  bool _isListening = false;
  String _lastWords = '';
  String _notification = '';
  static const int _silenceTimeout = 5; // Timeout in seconds for silence

  @override
  void initState() {
    super.initState();
  }

  void _startListening() async {
    bool available = await _speechToText.initialize();
    if (available) {
      setState(() {
        _isListening = true;
        _notification = 'Listening...';
      });
      await _speechToText.listen(
        onResult: _onSpeechResult,
        listenFor: const Duration(seconds: 60), // Adjust as needed
        pauseFor: const Duration(seconds: _silenceTimeout),
        onSoundLevelChange: _onSoundLevelChange,
        cancelOnError: true,
        partialResults: true,
      );
    } else {
      setState(() {
        _isListening = false;
        _notification = 'Speech recognition unavailable';
      });
    }
  }

  void _stopListening() async {
    await _speechToText.stop();
    setState(() {
      _isListening = false;
      _notification = 'Recording stopped';
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

  void _onSoundLevelChange(double level) {
    if (_isListening && level == 0.0) {
      // If no sound is detected for a while, stop listening
      Future.delayed(const Duration(seconds: _silenceTimeout), () {
        if (_isListening) {
          _stopListening();
          setState(() {
            _notification = 'No voice detected, stopped recording';
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FloatingActionButton(
          onPressed: () {
            if (_isListening) {
              _stopListening();
              setState(() {
                _notification = 'Recording canceled';
              });
            } else {
              _startListening();
            }
          },
          child: Icon(_isListening ? Icons.mic : Icons.mic_none),
        ),
        if (_notification.isNotEmpty) ...[
          const SizedBox(height: 10),
          Text(_notification),
        ],
      ],
    );
  }
}
