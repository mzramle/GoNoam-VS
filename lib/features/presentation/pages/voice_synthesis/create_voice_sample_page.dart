// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// import '../../../../controller/voice_sample_controller.dart';
// import '../../widgets/form_container_widget.dart';
// import '../translation/language_controller.dart';

// class CreateVoiceSamplePage extends StatelessWidget {
//   const CreateVoiceSamplePage({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final languageController = Get.put(LanguageController());
//     final voiceSampleController = Get.put(VoiceSampleController());
//     final _voiceNameController = TextEditingController();

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Create Voice Sample'),
//         foregroundColor: Colors.white,
//         backgroundColor: Colors.blue,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: () {
//             Navigator.of(context).pop();
//           },
//         ),
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Text(
//                 'Choose the language of the voice',
//                 style: TextStyle(color: Color(0xFF4E0189), fontSize: 16),
//               ),
//               const SizedBox(height: 10),
//               ElevatedButton(
//                 onPressed: () {
//                   Get.bottomSheet(
//                     Container(
//                       height: 700,
//                       color: Colors.white,
//                       child: ListView.builder(
//                         itemCount: languageController.languages.length,
//                         itemBuilder: (context, index) {
//                           return ListTile(
//                             title: Text(languageController.languages[index]),
//                             onTap: () {
//                               languageController.setChosenLanguage(
//                                   languageController.languages[index]);
//                               Navigator.of(context).pop();
//                             },
//                           );
//                         },
//                       ),
//                     ),
//                   );
//                 },
//                 child: Obx(
//                   () => Text(
//                     languageController.chosenLanguage.value.isEmpty
//                         ? 'Select Language'
//                         : languageController.chosenLanguage.value,
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 20),
//               FormContainerWidget(
//                 controller: _voiceNameController,
//                 hintText: "Enter voice module name here",
//                 isPasswordField: false,
//                 fieldName: "Enter Voice Module Name",
//                 onChanged: (value) {
//                   voiceSampleController.setVoiceSampleName(value);
//                 },
//               ),
//               const SizedBox(height: 20),
//               const Text(
//                 'Read Text Passages',
//                 style: TextStyle(color: Color(0xFF4E0189), fontSize: 16),
//               ),
//               const SizedBox(height: 10),
//               Obx(() {
//                 return Row(
//                   children: [
//                     Expanded(
//                       child: TextFormField(
//                         controller: TextEditingController()
//                           ..text = voiceSampleController.textPassage.value,
//                         maxLines: 10,
//                         decoration: const InputDecoration(
//                           border: OutlineInputBorder(),
//                         ),
//                         onChanged: (value) {
//                           voiceSampleController.setTextPassage(value);
//                         },
//                         enabled: voiceSampleController.isRecording.value,
//                       ),
//                     ),
//                     IconButton(
//                       icon: Icon(
//                         voiceSampleController.isRecording.value
//                             ? Icons.save
//                             : Icons.edit,
//                       ),
//                       onPressed: () {
//                         voiceSampleController.isRecording.value =
//                             !voiceSampleController.isRecording.value;
//                       },
//                     ),
//                   ],
//                 );
//               }),
//               const SizedBox(height: 10),
//               const Center(
//                   child: Text('It is optional to read text',
//                       style: TextStyle(
//                           fontWeight: FontWeight.bold, fontSize: 12))),
//               const Spacer(),
//               Center(
//                 child: Obx(() {
//                   return ElevatedButton(
//                     onPressed: voiceSampleController.toggleRecording,
//                     style: ElevatedButton.styleFrom(
//                         backgroundColor: const Color(0xff003366),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(100),
//                         ),
//                         minimumSize: const Size(30, 70)),
//                     child: Icon(
//                       voiceSampleController.isRecording.value
//                           ? Icons.stop
//                           : Icons.mic,
//                       color: Colors.white,
//                       size: 30,
//                     ),
//                   );
//                 }),
//               ),
//               const SizedBox(height: 20),
//               const Center(
//                   child: Text('Press again to stop',
//                       style: TextStyle(
//                           fontWeight: FontWeight.bold, fontSize: 12))),
//               const SizedBox(height: 20),
//               Center(
//                 child: ElevatedButton(
//                   onPressed: () {
//                     voiceSampleController.saveVoiceSample();
//                   },
//                   child: const Text('Save Voice Sample'),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

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
