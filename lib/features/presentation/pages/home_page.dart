// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// import '../../../controller/translator_controller.dart';
// import '../../../helper/global.dart';
// import '../widgets/custom_btn.dart';
// import '../widgets/custom_loading.dart';
// import '../widgets/language_sheet.dart';

// class HomePage extends StatefulWidget {
//   const HomePage({super.key});

//   @override
//   State<HomePage> createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   final _c = TranslateController();

//   @override
//   Widget build(BuildContext context) {
//     mq = MediaQuery.sizeOf(context);

//     return Scaffold(
//       //app bar
//       appBar: AppBar(
//         title: const Text('GoNoam Translation'),
//       ),

//       //body
//       body: ListView(
//         physics: const BouncingScrollPhysics(),
//         padding: EdgeInsets.only(top: mq.height * .02, bottom: mq.height * .1),
//         children: [
//           Row(mainAxisAlignment: MainAxisAlignment.center, children: [
//             //from language
//             InkWell(
//               onTap: () => Get.bottomSheet(LanguageSheet(c: _c, s: _c.from)),
//               borderRadius: const BorderRadius.all(Radius.circular(15)),
//               child: Container(
//                 height: 50,
//                 width: mq.width * .4,
//                 alignment: Alignment.center,
//                 decoration: BoxDecoration(
//                     border: Border.all(color: Colors.blue),
//                     borderRadius: const BorderRadius.all(Radius.circular(15))),
//                 child:
//                     Obx(() => Text(_c.from.isEmpty ? 'Auto' : _c.from.value)),
//               ),
//             ),

//             //swipe language btn
//             IconButton(
//                 onPressed: _c.swapLanguages,
//                 icon: Obx(
//                   () => Icon(
//                     CupertinoIcons.repeat,
//                     color: _c.to.isNotEmpty && _c.from.isNotEmpty
//                         ? Colors.blue
//                         : Colors.grey,
//                   ),
//                 )),

//             //to language
//             InkWell(
//               onTap: () => Get.bottomSheet(LanguageSheet(c: _c, s: _c.to)),
//               borderRadius: const BorderRadius.all(Radius.circular(15)),
//               child: Container(
//                 height: 50,
//                 width: mq.width * .4,
//                 alignment: Alignment.center,
//                 decoration: BoxDecoration(
//                     border: Border.all(color: Colors.blue),
//                     borderRadius: const BorderRadius.all(Radius.circular(15))),
//                 child: Obx(() => Text(_c.to.isEmpty ? 'To' : _c.to.value)),
//               ),
//             ),
//           ]),

//           //text field
//           Padding(
//             padding: EdgeInsets.symmetric(
//                 horizontal: mq.width * .04, vertical: mq.height * .035),
//             child: TextFormField(
//               controller: _c.textC,
//               minLines: 5,
//               maxLines: null,
//               onTapOutside: (e) => FocusScope.of(context).unfocus(),
//               decoration: const InputDecoration(
//                   hintText: 'Translate anything you want...',
//                   hintStyle: TextStyle(fontSize: 13.5),
//                   border: OutlineInputBorder(
//                       borderRadius: BorderRadius.all(Radius.circular(10)))),
//             ),
//           ),

//           //result field
//           Obx(() => _translateResult()),

//           //for adding some space
//           SizedBox(height: mq.height * .04),

//           //translate btn
//           CustomBtn(
//             onTap: _c.googleTranslate,
//             // onTap: _c.translate,
//             text: 'Translate',
//           )
//         ],
//       ),
//     );
//   }

//   Widget _translateResult() => switch (_c.status.value) {
//         Status.none => const SizedBox(),
//         Status.complete => Padding(
//             padding: EdgeInsets.symmetric(horizontal: mq.width * .04),
//             child: TextFormField(
//               controller: _c.resultC,
//               maxLines: null,
//               onTapOutside: (e) => FocusScope.of(context).unfocus(),
//               decoration: const InputDecoration(
//                   border: OutlineInputBorder(
//                       borderRadius: BorderRadius.all(Radius.circular(10)))),
//             ),
//           ),
//         Status.loading => const Align(child: CustomLoading())
//       };
// }

// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:get/get.dart';
// import 'package:speech_to_text/speech_to_text.dart' as stt;
// import 'package:flutter_tts/flutter_tts.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// import '../../../controller/translator_controller.dart';
// import '../../../helper/global.dart';
// import '../../../helper/toast.dart';
// import '../widgets/custom_loading.dart';
// import '../widgets/language_sheet.dart';

// class HomePage extends StatefulWidget {
//   const HomePage({
//     Key? key,
//   }) : super(key: key);

//   @override
//   State<HomePage> createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   final _c = TranslateController();
//   final stt.SpeechToText _speech = stt.SpeechToText();
//   final FlutterTts flutterTts = FlutterTts();

//   void _startListening() async {
//     if (!_speech.isListening) {
//       bool available = await _speech.initialize(
//         onStatus: (status) => showToast(message: 'status: $status'),
//         onError: (error) => showErrorToast('error: $error'),
//       );

//       if (available) {
//         _speech.listen(
//           onResult: (result) => setState(() {
//             _c.textC.text = result.recognizedWords;
//           }),
//         );
//       }
//     }
//   }

//   Future<void> _speakText(String text, String languageCode) async {
//     await flutterTts.setLanguage(languageCode);
//     await flutterTts.setPitch(1);
//     await flutterTts.speak(text);
//   }

//   Future<void> _signOut() async {
//     await FirebaseAuth.instance.signOut();
//     Get.offAllNamed('/login');
//   }

//   @override
//   Widget build(BuildContext context) {
//     mq = MediaQuery.sizeOf(context);

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('GoNoam Translation',
//             style: TextStyle(color: Colors.white)),
//         backgroundColor: Colors.blue,
//         automaticallyImplyLeading: false,
//         actions: [
//           PopupMenuButton<String>(
//             onSelected: (String result) {
//               if (result == 'user_profile') {
//                 Get.toNamed('/user_profile');
//               } else if (result == 'logout') {
//                 _signOut();
//               } else if (result == 'settings') {
//                 Get.toNamed('/settings');
//               }
//               // } else if (result == 'example_crd') {
//               //   Get.toNamed('/example_crd');
//               // }
//             },
//             itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
//               const PopupMenuItem<String>(
//                 value: 'user_profile',
//                 child: Text('User Profile'),
//               ),
//               const PopupMenuItem<String>(
//                 value: 'logout',
//                 child: Text('Log Out'),
//               ),
//               const PopupMenuItem<String>(
//                 value: 'settings',
//                 child: Text('Setting'),
//               ),
//               // const PopupMenuItem<String>(
//               //   value: 'example_crd',
//               //   child: Text('Example CRD'),
//               // ),
//             ],
//             icon: const Icon(Icons.person, color: Colors.white),
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: ListView(
//               physics: const BouncingScrollPhysics(),
//               padding:
//                   EdgeInsets.only(top: mq.height * .02, bottom: mq.height * .1),
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     InkWell(
//                       onTap: () =>
//                           Get.bottomSheet(LanguageSheet(c: _c, s: _c.from)),
//                       borderRadius: const BorderRadius.all(Radius.circular(15)),
//                       child: Container(
//                         height: 50,
//                         width: mq.width * .4,
//                         alignment: Alignment.center,
//                         decoration: BoxDecoration(
//                           border: Border.all(color: Colors.blue),
//                           borderRadius:
//                               const BorderRadius.all(Radius.circular(15)),
//                         ),
//                         child: Obx(() =>
//                             Text(_c.from.isEmpty ? 'Auto' : _c.from.value)),
//                       ),
//                     ),
//                     IconButton(
//                       onPressed: _c.swapLanguages,
//                       icon: Obx(
//                         () => Icon(
//                           CupertinoIcons.repeat,
//                           color: _c.to.isNotEmpty && _c.from.isNotEmpty
//                               ? Colors.blue
//                               : Colors.grey,
//                         ),
//                       ),
//                     ),
//                     InkWell(
//                       onTap: () =>
//                           Get.bottomSheet(LanguageSheet(c: _c, s: _c.to)),
//                       borderRadius: const BorderRadius.all(Radius.circular(15)),
//                       child: Container(
//                         height: 50,
//                         width: mq.width * .4,
//                         alignment: Alignment.center,
//                         decoration: BoxDecoration(
//                           border: Border.all(color: Colors.blue),
//                           borderRadius:
//                               const BorderRadius.all(Radius.circular(15)),
//                         ),
//                         child:
//                             Obx(() => Text(_c.to.isEmpty ? 'To' : _c.to.value)),
//                       ),
//                     ),
//                   ],
//                 ),
//                 Padding(
//                   padding: EdgeInsets.symmetric(
//                       horizontal: mq.width * .04, vertical: mq.height * .035),
//                   child: Stack(
//                     children: [
//                       TextFormField(
//                         controller: _c.textC,
//                         minLines: 5,
//                         maxLines: null,
//                         onTapOutside: (e) => FocusScope.of(context).unfocus(),
//                         decoration: const InputDecoration(
//                           hintText: 'Translate anything you want...',
//                           hintStyle: TextStyle(fontSize: 13.5),
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.all(Radius.circular(10)),
//                           ),
//                         ),
//                       ),
//                       Positioned(
//                         bottom: 0,
//                         right: 0,
//                         child: IconButton(
//                           onPressed: () => _speakText(_c.textC.text,
//                               _c.from.value.isEmpty ? 'en' : _c.from.value),
//                           icon: const Icon(Icons.volume_up),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 Obx(() => _translateResult()),
//                 SizedBox(height: mq.height * .04),
//                 Column(
//                   children: [
//                     ElevatedButton(
//                         onPressed: _c.googleTranslate,
//                         style: ButtonStyle(
//                           foregroundColor:
//                               MaterialStateProperty.all<Color>(Colors.white),
//                           backgroundColor: MaterialStateProperty.all<Color>(
//                               const Color.fromARGB(255, 255, 123, 0)),
//                           shape:
//                               MaterialStateProperty.all<RoundedRectangleBorder>(
//                             RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(18.0),
//                             ),
//                           ),
//                         ),
//                         child: const Text('Translate')),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _startListening,
//         heroTag: 'home_page_v1_voice_input',
//         child: const Icon(Icons.mic),
//       ),
//       floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
//     );
//   }

//   Widget _translateResult() {
//     switch (_c.status.value) {
//       case Status.none:
//         return const SizedBox();
//       case Status.complete:
//         return Padding(
//           padding: EdgeInsets.symmetric(horizontal: mq.width * .04),
//           child: Stack(
//             children: [
//               TextFormField(
//                 controller: _c.resultC,
//                 maxLines: null,
//                 onTapOutside: (e) => FocusScope.of(context).unfocus(),
//                 decoration: const InputDecoration(
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.all(Radius.circular(10)),
//                   ),
//                 ),
//               ),
//               Positioned(
//                 bottom: 0,
//                 right: 50,
//                 child: Row(
//                   children: [
//                     IconButton(
//                       onPressed: () {
//                         Clipboard.setData(ClipboardData(text: _c.resultC.text));
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           const SnackBar(content: Text('Copied to Clipboard')),
//                         );
//                       },
//                       icon: const Icon(Icons.copy),
//                     ),
//                     IconButton(
//                       onPressed: () => _speakText(_c.resultC.text, _c.to.value),
//                       icon: const Icon(Icons.volume_up),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         );
//       case Status.loading:
//         return const Align(child: CustomLoading());
//     }
//   }
// }

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
                    maxLines: null,
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
                          maxLines: null,
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
                Column(
                  children: [
                    OrangeButton(
                      onPressed: translateProvider.googleTranslate,
                      text: 'Translate',
                    ),
                    SizedBox(height: mq.height * .10),
                    Positioned(
                      bottom: 16,
                      left: MediaQuery.of(context).size.width / 2 - 24,
                      child: SpeechWidget(
                        onResult: (text) {
                          translateProvider.textC.text = text;
                        },
                        icon: const Icon(Icons.mic,
                            size: 48, color: Colors.orange),
                      ),
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
