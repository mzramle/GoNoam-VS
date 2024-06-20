import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../controller/language_controller.dart';
import '../../../../controller/voice_sample_controller.dart';
import '../../../../helper/toast.dart';
import '../../../../provider/voice_sample_provider.dart';
import '../../../../model/text_passages_model.dart';
import '../../widgets/language_sheet.dart';
import '../../widgets/voice_recorder_widget.dart';

class CreateVoiceSamplePage extends StatelessWidget {
  const CreateVoiceSamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    final voiceSampleProvider = Provider.of<VoiceSampleProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);
    final voiceSampleController = VoiceSampleController();

    void saveTextPassage() async {
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) throw Exception('User not logged in');

        final textPassageModel = TextPassageModel(
          id: '',
          userId: user.uid,
          content: voiceSampleProvider.textPassage,
        );

        DocumentReference docRef = await FirebaseFirestore.instance
            .collection('text_passages')
            .add(textPassageModel.toJson());

        await docRef.update({'id': docRef.id});
        showSuccessToast('Text passage saved successfully!');
      } catch (e) {
        showErrorToast('Failed to save text passage: $e');
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Voice Sample'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Choose the language'),
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
            const Text('Choose the voice module name'),
            TextField(
              onChanged: voiceSampleProvider.setVoiceSampleName,
              decoration: const InputDecoration(
                labelText: 'Voice Sample Name',
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Read Text Passage'),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        voiceSampleProvider.isEditing
                            ? Icons.check
                            : Icons.edit,
                      ),
                      onPressed: () {
                        voiceSampleProvider.toggleEditing();
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.save),
                      onPressed: voiceSampleProvider.isEditing
                          ? saveTextPassage
                          : null,
                    ),
                  ],
                ),
              ],
            ),
            TextField(
              controller: TextEditingController(
                text: voiceSampleProvider.textPassage,
              ),
              onChanged: voiceSampleProvider.setTextPassage,
              readOnly: !voiceSampleProvider.isEditing,
              maxLines: 5,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Column(
                children: [
                  VoiceRecorderWidget(
                    onSave: (File audioFile) async {
                      try {
                        await voiceSampleController.saveVoiceSample(
                          audioFile,
                          voiceSampleProvider.voiceSampleName,
                          languageProvider.chosenLanguage,
                          voiceSampleProvider.textPassage,
                        );
                        showSuccessToast('Voice Sample Saved Successfully');
                      } catch (e) {
                        showErrorToast('Error: $e');
                      }
                    },
                    onTimeUpdate: (String recordingTime) {
                      voiceSampleProvider.setRecordingTime(recordingTime);
                    },
                  ),
                  const SizedBox(height: 20),
                  Text('Recording Time: ${voiceSampleProvider.recordingTime}'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
