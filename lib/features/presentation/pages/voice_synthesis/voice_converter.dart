import 'package:onnxruntime/onnxruntime.dart';
import 'dart:io';
import 'dart:typed_data';

class VoiceConverter {
  late OrtSession _session;

  Future<void> initializeModel(String modelPath) async {
    OrtEnv.instance.init();
    final sessionOptions = OrtSessionOptions();
    final rawAssetFile = await File(modelPath).readAsBytes();
    final bytes = rawAssetFile.buffer.asUint8List();
    _session = OrtSession.fromBuffer(bytes, sessionOptions);
  }

  Future<List<double>> runInference(String audioFilePath) async {
    // Read audio file
    final file = File(audioFilePath);
    final bytes = await file.readAsBytes();
    final inputAudio = bytes.map((byte) => byte.toDouble()).toList();

    // Prepare input tensor
    final inputOrt = OrtValueTensor.createTensorWithDataList(
        inputAudio, [1, inputAudio.length]);

    // Run session
    final inputs = {'input': inputOrt};
    final runOptions = OrtRunOptions();
    final outputs = await _session.runAsync(runOptions, inputs);

    // Extract output audio
    final outputAudio = (outputs?[0]?.value as List<double>?) ?? [];

    // Release resources
    inputOrt.release();
    runOptions.release();
    outputs?.forEach((element) {
      element?.release();
    });

    return outputAudio;
  }

  void release() {
    _session.release();
    OrtEnv.instance.release();
  }
}
