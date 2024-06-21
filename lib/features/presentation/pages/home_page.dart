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

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import '../../../provider/voice_sample_provider.dart';
import '../../../controller/language_controller.dart';
import '../../../controller/translator_controller.dart';
import '../../../helper/toast.dart';
import '../widgets/custom_loading.dart';
import '../widgets/language_sheet.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late TranslateController _c;
  late stt.SpeechToText _speech;
  late FlutterTts flutterTts;
  late Size mq;

  @override
  void initState() {
    super.initState();
    _c = TranslateController();
    _speech = stt.SpeechToText();
    flutterTts = FlutterTts();
  }

  void _startListening() async {
    try {
      if (!_speech.isListening) {
        bool available = await _speech.initialize(
          onStatus: (status) {
            if (status == 'listening') {
              showToast(message: 'Listening...');
            } else if (status == 'done') {
              showSuccessToast('Done');
            }
          },
          onError: (error) {
            showErrorToast('error: $error');
            _speech.stop();
          },
        );

        if (available) {
          _speech.listen(
            onResult: (result) {
              setState(() {
                _c.textC.text = result.recognizedWords;
              });
            },
          );
        } else {
          showErrorToast('The user has denied the use of speech recognition.');
        }
      }
    } catch (e) {
      showErrorToast('Error initializing speech recognition: $e');
    }
  }

  Future<void> _speakText(String text, String languageCode) async {
    await flutterTts.setLanguage(languageCode);
    await flutterTts.setPitch(1);
    await flutterTts.speak(text);
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    Get.offAllNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;

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
                Get.toNamed('/user_profile');
              } else if (result == 'logout') {
                _signOut();
              } else if (result == 'settings') {
                Get.toNamed('/settings');
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
                                _c.from.value = language;
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
                        _c.swapLanguages();
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
                                _c.to.value = language;
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
                        child: Text(voiceSampleProvider.chosenLanguage.isEmpty
                            ? 'To'
                            : voiceSampleProvider.chosenLanguage),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: mq.width * .04, vertical: mq.height * .035),
                  child: Stack(
                    children: [
                      TextFormField(
                        controller: _c.textC,
                        minLines: 5,
                        maxLines: null,
                        onTapOutside: (e) => FocusScope.of(context).unfocus(),
                        decoration: const InputDecoration(
                          hintText: 'Translate anything you want...',
                          hintStyle: TextStyle(fontSize: 13.5),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: IconButton(
                          onPressed: () => _speakText(_c.textC.text,
                              _c.from.value.isEmpty ? 'en' : _c.from.value),
                          icon: const Icon(Icons.volume_up),
                        ),
                      ),
                    ],
                  ),
                ),
                Obx(() => _translateResult()),
                SizedBox(height: mq.height * .04),
                Column(
                  children: [
                    ElevatedButton(
                      onPressed: _c.googleTranslate,
                      style: ButtonStyle(
                        foregroundColor:
                            WidgetStateProperty.all<Color>(Colors.white),
                        backgroundColor: WidgetStateProperty.all<Color>(
                            const Color.fromARGB(255, 255, 123, 0)),
                        shape:
                            WidgetStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18.0),
                          ),
                        ),
                      ),
                      child: const Text('Translate'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _startListening,
        heroTag: 'home_page_v1_voice_input',
        child: const Icon(Icons.mic),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _translateResult() {
    switch (_c.status.value) {
      case Status.none:
        return const SizedBox();
      case Status.complete:
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: mq.width * .04),
          child: Stack(
            children: [
              TextFormField(
                controller: _c.resultC,
                maxLines: null,
                onTapOutside: (e) => FocusScope.of(context).unfocus(),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 50,
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: _c.resultC.text));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Copied to Clipboard')),
                        );
                      },
                      icon: const Icon(Icons.copy),
                    ),
                    IconButton(
                      onPressed: () => _speakText(_c.resultC.text, _c.to.value),
                      icon: const Icon(Icons.volume_up),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      case Status.loading:
        return const Align(child: CustomLoading());
    }
  }
}
