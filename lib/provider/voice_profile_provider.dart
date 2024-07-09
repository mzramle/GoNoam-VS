import 'dart:convert';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../helper/toast.dart';
import '../model/trained_voice_model.dart';
import '../model/voice_profile_model.dart';

class VoiceProfileProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  late FlutterTts flutterTts = FlutterTts();

  List<VoiceProfile> _voiceProfiles = [];
  String? _selectedProfileName;

  List<VoiceProfile> get voiceProfiles => _voiceProfiles;
  String? get selectedProfileName => _selectedProfileName;

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

  String _selectedF0Method = "rmvpe"; // group value for f0method
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

  bool _allowTTSExecution = true;
  bool get allowTTSExecution => _allowTTSExecution;

  void setAllowTTSExecution(bool allow) {
    _allowTTSExecution = allow;
  }

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

  set cleanAudio(bool value) {
    _cleanAudio = value;
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

  set selectedProfileName(String? value) {
    _selectedProfileName = value;
    notifyListeners();
  }

  final AudioPlayer audioPlayer = AudioPlayer();

  VoiceProfileProvider() {
    initialize();
  }

  Future<void> initialize() async {
    await Future.wait([
      fetchModels(),
      fetchIndexes(),
      fetchVoices(),
    ]);
  }

  Future<void> fetchModels() async {
    final response =
        await http.get(Uri.parse('http://10.213.96.76:5000/models'));
    if (response.statusCode == 200) {
      models = List<String>.from(json.decode(response.body));
      notifyListeners();
    }
  }

  Future<void> fetchIndexes() async {
    final response =
        await http.get(Uri.parse('http://10.213.96.76:5000/indexes'));
    if (response.statusCode == 200) {
      indexes = List<String>.from(json.decode(response.body));
      notifyListeners();
    }
  }

  Future<void> fetchVoices() async {
    final response =
        await http.get(Uri.parse('http://10.213.96.76:5000/voices'));
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

  Future<void> fetchVoiceProfiles() async {
    final QuerySnapshot snapshot =
        await _db.collection('voice_model_setting').get();
    _voiceProfiles =
        snapshot.docs.map((doc) => VoiceProfile.fromFirestore(doc)).toList();
    notifyListeners();
  }

  Future<void> selectProfileAsCurrent(VoiceProfile profile) async {
    try {
      final QuerySnapshot currentProfileSnapshot = await _db
          .collection('voice_model_setting')
          .where('currentVoiceProfile', isEqualTo: 1)
          .get();

      if (currentProfileSnapshot.docs.isNotEmpty) {
        for (var doc in currentProfileSnapshot.docs) {
          await _db
              .collection('voice_model_setting')
              .doc(doc.id)
              .update({'currentVoiceProfile': 0});
        }
      }

      await _db
          .collection('voice_model_setting')
          .doc(profile.id)
          .update({'currentVoiceProfile': 1});

      notifyListeners();
      showSuccessToast('Current voice profile set to ${profile.modelName}');
    } catch (e) {
      showErrorToast("Error setting current voice profile: $e");
    }
  }

  Future<void> updateTrainedVoiceModelSetting() async {
    try {
      final QuerySnapshot currentProfileSnapshot = await _db
          .collection('voice_model_setting')
          .where('currentVoiceProfile', isEqualTo: 1)
          .get();

      if (currentProfileSnapshot.docs.isEmpty) {
        showErrorToast('No current voice profile found.');
        return;
      }
      final DocumentSnapshot currentProfileDoc =
          currentProfileSnapshot.docs.first;

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

      await _db
          .collection('voice_model_setting')
          .doc(currentProfileDoc.id)
          .set(dataMap);

      showSuccessToast('Voice model setting updated successfully!');
    } catch (e) {
      showErrorToast('Failed to update voice model setting: $e');
    }
  }

  Future<Map<String, dynamic>> fetchCurrentVoiceModelData() async {
    try {
      final QuerySnapshot snapshot = await _db
          .collection('voice_model_setting')
          .where('currentVoiceProfile', isEqualTo: 1)
          .limit(1)
          .get();
      if (snapshot.docs.isNotEmpty) {
        // Return all fields of the document
        return snapshot.docs.first.data() as Map<String, dynamic>;
      }
      // Return an empty map or a default map as needed
      return {'defaultField': 'Default Model'};
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      // Return an error map or handle this case as needed
      return {'error': 'Error fetching document'};
    }
  }

  Stream<Map<String, dynamic>> fetchVoiceModelDataStream() {
    try {
      return _db
          .collection('voice_model_setting')
          .where('currentVoiceProfile', isEqualTo: 1)
          .snapshots()
          .map((snapshot) {
        if (snapshot.docs.isNotEmpty) {
          if (kDebugMode) {
            print("Document fetched: ${snapshot.docs.first.data()}");
          }
          return snapshot.docs.first.data();
        } else {
          if (kDebugMode) {
            print("No documents found matching criteria.");
          }
          return {};
        }
      });
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching data: $e");
      }
      return Stream.value({'error': 'Error fetching document'});
    }
  }

  Future<void> _decideAndExecuteTTS(String text, String languageCode) async {
    try {
      fetchCurrentVoiceModelData().then((modelData) async {
        if (allowTTSExecution == true && modelData.isNotEmpty) {
          generateCurrentTTS(
            textInput: text,
            modelData: modelData,
          );
        } else {
          showWarningToast('No Current Voice Profile is present.');
          showWarningToast('Defaulting to Flutter TTS instead...');
          _speakText(text, languageCode);
        }
      });

      //       if (allowTTSExecution == true && modelData.isNotEmpty) {
      //   generateCurrentTTS(
      //     textInput: text,
      //     modelData: modelData,
      //   );
      // } else {
      //   showWarningToast('No Current Voice Profile is present.');
      //   showWarningToast('Defaulting to Flutter TTS instead...');
      //   _speakText(text, languageCode);
      // }
    } catch (e) {
      showErrorToast('Cannot Generate TTS');
      showErrorToast('Error: $e');
    }
  }

  Future<void> executeTTS(String text, String languageCode) async {
    await _decideAndExecuteTTS(text, languageCode);
  }

  Future<void> _speakText(String text, String languageCode) async {
    //voiceSampleProvider.setChosenLanguage(languageCode);
    if (kDebugMode) {
      print("$text $languageCode");
    }
    await flutterTts.setLanguage(languageCode);
    await flutterTts.setPitch(1);
    await flutterTts.speak(text);
    await flutterTts.awaitSpeakCompletion(true);
  }

  Future<void> generateTTS() async {
    if (selectedModel == null) {
      showErrorToast('Please select a model');
    } else if (selectedIndex == null) {
      showErrorToast('Please select an index');
    } else if (selectedVoice == null) {
      showErrorToast('Please select a voice');
    } else if (textInput.isEmpty || textInput == '') {
      showErrorToast('Please enter texts to synthesize speech');
    } else {
      try {
        final response = await http.post(
          Uri.parse('http://10.213.96.76:5000/tts'),
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
          showSuccessToast('TTS generated successfully!');

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

  Future<void> generateCurrentTTS(
      {required String textInput,
      required Map<String, dynamic> modelData}) async {
    if (textInput == '') {
      showErrorToast('Please enter text to synthesize speech');
      return;
    } else if (modelData['model_name'] == null) {
      showErrorToast(
          'No voice model selected. Please select a current voice profile in Adjust Voice Page.');
      return;
    } else if (modelData['model_language'] == null) {
      showErrorToast(
          'No language selected. Please select a current voice profile in Adjust Voice Page.');
      return;
    }

    showNormalToast('Generating TTS...');
    // Set the necessary fields based on modelData
    selectedModel = modelData['model_file'];
    selectedIndex = modelData['index_file'];
    selectedVoice = modelData['tts_voice'];
    ttsRate = modelData['tts_rate'];
    pitch = modelData['pitch'];
    filterRadius = modelData['filter_radius'];
    indexRate = modelData['index_rate'];
    rmsMixRate = modelData['rms_mix_rate'];
    protect = modelData['protect'];
    hopLength = modelData['hop_length'];
    selectedF0Method = modelData['f0method'];
    outputTTSPath = modelData['output_tts_path'];
    outputRVCPath = modelData['output_rvc_path'];
    splitAudio = modelData['split_audio'];
    autotune = modelData['autotune'];
    cleanAudio = modelData['clean_audio'];
    cleanStrength = modelData['clean_strength'];
    exportFormat = modelData['export_format'];
    embedderModel = modelData['embedder_model'];
    embedderModelCustom = modelData['embedder_model_custom'];
    this.textInput = textInput;

    try {
      await generateTTS();
    } catch (e) {
      showErrorToast('Error in generating speech.');
      showErrorToast('Error: $e');
    }
  }

  void initializeFromData(Map<String, dynamic> data) {
    selectedModel = data['model_file'];
    selectedIndex = data['index_file'];
    selectedVoice = data['tts_voice'];
    modelName = data['model_name'];
    modelLanguage = data['model_language'];
    ttsRate = data['tts_rate'].toDouble();
    pitch = data['pitch'];
    filterRadius = data['filter_radius'];
    indexRate = data['index_rate'];
    rmsMixRate = data['rms_mix_rate'];
    protect = data['protect'];
    hopLength = data['hop_length'];
    selectedF0Method = data['f0method'];
    textInput = data['text_to_synthesize'] ?? '';
    notifyListeners();
  }
}

// ===========================================================================================================================
// ===========================================================================================================================

// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:cloud_firestore/cloud_firestore.dart';

// class VoiceProfileProvider extends ChangeNotifier {
//   final FirebaseFirestore _db = FirebaseFirestore.instance;
//   List<VoiceProfile> _voiceProfiles = [];
//   String? _selectedProfileName;

//   List<VoiceProfile> get voiceProfiles => _voiceProfiles;
//   String? get selectedProfileName => _selectedProfileName;

//   List<String> models = [];
//   List<String> indexes = [];
//   List<TrainedVoiceModel> voices = [];
//   late String _selectedModel;
//   String get selectedModel => _selectedModel;
//   late String _selectedIndex;
//   String get selectedIndex => _selectedIndex;
//   late String _selectedVoice;
//   String get selectedVoice => _selectedVoice;

//   String _textInput = '';
//   String get textInput => _textInput;
//   String _outputFile = '';
//   String get outputFile => _outputFile;
//   int _ttsRate = 0;
//   int get ttsRate => _ttsRate;
//   double _pitch = 0;
//   double get pitch => _pitch;
//   double _filterRadius = 3;
//   double get filterRadius => _filterRadius;
//   double _indexRate = 0.75;
//   double get indexRate => _indexRate;
//   double _rmsMixRate = 1;
//   double get rmsMixRate => _rmsMixRate;
//   double _protect = 0.5;
//   double get protect => _protect;
//   double _hopLength = 128;
//   double get hopLength => _hopLength;
//   List<String> f0method = [
//     "pm",
//     "harvest",
//     "dio",
//     "crepe",
//     "crepe-tiny",
//     "rmvpe",
//     "fcpe",
//     "hybrid[rmvpe+fcpe]",
//   ];

//   String _selectedF0Method = "rmvpe";
//   String get selectedF0Method => _selectedF0Method;
//   bool _splitAudio = false;
//   bool get splitAudio => _splitAudio;
//   bool _autotune = false;
//   bool get autotune => _autotune;
//   bool _cleanAudio = true;
//   bool get cleanAudio => _cleanAudio;

//   double _cleanStrength = 0.5;
//   double get cleanStrength => _cleanStrength;
//   bool _upscaleAudio = false;
//   bool get upscaleAudio => _upscaleAudio;
//   String _outputTTSPath = '';
//   String get outputTTSPath => _outputTTSPath;
//   String _outputRVCPath = '';
//   String get outputRVCPath => _outputRVCPath;
//   String _exportFormat = "WAV";
//   String get exportFormat => _exportFormat;
//   String _embedderModel = "contentvec";
//   String get embedderModel => _embedderModel;
//   String? _embedderModelCustom;
//   String? get embedderModelCustom => _embedderModelCustom;
//   String _searchQuery = '';
//   String get searchQuery => _searchQuery;
//   String _modelName = '';
//   String get modelName => _modelName;
//   String _modelLanguage = '';
//   String get modelLanguage => _modelLanguage;

//   Future<void> fetchModels() async {
//     final response =
//         await http.get(Uri.parse('http://10.213.96.76:5000/models'));
//     if (response.statusCode == 200) {
//       models = List<String>.from(json.decode(response.body));
//       notifyListeners();
//     }
//   }

//   Future<void> fetchIndexes() async {
//     final response =
//         await http.get(Uri.parse('http://10.213.96.76:5000/indexes'));
//     if (response.statusCode == 200) {
//       indexes = List<String>.from(json.decode(response.body));
//       notifyListeners();
//     }
//   }

//   Future<void> fetchVoices() async {
//     final response =
//         await http.get(Uri.parse('http://10.213.96.76:5000/voices'));
//     if (response.statusCode == 200) {
//       final List<dynamic> responseData = json.decode(response.body)['voices'];
//       voices = responseData.map((voice) {
//         return TrainedVoiceModel(
//           shortName: voice['ShortName'],
//           gender: voice['Gender'],
//         );
//       }).toList();
//       notifyListeners();
//     }
//   }

//   Future<void> fetchVoiceProfiles() async {
//     final QuerySnapshot snapshot =
//         await _db.collection('voice_model_setting').get();
//     _voiceProfiles =
//         snapshot.docs.map((doc) => VoiceProfile.fromFirestore(doc)).toList();
//     notifyListeners();
//   }

//   void updateSelectedModel(String model) {
//     _selectedModel = model;
//     notifyListeners();
//   }

//   void updateSelectedIndex(String index) {
//     _selectedIndex = index;
//     notifyListeners();
//   }

//   void updateSelectedVoice(String voice) {
//     _selectedVoice = voice;
//     notifyListeners();
//   }

//   void updateTextInput(String text) {
//     _textInput = text;
//     notifyListeners();
//   }

//   void updateOutputFile(String file) {
//     _outputFile = file;
//     notifyListeners();
//   }

//   void updateTtsRate(int rate) {
//     _ttsRate = rate;
//     notifyListeners();
//   }

//   void updatePitch(double pitchValue) {
//     _pitch = pitchValue;
//     notifyListeners();
//   }

//   void updateFilterRadius(double radius) {
//     _filterRadius = radius;
//     notifyListeners();
//   }

//   void updateIndexRate(double rate) {
//     _indexRate = rate;
//     notifyListeners();
//   }

//   void updateRmsMixRate(double rate) {
//     _rmsMixRate = rate;
//     notifyListeners();
//   }

//   void updateProtect(double protectValue) {
//     _protect = protectValue;
//     notifyListeners();
//   }

//   void updateHopLength(double length) {
//     _hopLength = length;
//     notifyListeners();
//   }

//   void updateSelectedF0Method(String method) {
//     _selectedF0Method = method;
//     notifyListeners();
//   }

//   void updateSplitAudio(bool split) {
//     _splitAudio = split;
//     notifyListeners();
//   }

//   void updateAutotune(bool autotuneValue) {
//     _autotune = autotuneValue;
//     notifyListeners();
//   }

//   void updateCleanAudio(bool clean) {
//     _cleanAudio = clean;
//     notifyListeners();
//   }

//   void updateCleanStrength(double strength) {
//     _cleanStrength = strength;
//     notifyListeners();
//   }

//   void updateUpscaleAudio(bool upscale) {
//     _upscaleAudio = upscale;
//     notifyListeners();
//   }

//   void updateOutputTTSPath(String path) {
//     _outputTTSPath = path;
//     notifyListeners();
//   }

//   void updateOutputRVCPath(String path) {
//     _outputRVCPath = path;
//     notifyListeners();
//   }

//   void updateExportFormat(String format) {
//     _exportFormat = format;
//     notifyListeners();
//   }

//   void updateEmbedderModel(String model) {
//     _embedderModel = model;
//     notifyListeners();
//   }

//   void updateEmbedderModelCustom(String? model) {
//     _embedderModelCustom = model;
//     notifyListeners();
//   }

//   void updateSearchQuery(String query) {
//     _searchQuery = query;
//     notifyListeners();
//   }

//   void updateModelName(String name) {
//     _modelName = name;
//     notifyListeners();
//   }

//   void updateModelLanguage(String language) {
//     _modelLanguage = language;
//     notifyListeners();
//   }
// }

// class VoiceProfile {
//   String id;
//   String modelName;
//   String modelLanguage;
//   Map<dynamic, dynamic> additionalFields;

//   VoiceProfile({
//     required this.id,
//     required this.modelName,
//     required this.modelLanguage,
//     required this.additionalFields,
//   });

//   factory VoiceProfile.fromFirestore(DocumentSnapshot doc) {
//     Map data = doc.data() as Map<String, dynamic>;
//     return VoiceProfile(
//       id: doc.id,
//       modelName: data['model_name'] ?? '',
//       modelLanguage: data['model_language'] ?? '',
//       additionalFields: data,
//     );
//   }
// }

// class TrainedVoiceModel {
//   String shortName;
//   String gender;

//   TrainedVoiceModel({
//     required this.shortName,
//     required this.gender,
//   });
// }
