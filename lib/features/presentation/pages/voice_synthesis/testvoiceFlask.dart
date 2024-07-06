import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gonoam_v1/helper/toast.dart';
import 'package:http/http.dart' as http;

class TTSTabPage extends StatefulWidget {
  @override
  _TTSTabPageState createState() => _TTSTabPageState();
}

class _TTSTabPageState extends State<TTSTabPage> {
  List<String> _models = [];
  List<String> _indexes = [];
  List<String> _voices = [];
  String? _selectedModel;
  String? _selectedIndex;
  String? _selectedVoice;
  String _textInput = '';
  String _outputFile = '';

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
      setState(() {
        _voices = List<String>.from(json.decode(response.body));
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
          'pth_path': _selectedModel,
          'index_path': _selectedIndex,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        setState(
          () {
            _outputFile = responseData['output_file'];
          },
        );
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('TTS App'),
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
            DropdownButton<String>(
              menuMaxHeight: 100,
              hint: const Text('Select Voice'),
              value: _selectedVoice,
              onChanged: (newValue) {
                setState(() {
                  _selectedVoice = newValue;
                });
              },
              items: _voices.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Enter Text',
              ),
              onChanged: (text) {
                setState(() {
                  _textInput = text;
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
