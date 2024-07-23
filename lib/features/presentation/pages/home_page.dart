import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:gonoam_v1/features/presentation/widgets/orange_button.dart';
import 'package:gonoam_v1/provider/voice_profile_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
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
  late Size mq;

  late TranslateProvider translateProvider;
  late VoiceSampleProvider voiceSampleProvider;
  late VoiceProfileProvider voiceProfileProvider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VoiceProfileProvider>().fetchVoiceModelDataStream();
      context.read<TranslateProvider>().resultC;
      voiceProfileProvider = context.read<VoiceProfileProvider>();
      translateProvider = context.read<TranslateProvider>();
    });
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    Get.offAllNamed('/login');
  }

  @override
  void dispose() {
    voiceSampleProvider.dispose();
    translateProvider.textC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;
    final translateProvider = Provider.of<TranslateProvider>(context);
    final voiceSampleProvider = Provider.of<VoiceSampleProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'GoNoam Translation',
          style: GoogleFonts.robotoCondensed(fontSize: 30, color: Colors.white),
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
                            ? 'English'
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
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF4E0189)),
                      ),
                      filled: true,
                      fillColor: const Color.fromARGB(172, 239, 237, 244),
                    ),
                  ),
                ),
                if (translateProvider.status == Status.loading)
                  const CustomLoadingTranslate(),
                if (translateProvider.status == Status.complete)
                  Padding(
                    padding: EdgeInsets.symmetric(
                        vertical: mq.height * .02, horizontal: mq.width * .05),
                    child: Column(
                      children: [
                        TextFormField(
                          controller: translateProvider.resultC,
                          minLines: 6,
                          maxLines: 10,
                          readOnly: true,
                          decoration: InputDecoration(
                            suffixIcon: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  onPressed: () {
                                    voiceProfileProvider.decideAndExecuteTTS(
                                        translateProvider.resultC.text,
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
                            focusedBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFF4E0189)),
                            ),
                            filled: true,
                            fillColor: const Color.fromARGB(172, 239, 237, 244),
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
                          onResult: (text) async {
                            translateProvider.textC.text = text;
                            // await Future.delayed(
                            //     const Duration(milliseconds: 100));
                            await translateProvider.googleTranslate();
                            voiceProfileProvider.decideAndExecuteTTS(
                                translateProvider.resultC.text,
                                voiceSampleProvider.chosenLanguage);
                          },
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
