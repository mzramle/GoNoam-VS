import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../../provider/voice_profile_provider.dart';
import '../../widgets/orange_button.dart';

class VoiceSynthesisMainPage extends StatefulWidget {
  const VoiceSynthesisMainPage({super.key});

  @override
  State<VoiceSynthesisMainPage> createState() => _VoiceSynthesisMainPageState();
}

class _VoiceSynthesisMainPageState extends State<VoiceSynthesisMainPage> {
  TextEditingController textController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    Get.offAllNamed('/login');
    dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Voice Synthesis',
            style:
                GoogleFonts.robotoCondensed(fontSize: 30, color: Colors.white)),
        backgroundColor: Colors.blue,
        automaticallyImplyLeading: false,
        actions: [
          PopupMenuButton<String>(
            onSelected: (String result) {
              if (result == 'user_profile') {
                Get.toNamed('/user_profile');
              } else if (result == 'logout') {
                _signOut();
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'user_profile',
                child: Text('User Profile'),
              ),
              const PopupMenuItem<String>(
                value: 'logout',
                child: Text('Log Out'),
              ),
            ],
            icon: const Icon(Icons.settings_applications_rounded,
                color: Colors.white, size: 40),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Center(
              child: OrangeButton(
                text: 'Adjust Voice',
                onPressed: () {
                  Navigator.of(context).pushNamed('/adjust_voice_profile_page');
                },
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: OrangeButton(
                text: 'Create Voice Sample',
                onPressed: () {
                  Navigator.of(context).pushNamed('/create_voice_sample_page');
                },
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: OrangeButton(
                text: 'Trained Voice Library Work',
                onPressed: () {
                  Navigator.of(context)
                      .pushNamed('/trained_voice_library_work_page');
                },
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: OrangeButton(
                text: 'Delete Voices',
                onPressed: () {
                  Navigator.of(context).pushNamed('/delete_voices_page');
                },
              ),
            ),
            const SizedBox(height: 30),
            const Text('Enter some text here to Generate TTS',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(
              width: 300,
              child: TextField(
                controller: textController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'To generate TTS, click on the mic...',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear, color: Colors.redAccent),
                    onPressed: () {
                      textController.clear(); // Clears the text
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Column(
              children: [
                const SizedBox(height: 10),
                Container(
                  alignment: Alignment.bottomLeft,
                  margin: const EdgeInsets.only(left: 50.0),
                  child: const Text('Current Voice Model',
                      style: TextStyle(fontSize: 18, color: Colors.black),
                      textAlign: TextAlign.start),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 30.0),
                  child: const Divider(color: Colors.black, thickness: 2.0),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      StreamBuilder<Map<String, dynamic>>(
                        stream: Provider.of<VoiceProfileProvider>(context,
                                listen: false)
                            .fetchVoiceModelDataStream(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                                  ConnectionState.active ||
                              snapshot.connectionState ==
                                  ConnectionState.done) {
                            if (snapshot.hasData) {
                              return ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xff003366),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(150),
                                  ),
                                  minimumSize: const Size(20, 70),
                                ),
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.mic,
                                    color: Colors.white,
                                    semanticLabel: 'Generate TTS',
                                  ),
                                  onPressed: () {
                                    Map<String, dynamic> voiceModelData =
                                        snapshot.data!;
                                    Provider.of<VoiceProfileProvider>(context,
                                            listen: false)
                                        .generateCurrentTTS(
                                      textInput: textController.text,
                                      modelData: voiceModelData,
                                    );
                                  },
                                ),
                              );
                            } else if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            } else {
                              return ElevatedButton(
                                onPressed: null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xff003366),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(150),
                                  ),
                                  minimumSize: const Size(20, 70),
                                ),
                                child: const Icon(
                                  Icons.mic,
                                  color: Colors.white,
                                  semanticLabel: 'Generate TTS',
                                ),
                              );
                            }
                          } else {
                            return const CircularProgressIndicator();
                          }
                        },
                      ),
                      StreamBuilder<Map<String, dynamic>>(
                        stream: Provider.of<VoiceProfileProvider>(context,
                                listen: false)
                            .fetchVoiceModelDataStream(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          } else if (snapshot.hasData) {
                            String modelName = snapshot.data!['model_name'] ??
                                'Default Model Name';
                            String modelLanguage =
                                snapshot.data!['model_language'] ??
                                    'Default Language';
                            return Expanded(
                              child: Column(
                                children: [
                                  ElevatedButton(
                                    onPressed: () {},
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xff003366),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 15),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    child: Text(
                                      modelName,
                                      style: const TextStyle(
                                          fontSize: 18, color: Colors.white),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  ElevatedButton(
                                    onPressed: () {},
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.grey[200],
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 50, vertical: 15),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    child: Text(
                                      modelLanguage,
                                      style: const TextStyle(
                                          fontSize: 18, color: Colors.black),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else {
                            return const Text('No data available');
                          }
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 60,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
