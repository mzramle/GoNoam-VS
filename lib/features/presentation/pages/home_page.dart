import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:gonoam_v1/features/presentation/widgets/orange_button.dart';
import 'package:provider/provider.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../../../provider/language_provider.dart';
import '../../../provider/translator_provider.dart';
import '../../../provider/voice_sample_provider.dart';
import '../widgets/custom_loading.dart';
import '../widgets/language_sheet.dart';
import '../widgets/speech_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late FlutterTts flutterTts = FlutterTts();
  late Size mq;

  @override
  void initState() {
    super.initState();
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

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;
    final translateProvider = Provider.of<TranslateProvider>(context);
    final voiceSampleProvider = Provider.of<VoiceSampleProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'GoNoam Translation',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        automaticallyImplyLeading: false,
        actions: [
          PopupMenuButton<String>(
            onSelected: (String result) {
              if (result == 'user_profile') {
                Navigator.of(context).pushNamed('/user_profile');
              } else if (result == 'logout') {
                _signOut();
              } else if (result == 'settings') {
                Navigator.of(context).pushNamed('/settings');
              } else if (result == 'stt_test') {
                Navigator.of(context).pushNamed('/stt_test');
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
              const PopupMenuItem<String>(
                value: 'settings',
                child: Text('Setting'),
              ),
              const PopupMenuItem<String>(
                value: 'stt_test',
                child: Text('STT_Widget'),
              ),
            ],
            icon: const Icon(Icons.person, color: Colors.white),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding:
                  EdgeInsets.only(top: mq.height * .02, bottom: mq.height * .1),
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          builder: (context) {
                            return LanguageSheet(
                              selectedLanguage: languageProvider.chosenLanguage,
                              onLanguageSelected: (language) {
                                languageProvider.setChosenLanguage(language);
                                translateProvider.from = language;
                              },
                            );
                          },
                        );
                      },
                      borderRadius: const BorderRadius.all(Radius.circular(15)),
                      child: Container(
                        height: 50,
                        width: mq.width * .4,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.blue),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(15)),
                        ),
                        child: Text(languageProvider.chosenLanguage.isEmpty
                            ? 'Auto'
                            : languageProvider.chosenLanguage),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        final temp = languageProvider.chosenLanguage;
                        languageProvider.setChosenLanguage(
                            voiceSampleProvider.chosenLanguage);
                        voiceSampleProvider.setChosenLanguage(temp);
                        translateProvider.swapLanguages();
                      },
                      icon: Icon(
                        Icons.swap_horiz,
                        color: languageProvider.chosenLanguage.isNotEmpty &&
                                voiceSampleProvider.chosenLanguage.isNotEmpty
                            ? Colors.blue
                            : Colors.grey,
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          builder: (context) {
                            return LanguageSheet(
                              selectedLanguage:
                                  voiceSampleProvider.chosenLanguage,
                              onLanguageSelected: (language) {
                                voiceSampleProvider.setChosenLanguage(language);
                                translateProvider.to = language;
                              },
                            );
                          },
                        );
                      },
                      borderRadius: const BorderRadius.all(Radius.circular(15)),
                      child: Container(
                        height: 50,
                        width: mq.width * .4,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.blue),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(15)),
                        ),
                        child: Text(
                          voiceSampleProvider.chosenLanguage.isEmpty
                              ? 'Select Language'
                              : voiceSampleProvider.chosenLanguage,
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                      vertical: mq.height * .03, horizontal: mq.width * .05),
                  child: TextFormField(
                    controller: translateProvider.textC,
                    minLines: 6,
                    maxLines: 10,
                    decoration: InputDecoration(
                      suffixIcon: IconButton(
                        onPressed: translateProvider.textC.clear,
                        icon: const Icon(Icons.clear, color: Colors.red),
                      ),
                      hintText: 'Type here...',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15)),
                    ),
                  ),
                ),
                if (translateProvider.status == Status.loading)
                  const CustomLoading(),
                if (translateProvider.status == Status.complete)
                  Padding(
                    padding: EdgeInsets.symmetric(
                        vertical: mq.height * .02, horizontal: mq.width * .05),
                    child: Column(
                      children: [
                        TextFormField(
                          controller: translateProvider.resultC,
                          minLines: 6, // Minimum lines for the input
                          maxLines: 10, // Allows the input to grow,
                          readOnly: true,
                          decoration: InputDecoration(
                            suffixIcon: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  onPressed: () {
                                    _speakText(translateProvider.resultC.text,
                                        voiceSampleProvider.chosenLanguage);
                                  },
                                  icon: const Icon(Icons.volume_up,
                                      color: Colors.blue),
                                ),
                                IconButton(
                                  onPressed: () {
                                    Clipboard.setData(ClipboardData(
                                            text:
                                                translateProvider.resultC.text))
                                        .then((value) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                            content:
                                                Text('Copied to Clipboard')),
                                      );
                                    });
                                  },
                                  icon: const Icon(Icons.copy,
                                      color: Colors.blue),
                                ),
                              ],
                            ),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15)),
                          ),
                        ),
                      ],
                    ),
                  ),
                SizedBox(height: mq.height * .02),
                Stack(
                  children: [
                    Column(
                      children: [
                        Center(
                          child: OrangeButton(
                            onPressed: translateProvider.googleTranslate,
                            text: 'Translate',
                          ),
                        ),
                        const SizedBox(height: 20),
                        SpeechWidget(
                          onResult: (text) {
                            translateProvider.textC.text = text;
                            translateProvider.googleTranslate;
                          },
                          icon: const Icon(Icons.mic,
                              size: 48, color: Colors.orange),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
