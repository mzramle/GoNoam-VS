import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../controller/translator_controller.dart';
import '../../../helper/global.dart';
import '../widgets/custom_btn.dart';
import '../widgets/custom_loading.dart';
import '../widgets/language_sheet.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _c = TranslateController();
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts flutterTts = FlutterTts();

  void _startListening() async {
    if (!_speech.isListening) {
      bool available = await _speech.initialize(
        onStatus: (status) => print('status: $status'),
        onError: (error) => print('error: $error'),
      );

      if (available) {
        _speech.listen(
          onResult: (result) => setState(() {
            _c.textC.text = result.recognizedWords;
          }),
        );
      }
    }
  }

  Future<void> _speakOriginalText() async {
    if (_c.textC.text.isNotEmpty) {
      await flutterTts.setLanguage('en');
      await flutterTts.setPitch(1);
      await flutterTts.speak(_c.textC.text);
    }
  }

  Future<void> _speakTranslatedText() async {
    if (_c.resultC.text.isNotEmpty) {
      await flutterTts.setLanguage(_c.to.value);
      await flutterTts.setPitch(1);
      await flutterTts.speak(_c.resultC.text);
    }
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    Get.offAllNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.sizeOf(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('GoNoam Translation'),
        automaticallyImplyLeading: false,
        actions: [
          PopupMenuButton<String>(
            onSelected: (String result) {
              if (result == 'update_profile') {
                Get.toNamed('/update_profile');
              } else if (result == 'logout') {
                _signOut();
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'update_profile',
                child: Text('Update Profile'),
              ),
              const PopupMenuItem<String>(
                value: 'logout',
                child: Text('Log Out'),
              ),
            ],
            icon: const Icon(Icons.person),
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
                      onTap: () =>
                          Get.bottomSheet(LanguageSheet(c: _c, s: _c.from)),
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
                        child: Obx(() =>
                            Text(_c.from.isEmpty ? 'Auto' : _c.from.value)),
                      ),
                    ),
                    IconButton(
                      onPressed: _c.swapLanguages,
                      icon: Obx(
                        () => Icon(
                          CupertinoIcons.repeat,
                          color: _c.to.isNotEmpty && _c.from.isNotEmpty
                              ? Colors.blue
                              : Colors.grey,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () =>
                          Get.bottomSheet(LanguageSheet(c: _c, s: _c.to)),
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
                        child:
                            Obx(() => Text(_c.to.isEmpty ? 'To' : _c.to.value)),
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
                          onPressed: _speakOriginalText,
                          icon: const Icon(Icons.volume_up),
                        ),
                      ),
                    ],
                  ),
                ),
                Obx(() => _translateResult()),
                SizedBox(height: mq.height * .04),
                CustomBtn(
                  onTap: _c.googleTranslate,
                  text: 'Translate',
                )
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _startListening,
        heroTag: 'home_page_v2_microphone',
        child: const Icon(Icons.mic),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      // bottomNavigationBar: BottomNavigationBarWidget(
      //   selectedIndex: 0, // Home page is selected
      //   onItemSelected: (index) {
      //     // Handle navigation to other pages
      //     if (index == 0) return; // Already in home page
      //     if (index == 1) {
      //       Get.offNamed('/history_translation');
      //     } else if (index == 2) Get.offNamed('/voice_synthesis');
      //   },
      // ),
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
                right: 0,
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
                      onPressed: _speakTranslatedText,
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

// original


// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:get/get.dart';
// import 'package:speech_to_text/speech_to_text.dart' as stt;
// import 'package:flutter_tts/flutter_tts.dart';

// import '../../../controller/translator_controller.dart';
// import '../../../helper/global.dart';
// import '../widgets/app_bottom_navigation_bar.dart';
// import '../widgets/custom_btn.dart';
// import '../widgets/custom_loading.dart';
// import '../widgets/language_sheet.dart';

// class HomePage extends StatefulWidget {
//   const HomePage({Key? key}) : super(key: key);

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
//         onStatus: (status) => print('status: $status'),
//         onError: (error) => print('error: $error'),
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

//   Future<void> _speakOriginalText() async {
//     if (_c.textC.text.isNotEmpty) {
//       await flutterTts.setLanguage('en');
//       await flutterTts.setPitch(1);
//       await flutterTts.speak(_c.textC.text);
//     }
//   }

//   Future<void> _speakTranslatedText() async {
//     if (_c.resultC.text.isNotEmpty) {
//       await flutterTts.setLanguage(_c.to.value);
//       await flutterTts.setPitch(1);
//       await flutterTts.speak(_c.resultC.text);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     mq = MediaQuery.sizeOf(context);

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('GoNoam Translation'),
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
//                           onPressed: _speakOriginalText,
//                           icon: const Icon(Icons.volume_up),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 Obx(() => _translateResult()),
//                 SizedBox(height: mq.height * .04),
//                 CustomBtn(
//                   onTap: _c.googleTranslate,
//                   text: 'Translate',
//                 )
//               ],
//             ),
//           ),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _startListening,
//         child: const Icon(Icons.mic),
//       ),
//       floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
//       bottomNavigationBar: BottomNavigationBarWidget(
//         selectedIndex: 0, // Home page is selected
//         onItemSelected: (index) {
//           // Handle navigation to other pages
//           if (index == 0) return; // Already in home page
//           if (index == 1) {
//             Get.offNamed('/history_translation');
//           } else if (index == 2) Get.offNamed('/voice_synthesis');
//         },
//       ),
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
//                 right: 0,
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
//                       onPressed: _speakTranslatedText,
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
