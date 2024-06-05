import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../controller/voice_sample_controller.dart';
import '../../widgets/form_container_widget.dart';
import '../translation/language_controller.dart';

class CreateVoiceSamplePage extends StatelessWidget {
  const CreateVoiceSamplePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final languageController = Get.put(LanguageController());
    final voiceSampleController = Get.put(VoiceSampleController());
    final _voiceNameController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Voice Sample'),
        foregroundColor: Colors.white,
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Choose the language of the voice',
                style: TextStyle(color: Color(0xFF4E0189), fontSize: 16),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  Get.bottomSheet(
                    Container(
                      height: 700,
                      color: Colors.white,
                      child: ListView.builder(
                        itemCount: languageController.languages.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(languageController.languages[index]),
                            onTap: () {
                              languageController.setChosenLanguage(
                                  languageController.languages[index]);
                              Navigator.of(context).pop();
                            },
                          );
                        },
                      ),
                    ),
                  );
                },
                child: Obx(
                  () => Text(
                    languageController.chosenLanguage.value.isEmpty
                        ? 'Select Language'
                        : languageController.chosenLanguage.value,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              FormContainerWidget(
                controller: _voiceNameController,
                hintText: "Enter voice module name here",
                isPasswordField: false,
                fieldName: "Enter Voice Module Name",
                onChanged: (value) {
                  voiceSampleController.setVoiceSampleName(value);
                },
              ),
              const SizedBox(height: 20),
              const Text(
                'Read Text Passages',
                style: TextStyle(color: Color(0xFF4E0189), fontSize: 16),
              ),
              const SizedBox(height: 10),
              Obx(() {
                return Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: TextEditingController()
                          ..text = voiceSampleController.textPassage.value,
                        maxLines: 10,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          voiceSampleController.setTextPassage(value);
                        },
                        enabled: voiceSampleController.isRecording.value,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        voiceSampleController.isRecording.value
                            ? Icons.save
                            : Icons.edit,
                      ),
                      onPressed: () {
                        voiceSampleController.isRecording.value =
                            !voiceSampleController.isRecording.value;
                      },
                    ),
                  ],
                );
              }),
              const SizedBox(height: 10),
              const Center(
                  child: Text('It is optional to read text',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 12))),
              const Spacer(),
              Center(
                child: Obx(() {
                  return ElevatedButton(
                    onPressed: voiceSampleController.toggleRecording,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff003366),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                        ),
                        minimumSize: const Size(30, 70)),
                    child: Icon(
                      voiceSampleController.isRecording.value
                          ? Icons.stop
                          : Icons.mic,
                      color: Colors.white,
                      size: 30,
                    ),
                  );
                }),
              ),
              const SizedBox(height: 20),
              const Center(
                  child: Text('Press again to stop',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 12))),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    voiceSampleController.saveVoiceSample();
                  },
                  child: const Text('Save Voice Sample'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
