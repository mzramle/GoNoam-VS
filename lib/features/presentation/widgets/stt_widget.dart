import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text_provider.dart';

class STTWidget extends StatelessWidget {
  const STTWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final speechProvider = Provider.of<SpeechToTextProvider>(context);
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Tap the microphone and start speaking',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 20),
          IconButton(
            icon: const Icon(Icons.mic, size: 50, color: Colors.blue),
            onPressed: speechProvider.isListening
                ? speechProvider.stop
                : () => speechProvider.listen(
                    // (text) {
                    //     // Update the text field with recognized speech
                    //     Navigator.pop(context, text);
                    //   }
                    ),
          ),
        ],
      ),
    );
  }
}
