import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:gonoam_v1/helper/toast.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:audioplayers/audioplayers.dart';
import '/model/trained_voice_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TrainedVoiceProvider extends ChangeNotifier {
  List<String> models = [];
  List<String> indexes = [];
  List<TrainedVoiceModel> voices = [];
  late String _selectedModel = '';
  String get selectedModel => _selectedModel;
  late String _selectedIndex = '';
  String get selectedIndex => _selectedIndex;
  late String _selectedVoice = '';
  String get selectedVoice => _selectedVoice;

  String _textInput = '';
  String get textInput => _textInput;
  String _outputFile = '';
  String get outputFile => _outputFile;
  int _ttsRate = 0;
  int get ttsRate => _ttsRate;
  double _pitch = 0;
  double get pitch => _pitch;
  double _filterRadius = 3;
  double get filterRadius => _filterRadius;
  double _indexRate = 0.75;
  double get indexRate => _indexRate;
  double _rmsMixRate = 1;
  double get rmsMixRate => _rmsMixRate;
  double _protect = 0.5;
  double get protect => _protect;
  double _hopLength = 128;
  double get hopLength => _hopLength;
  List<String> f0method = [
    "pm",
    "harvest",
    "dio",
    "crepe",
    "crepe-tiny",
    "rmvpe",
    "fcpe",
    "hybrid[rmvpe+fcpe]",
  ];

  String _selectedF0Method = "rmvpe";
  String get selectedF0Method => _selectedF0Method;
  bool _splitAudio = false;
  bool get splitAudio => _splitAudio;
  bool _autotune = false;
  bool get autotune => _autotune;
  bool _cleanAudio = true;
  bool get cleanAudio => _cleanAudio;

  double _cleanStrength = 0.5;
  double get cleanStrength => _cleanStrength;
  bool _upscaleAudio = false;
  bool get upscaleAudio => _upscaleAudio;
  String _outputTTSPath = '';
  String get outputTTSPath => _outputTTSPath;
  String _outputRVCPath = '';
  String get outputRVCPath => _outputRVCPath;
  String _exportFormat = "WAV";
  String get exportFormat => _exportFormat;
  String _embedderModel = "contentvec";
  String get embedderModel => _embedderModel;
  String? _embedderModelCustom;
  String? get embedderModelCustom => _embedderModelCustom;
  String _searchQuery = '';
  String get searchQuery => _searchQuery;
  String _modelName = '';
  String get modelName => _modelName;
  String _modelLanguage = '';
  String get modelLanguage => _modelLanguage;

  set selectedModel(String value) {
    _selectedModel = value;
    notifyListeners();
  }

  set selectedIndex(String value) {
    _selectedIndex = value;
    notifyListeners();
  }

  set selectedVoice(String value) {
    _selectedVoice = value;
    notifyListeners();
  }

  set textInput(String value) {
    _textInput = value;
    notifyListeners();
  }

  set outputFile(String value) {
    _outputFile = value;
    notifyListeners();
  }

  set ttsRate(int value) {
    _ttsRate = value;
    notifyListeners();
  }

  set pitch(double value) {
    _pitch = value;
    notifyListeners();
  }

  set filterRadius(double value) {
    _filterRadius = value;
    notifyListeners();
  }

  set indexRate(double value) {
    _indexRate = value;
    notifyListeners();
  }

  set rmsMixRate(double value) {
    _rmsMixRate = value;
    notifyListeners();
  }

  set protect(double value) {
    _protect = value;
    notifyListeners();
  }

  set hopLength(double value) {
    _hopLength = value;
    notifyListeners();
  }

  set selectedF0Method(String value) {
    _selectedF0Method = value;
    notifyListeners();
  }

  set splitAudio(bool value) {
    _splitAudio = value;
    notifyListeners();
  }

  set autotune(bool value) {
    _autotune = value;
    notifyListeners();
  }

  set cleanStrength(double value) {
    _cleanStrength = value;
    notifyListeners();
  }

  set upscaleAudio(bool value) {
    _upscaleAudio = value;
    notifyListeners();
  }

  set outputTTSPath(String value) {
    _outputTTSPath = value;
    notifyListeners();
  }

  set outputRVCPath(String value) {
    _outputRVCPath = value;
    notifyListeners();
  }

  set cleanAudio(bool value) {
    _cleanAudio = value;
    notifyListeners();
  }

  set exportFormat(String value) {
    _exportFormat = value;
    notifyListeners();
  }

  set embedderModel(String value) {
    _embedderModel = value;
    notifyListeners();
  }

  set embedderModelCustom(String? value) {
    _embedderModelCustom = value;
    notifyListeners();
  }

  set searchQuery(String value) {
    _searchQuery = value;
    notifyListeners();
  }

  set modelName(String value) {
    _modelName = value;
    notifyListeners();
  }

  set modelLanguage(String value) {
    _modelLanguage = value;
    notifyListeners();
  }

  final AudioPlayer audioPlayer = AudioPlayer();

  TrainedVoiceProvider() {
    initialize();
  }

  Future<void> initialize() async {
    await Future.wait([
      fetchModels(),
      fetchIndexes(),
      fetchVoices(),
    ]);
  }

  // TrainedVoiceProvider() {
  //   fetchModels();
  //   fetchIndexes();
  //   fetchVoices();
  // }

  Future<void> fetchModels() async {
    final response = await http.get(Uri.parse(
        'http://10.160.40.241:5000/models')); // Change to the server's IP address in runLocalTTS batch file
    if (response.statusCode == 200) {
      models = List<String>.from(json.decode(response.body));
      notifyListeners();
    }
  }

  Future<void> fetchIndexes() async {
    final response = await http.get(Uri.parse(
        'http://10.160.40.241:5000/indexes')); // Change to the server's IP address in runLocalTTS batch file
    if (response.statusCode == 200) {
      indexes = List<String>.from(json.decode(response.body));
      notifyListeners();
    }
  }

  Future<void> fetchVoices() async {
    final response = await http.get(Uri.parse(
        'http://10.160.40.241:5000/voices')); // Change to the server's IP address in runLocalTTS batch file
    if (response.statusCode == 200) {
      final List<dynamic> responseData = json.decode(response.body)['voices'];
      voices = responseData.map((voice) {
        return TrainedVoiceModel(
          shortName: voice['ShortName'],
          gender: voice['Gender'],
        );
      }).toList();
      notifyListeners();
    }
  }

  Future<void> generateTTS() async {
    if (selectedModel == null) {
      showErrorToast('Please select a model');
    } else if (selectedIndex == null) {
      showErrorToast('Please select an index');
    } else if (selectedVoice == null) {
      showErrorToast('Please select a voice');
    } else if (textInput.isEmpty || textInput == '') {
      showErrorToast('Text to synthesize cannot be empty');
    } else {
      try {
        final response = await http.post(
          Uri.parse('http://10.160.40.241:5000/tts'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, dynamic>{
            'tts_text': textInput,
            'tts_voice': selectedVoice,
            'tts_rate': ttsRate,
            'pitch': pitch,
            'filter_radius': filterRadius,
            'index_rate': indexRate,
            'rms_mix_rate': rmsMixRate,
            'protect': protect,
            'hop_length': hopLength,
            'f0method': selectedF0Method,
            'output_tts_path': outputTTSPath,
            'output_rvc_path': outputRVCPath,
            'model_file': selectedModel,
            'index_file': selectedIndex,
            'split_audio': splitAudio,
            'autotune': autotune,
            'clean_audio': cleanAudio,
            'clean_strength': cleanStrength,
            'export_format': exportFormat,
            'embedder_model': embedderModel,
            'embedder_model_custom': embedderModelCustom,
            'upscale_audio': upscaleAudio,
          }),
        );

        if (response.statusCode == 200) {
          final directory = await getApplicationDocumentsDirectory();
          final filePath = '${directory.path}/output_audio.wav';
          final file = File(filePath);
          await file.writeAsBytes(response.bodyBytes);

          await audioPlayer.play(
            DeviceFileSource(filePath),
          );

          outputFile = filePath;
          notifyListeners();

          await audioPlayer.onPlayerComplete.first;
          await Future.delayed(const Duration(seconds: 5));
          if (await file.exists()) {
            await file.delete();
          }
        } else {
          throw Exception('Failed to convert text to speech');
        }
      } catch (e) {
        throw Exception('Failed to convert text to speech: $e');
      }
    }
  }

  Future<void> saveTrainedVoiceModelSetting() async {
    var dataMap = {
      'model_name': '$modelName-$selectedVoice',
      'model_language': modelLanguage,
      'tts_voice': selectedVoice,
      'tts_rate': ttsRate,
      'pitch': pitch,
      'filter_radius': filterRadius,
      'index_rate': indexRate,
      'rms_mix_rate': rmsMixRate,
      'protect': protect,
      'hop_length': hopLength,
      'f0method': selectedF0Method,
      'output_tts_path': outputTTSPath,
      'output_rvc_path': outputRVCPath,
      'model_file': selectedModel,
      'index_file': selectedIndex,
      'split_audio': splitAudio,
      'autotune': autotune,
      'clean_audio': cleanAudio,
      'clean_strength': cleanStrength,
      'export_format': exportFormat,
      'embedder_model': embedderModel,
      'embedder_model_custom': embedderModelCustom,
      'upscale_audio': upscaleAudio,
    };

    if (dataMap['model_file'] == null) {
      showErrorToast('Please select a model file');
      return;
    }
    if (dataMap['index_file'] == null) {
      showErrorToast('Please select a index file');
      return;
    }
    if (dataMap['tts_voice'] == null) {
      showErrorToast('Please select a voice');
      return;
    }
    if (dataMap['model_name'] == null || dataMap['model_name'] == '') {
      showErrorToast('Please select a model');
      return;
    }
    if (dataMap['model_language'] == null || dataMap['model_language'] == '') {
      showErrorToast('Please select a language');
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('voice_model_setting')
          .add(dataMap);
      showSuccessToast('Voice model setting saved successfully!');
    } catch (e) {
      throw Exception('Failed to save voice model setting: $e');
    }
  }
}
