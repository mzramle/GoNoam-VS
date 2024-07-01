import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class AudioPlayerControls extends StatefulWidget {
  final File? audioFile;
  final Function onPlay;
  final Function onPause;
  final Function onStop;
  final Function(Duration) onSeek;

  const AudioPlayerControls({
    super.key,
    this.audioFile,
    required this.onPlay,
    required this.onPause,
    required this.onStop,
    required this.onSeek,
  });

  @override
  State<AudioPlayerControls> createState() => _AudioPlayerControlsState();
}

class _AudioPlayerControlsState extends State<AudioPlayerControls> {
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.play_arrow),
          onPressed: () async {
            await _audioPlayer.play(DeviceFileSource(widget.audioFile!.path));
            widget.onPlay();
          },
        ),
        IconButton(
          icon: const Icon(Icons.pause),
          onPressed: () async {
            await _audioPlayer.pause();
            widget.onPause();
          },
        ),
        IconButton(
          icon: const Icon(Icons.stop),
          onPressed: () async {
            await _audioPlayer.stop();
            widget.onStop();
          },
        ),
        // Additional UI for seeking within the audio could be added here
      ],
    );
  }
}
