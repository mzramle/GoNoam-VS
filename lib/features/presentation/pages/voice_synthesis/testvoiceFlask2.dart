import 'dart:convert';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gonoam_v1/helper/toast.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class TTSTabPage2 extends StatefulWidget {
  const TTSTabPage2({super.key});

  @override
  State<TTSTabPage2> createState() => _TTSTabPage2State();
}

class _TTSTabPage2State extends State<TTSTabPage2> {
  List<String> _models = [];
  List<String> _indexes = [];
  List<Map<String, dynamic>> _voices = [];
  String? _selectedModel;
  String? _selectedIndex;
  String? _selectedVoice;
  String _textInput = '';
  String _outputFile = '';
  int _ttsRate = 0;
  double _pitch = 0;
  double _filterRadius = 3;
  double _indexRate = 0.75;
  double _rmsMixRate = 1;
  double _protect = 0.5;
  double _hopLength = 128;
  final List<String> _f0method = [
    "pm",
    "harvest",
    "dio",
    "crepe",
    "crepe-tiny",
    "rmvpe",
    "fcpe",
    "hybrid[rmvpe+fcpe]",
  ];
  String _selectedF0Method = "rmvpe"; // Default value
  final bool _splitAudio = false;
  final bool _autotune = false;
  final bool _cleanAudio = true;
  final double _cleanStrength = 0.5;
  final bool _upscaleAudio = false;
  final String _outputTTSPath = '';
  final String _outputRVCPath = '';
  final String _exportFormat = "WAV";
  final String _embedderModel = "contentvec";
  String? _embedderModelCustom;
  String _searchQuery = '';
  AudioPlayer audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _fetchModels();
    _fetchIndexes();
    _fetchVoices();
  }

  Future<void> _fetchModels() async {
    final response =
        await http.get(Uri.parse('http://10.213.96.76:5000/models'));
    if (response.statusCode == 200) {
      setState(() {
        _models = List<String>.from(json.decode(response.body));
      });
    }
  }

  Future<void> _fetchIndexes() async {
    final response =
        await http.get(Uri.parse('http://10.213.96.76:5000/indexes'));
    if (response.statusCode == 200) {
      setState(() {
        _indexes = List<String>.from(json.decode(response.body));
      });
    }
  }

  Future<void> _fetchVoices() async {
    final response =
        await http.get(Uri.parse('http://10.213.96.76:5000/voices'));
    if (response.statusCode == 200) {
      final List<dynamic> responseData = json.decode(response.body)['voices'];
      setState(() {
        _voices = responseData.map((voice) {
          return {
            'ShortName': voice['ShortName'],
            'Gender': voice['Gender'],
          };
        }).toList();
      });
    }
  }

  Future<void> _convertTTS() async {
    try {
      final response = await http.post(
        Uri.parse('http://10.213.96.76:5000/tts'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'tts_text': _textInput,
          'tts_voice': _selectedVoice,
          'tts_rate': _ttsRate,
          'pitch': _pitch,
          'filter_radius': _filterRadius,
          'index_rate': _indexRate,
          'rms_mix_rate': _rmsMixRate,
          'protect': _protect,
          'hop_length': _hopLength,
          'f0method': _f0method,
          'output_tts_path': _outputTTSPath,
          'output_rvc_path': _outputRVCPath,
          'model_file': _selectedModel,
          'index_file': _selectedIndex,
          'split_audio': _splitAudio,
          'autotune': _autotune,
          'clean_audio': _cleanAudio,
          'clean_strength': _cleanStrength,
          'export_format': _exportFormat,
          'embedder_model': _embedderModel,
          'embedder_model_custom': _embedderModelCustom,
          'upscale_audio': _upscaleAudio,
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

        setState(() {
          _outputFile = filePath;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to convert text to speech')),
        );
      }
    } catch (e) {
      showErrorToast('Failed to convert text to speech: $e');
      if (kDebugMode) {
        print(e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final searchField = TextField(
      decoration: const InputDecoration(
        labelText: 'Search Voice',
        suffixIcon: Icon(Icons.search),
      ),
      onChanged: (value) {
        setState(() {
          _searchQuery = value.toLowerCase();
        });
      },
    );

    final filteredVoices = _voices.where((voice) {
      return voice['ShortName']!.toLowerCase().contains(_searchQuery) ||
          voice['Gender']!.toLowerCase().contains(_searchQuery);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Current Voice Model Adjustment'),
        backgroundColor: Colors.blueGrey[900],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            DropdownButton<String>(
              hint: const Text('Select Model'),
              value: _selectedModel,
              onChanged: (newValue) {
                setState(() {
                  _selectedModel = newValue;
                });
              },
              items: _models.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            DropdownButton<String>(
              hint: const Text('Select Index'),
              value: _selectedIndex,
              onChanged: (newValue) {
                setState(() {
                  _selectedIndex = newValue;
                });
              },
              items: _indexes.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            // searchField,
            DropdownButton<String>(
              menuMaxHeight: 400,
              hint: const Text('Select Voice'),
              value: _selectedVoice,
              onChanged: (newValue) {
                setState(() {
                  _selectedVoice = newValue;
                });
              },
              items: filteredVoices.map<DropdownMenuItem<String>>((voice) {
                return DropdownMenuItem<String>(
                  value: voice['ShortName'],
                  child: Text('${voice['ShortName']} (${voice['Gender']})'),
                );
              }).toList(),
            ),
            Text('TTS Rate: $_ttsRate'),
            Slider(
              label: "TTS Rate",
              value: _ttsRate.toDouble(), // Convert int to double for Slider
              min: 0,
              max: 100,
              divisions: 100, // Specify divisions for integer values
              onChanged: (newValue) {
                setState(() {
                  _ttsRate =
                      newValue.round(); // Convert back to int and update state
                });
              },
            ),
            Text('Pitch: $_pitch'),
            Slider(
              label: "Pitch",
              value: _pitch,
              min: -100,
              max: 100,
              onChanged: (newValue) {
                setState(() {
                  _pitch = newValue;
                });
              },
            ),
            Text('Filter Radius: $_filterRadius'),
            Slider(
              label: "Filter Radius",
              value: _filterRadius,
              min: 1,
              max: 10,
              onChanged: (newValue) {
                setState(() {
                  _filterRadius = newValue;
                });
              },
            ),
            Text('Index Rate: $_indexRate'),
            Slider(
              label: "Index Rate",
              value: _indexRate,
              min: 0,
              max: 1,
              onChanged: (newValue) {
                setState(() {
                  _indexRate = newValue;
                });
              },
            ),
            Text('RMS Mix Rate: $_rmsMixRate'),
            Slider(
              label: "RMS Mix Rate",
              value: _rmsMixRate,
              min: 0,
              max: 1,
              onChanged: (newValue) {
                setState(() {
                  _rmsMixRate = newValue;
                });
              },
            ),
            Text('Protect: $_protect'),
            Slider(
              label: "Protect",
              value: _protect,
              min: 0,
              max: 1,
              onChanged: (newValue) {
                setState(() {
                  _protect = newValue;
                });
              },
            ),
            Text('Hop Length: $_hopLength'),
            Slider(
              label: "Hop Length",
              value: _hopLength,
              min: 64,
              max: 512,
              onChanged: (newValue) {
                setState(() {
                  _hopLength = newValue;
                });
              },
            ),
            const Text('F0 Method:'),
            ..._f0method.map((method) => RadioListTile<String>(
                  title: Text(method),
                  value: method,
                  groupValue: _selectedF0Method,
                  onChanged: (String? value) {
                    setState(() {
                      _selectedF0Method = value!;
                    });
                  },
                )),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Enter Text to synthesize',
              ),
              onChanged: (text) {
                setState(() {
                  _textInput = text;
                });
              },
            ),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Enter Output File Name',
              ),
              onChanged: (text) {
                setState(() {
                  _outputFile = text;
                });
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _convertTTS,
              child: const Text('Convert'),
            ),
            const SizedBox(height: 20),
            if (_outputFile.isNotEmpty) ...[
              const Text('Output File:'),
              Text(_outputFile),
            ],
          ],
        ),
      ),
    );
  }
}
