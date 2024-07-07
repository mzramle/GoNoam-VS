import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../provider/language_provider.dart';
import '../../../../provider/voice_sample_provider.dart';
import '../../widgets/audio_player.dart';
import '../../widgets/audio_recorder.dart';
import '../../widgets/form_container_widget.dart';
import '../../widgets/language_sheet.dart';

class CreateVoiceSamplePage extends StatefulWidget {
  const CreateVoiceSamplePage({super.key});

  @override
  State<CreateVoiceSamplePage> createState() => _CreateVoiceSamplePageState();
}

class _CreateVoiceSamplePageState extends State<CreateVoiceSamplePage> {
  late VoiceSampleProvider voiceSampleProvider =
      Provider.of<VoiceSampleProvider>(context);
  late LanguageProvider languageProvider =
      Provider.of<LanguageProvider>(context);
  String? saveDirectoryPath;

  bool showPlayer = false;
  String? audioPath;
  // final voiceSampleController = VoiceSampleController();

  final TextEditingController _voiceSampleNameController =
      TextEditingController();
  final TextEditingController _textPassageController = TextEditingController();

  @override
  void initState() {
    showPlayer = false;

    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _textPassageController.text =
          context.read<VoiceSampleProvider>().textPassage;
      context.read<VoiceSampleProvider>().addListener(_onTextPassageChanged);
    });
  }

  void _onTextPassageChanged() {
    voiceSampleProvider.setTextPassage(_textPassageController.text);
  }

  @override
  void dispose() {
    _textPassageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Voice Sample',
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Choose the language',
              style: TextStyle(color: Color(0xFF4E0189), fontSize: 16),
            ),
            ElevatedButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (context) {
                    return LanguageSheet(
                      selectedLanguage: languageProvider.chosenLanguage,
                      onLanguageSelected: (language) {
                        languageProvider.setChosenLanguage(language);
                      },
                    );
                  },
                );
              },
              child: Text(
                languageProvider.chosenLanguage.isEmpty
                    ? 'Select Language'
                    : languageProvider.chosenLanguage,
              ),
            ),
            const SizedBox(height: 20),
            FormContainerWidget(
              controller: _voiceSampleNameController,
              hintText: "Enter voice module name here",
              isPasswordField: false,
              fieldName: "Choose the voice module name",
              onChanged: (value) {
                voiceSampleProvider.setVoiceSampleName(value);
              },
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Read Text Passage',
                    style: TextStyle(color: Color(0xFF4E0189), fontSize: 16)),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(voiceSampleProvider.isEditing
                          ? Icons.check
                          : Icons.edit),
                      onPressed: () {
                        voiceSampleProvider.toggleEditing();
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.save),
                      onPressed: voiceSampleProvider.isEditing
                          ? () async {
                              await voiceSampleProvider.saveTextPassage(
                                  voiceSampleProvider.textPassage);
                            }
                          : null,
                    ),
                  ],
                ),
              ],
            ),
            TextField(
              controller: _textPassageController,
              readOnly: !voiceSampleProvider.isEditing,
              maxLines: 5,
              decoration: const InputDecoration(
                filled: true,
                fillColor: Color.fromARGB(255, 230, 228, 235),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF4E0189)),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // ElevatedButton(
            //   onPressed: () async {
            //     String? selectedDirectory =
            //         await FilePicker.platform.getDirectoryPath();
            //     if (selectedDirectory != null) {
            //       setState(() {
            //         saveDirectoryPath = selectedDirectory;
            //       });
            //     }
            //   },
            //   child: Text('Select Save Directory: ${saveDirectoryPath ?? ''}'),
            // ),
            const SizedBox(height: 20),
            const Text(
              'Record Voice Sample',
              style: TextStyle(color: Color(0xFF4E0189), fontSize: 16),
            ),
            const SizedBox(
              height: 20,
              width: double.infinity,
            ),
            SizedBox(
              width: 400,
              height: 200,
              child: showPlayer
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: AudioPlayer(
                        source: audioPath!,
                        onDelete: () {
                          setState(() => showPlayer = false);
                        },
                        voiceSampleName: voiceSampleProvider.voiceSampleName,
                        chosenLanguage: languageProvider.chosenLanguage,
                        onSave: (voiceSampleName, chosenLanguage, audioPath) {
                          voiceSampleProvider.getStoreVoiceSample(
                              voiceSampleName, chosenLanguage, audioPath);
                        },
                      ),
                    )
                  : Recorder(
                      onStop: (path) {
                        if (kDebugMode) print('Recorded file path: $path');
                        setState(() {
                          audioPath = path;
                          showPlayer = true;
                        });
                      },
                      voiceSampleName: voiceSampleProvider.voiceSampleName,
                      chosenLanguage: languageProvider.chosenLanguage,
                      saveDirectoryPath: saveDirectoryPath ??
                          voiceSampleProvider.directoryPath,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}


// 
