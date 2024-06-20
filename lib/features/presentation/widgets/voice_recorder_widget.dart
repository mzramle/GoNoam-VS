import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../provider/voice_sample_provider.dart';
import '../../../../controller/voice_sample_controller.dart';
import '../../../helper/toast.dart';

class VoiceRecorderWidget extends StatelessWidget {
  final Function(File) onSave;
  final Function(String) onTimeUpdate;

  const VoiceRecorderWidget({
    super.key,
    required this.onSave,
    required this.onTimeUpdate,
  });

  @override
  Widget build(BuildContext context) {
    final voiceSampleProvider = Provider.of<VoiceSampleProvider>(context);
    final voiceSampleController = VoiceSampleController();

    return Column(
      children: [
        ElevatedButton(
          onPressed: voiceSampleProvider.isRecording
              ? null
              : () => voiceSampleController.startRecording(
                    voiceSampleProvider.voiceSampleName,
                    voiceSampleProvider.setRecordingStatus,
                    voiceSampleProvider.setRecordingTime,
                  ),
          child: const Text('Start Recording'),
        ),
        ElevatedButton(
          onPressed: voiceSampleProvider.isRecording
              ? () => voiceSampleController.stopRecording(
                    voiceSampleProvider.setRecordingStatus,
                    onSave,
                    () => showSuccessToast('Voice Sample Saved Successfully'),
                    () => showErrorToast('Failed to save voice sample'),
                  )
              : null,
          child: const Text('Stop Recording'),
        ),
      ],
    );
  }
}
