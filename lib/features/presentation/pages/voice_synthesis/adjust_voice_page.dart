import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:gonoam_v1/features/presentation/widgets/orange_button.dart';
import 'package:gonoam_v1/provider/voice_profile_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../model/voice_profile_model.dart';

class AdjustVoiceProfilePage extends StatefulWidget {
  const AdjustVoiceProfilePage({super.key});

  @override
  State<AdjustVoiceProfilePage> createState() => _AdjustVoiceProfilePageState();
}

class _AdjustVoiceProfilePageState extends State<AdjustVoiceProfilePage> {
  late VoiceProfileProvider voiceProfileProviderC;
  late Map<String, dynamic> initialData = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      voiceProfileProviderC =
          Provider.of<VoiceProfileProvider>(context, listen: false);
      await voiceProfileProviderC.fetchVoiceProfiles();
      await fetchInitialData();
    });
  }

  Future<void> fetchInitialData() async {
    var snapshot = await FirebaseFirestore.instance
        .collection('voice_model_setting')
        .where('currentVoiceProfile', isEqualTo: 1)
        .get()
        .then((snapshot) => snapshot.docs.first);
    setState(() {
      initialData = snapshot.data();
      voiceProfileProviderC.initializeFromData(initialData);
    });
  }

  DropdownButtonFormField<String> buildDropdown<T>({
    required String labelText,
    required String? selectedValue,
    required List<T> items,
    required String Function(T) getName,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: labelText,
      ),
      value: selectedValue,
      items: items.map((T item) {
        return DropdownMenuItem<String>(
          value: getName(item),
          child: SizedBox(
            width: 300, // Set a fixed width for the container
            child: Text(
              getName(item),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildSlider(String label, double value, double min, double max,
      int divisions, Function(double) onChanged) {
    return Column(
      children: [
        Text('$label: $value'),
        Slider(
          label: label,
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildTextInputField(
      String label, String initialValue, Function(String) onChanged) {
    return TextField(
      controller: TextEditingController(text: initialValue),
      decoration: InputDecoration(labelText: label),
      onChanged: onChanged,
    );
  }

  Widget _buildRadioButtons(
      String groupValue, List<String> options, Function(String?) onChanged) {
    return Column(
      children: options
          .map((option) => RadioListTile<String>(
                title: Text(option),
                value: option,
                groupValue: groupValue,
                onChanged: onChanged,
              ))
          .toList(),
    );
  }

  Widget _buildButton(String text, VoidCallback onPressed) {
    return OrangeButton(
      onPressed: onPressed,
      text: text,
    );
  }

  Future<void> refreshAndFetchData() async {
    var snapshot = await FirebaseFirestore.instance
        .collection('voice_model_setting')
        .where('currentVoiceProfile', isEqualTo: 1)
        .get()
        .then((snapshot) => snapshot.docs.first);

    setState(() {
      initialData = snapshot.data() as Map<String, dynamic>;
      voiceProfileProviderC.initializeFromData(initialData);
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final voiceModelProviderC = Provider.of<VoiceProfileProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Adjust Voice', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: refreshAndFetchData,
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueGrey[900],
                      foregroundColor: Colors.white),
                  onPressed: () async {
                    await _showVoiceProfileDialog(context, voiceModelProviderC);
                    setState(() {
                      refreshAndFetchData();
                    }); // Refresh the page after selecting a profile
                  },
                  child: Text(voiceModelProviderC.selectedProfileName ??
                      'Choose Current Voice Profile'),
                ),
                Container(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    children: [
                      initialData == null
                          ? const CircularProgressIndicator()
                          : Column(
                              children: [
                                buildDropdown<String>(
                                  labelText: 'Select Model',
                                  selectedValue:
                                      voiceModelProviderC.selectedModel,
                                  items: voiceModelProviderC.models,
                                  getName: (model) => model,
                                  onChanged: (String? newValue) {
                                    if (newValue != null) {
                                      voiceModelProviderC.selectedModel =
                                          newValue;
                                    }
                                  },
                                ),
                                buildDropdown<String>(
                                  labelText: 'Select Index',
                                  selectedValue:
                                      voiceModelProviderC.selectedIndex,
                                  items: voiceModelProviderC.indexes,
                                  getName: (index) => index,
                                  onChanged: (String? newValue) {
                                    if (newValue != null) {
                                      voiceModelProviderC.selectedIndex =
                                          newValue;
                                    }
                                  },
                                ),
                                buildDropdown<String>(
                                  labelText: 'Select Voice',
                                  selectedValue:
                                      voiceModelProviderC.selectedVoice,
                                  items: voiceModelProviderC.voices
                                      .map((voice) => voice.shortName)
                                      .toList(),
                                  getName: (voice) => voice,
                                  onChanged: (String? newValue) {
                                    if (newValue != null) {
                                      voiceModelProviderC.selectedVoice =
                                          newValue;
                                    }
                                  },
                                ),
                                const SizedBox(height: 10),
                                _buildTextInputField(
                                    'Model Name', voiceModelProviderC.modelName,
                                    (value) {
                                  voiceModelProviderC.modelName = value;
                                }),
                                _buildTextInputField('Model Language',
                                    voiceProfileProviderC.modelLanguage,
                                    (value) {
                                  voiceModelProviderC.modelLanguage = value;
                                }),
                                const SizedBox(height: 20),
                                _buildSlider(
                                    'TTS Rate',
                                    voiceModelProviderC.ttsRate.toDouble(),
                                    0,
                                    100,
                                    100, (newValue) {
                                  voiceModelProviderC.ttsRate =
                                      newValue.round();
                                }),
                                _buildSlider(
                                    'Pitch',
                                    voiceModelProviderC.pitch.toDouble(),
                                    -100,
                                    100,
                                    200, (newValue) {
                                  voiceModelProviderC.pitch = newValue;
                                }),
                                _buildSlider(
                                    'Filter Radius',
                                    voiceModelProviderC.filterRadius.toDouble(),
                                    1,
                                    10,
                                    9, (newValue) {
                                  voiceModelProviderC.filterRadius = newValue;
                                }),
                                _buildSlider(
                                    'Index Rate',
                                    voiceModelProviderC.indexRate.toDouble(),
                                    0,
                                    1,
                                    1, (newValue) {
                                  voiceModelProviderC.indexRate = newValue;
                                }),
                                _buildSlider(
                                    'RMS Mix Rate',
                                    voiceModelProviderC.rmsMixRate.toDouble(),
                                    0,
                                    1,
                                    1, (newValue) {
                                  voiceModelProviderC.rmsMixRate = newValue;
                                }),
                                _buildSlider(
                                    'Protect',
                                    voiceModelProviderC.protect.toDouble(),
                                    0,
                                    1,
                                    1, (newValue) {
                                  voiceModelProviderC.protect = newValue;
                                }),
                                _buildSlider(
                                    'Hop Length',
                                    voiceModelProviderC.hopLength.toDouble(),
                                    64,
                                    512,
                                    448, (newValue) {
                                  voiceModelProviderC.hopLength = newValue;
                                }),
                                _buildRadioButtons(
                                    voiceModelProviderC.selectedF0Method,
                                    voiceModelProviderC.f0method, (newValue) {
                                  voiceModelProviderC.selectedF0Method =
                                      newValue!;
                                }),
                                _buildTextInputField('Text to Synthesize',
                                    voiceModelProviderC.textInput, (value) {
                                  voiceModelProviderC.textInput = value;
                                }),
                                const SizedBox(height: 20),
                                _buildButton('Generate TTS', () {
                                  voiceModelProviderC.generateTTS();
                                }),
                                const SizedBox(height: 20),
                                _buildButton('Update Voice Model Profile', () {
                                  voiceModelProviderC
                                      .updateTrainedVoiceModelSetting();
                                  setState(
                                      () {}); // Refresh the page after update
                                }),
                                const SizedBox(height: 80),
                              ],
                            ),
                    ],
                  ),
                ),
              ],
              // Add other input fields here following the same pattern
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showVoiceProfileDialog(
      BuildContext context, VoiceProfileProvider voiceModelProviderC) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.blueGrey,
          title: Text(
            'Set Current Voice Profile',
            style: GoogleFonts.bebasNeue(
              textStyle: const TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: voiceModelProviderC.voiceProfiles.expand((profile) {
                return [
                  ListTile(
                    selectedTileColor: const ColorScheme.light().primary,
                    shape: ShapeBorder.lerp(
                        const RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero),
                        RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        1),
                    tileColor: const Color.fromARGB(255, 240, 216, 154),
                    title: Text(
                      '${profile.modelName}-${profile.modelLanguage}',
                      style: GoogleFonts.merriweather(
                        textStyle: const TextStyle(
                          color: Colors.blueGrey,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    trailing: IconButton(
                      visualDensity: VisualDensity.compact,
                      iconSize: 35,
                      tooltip: 'Choose Current Voice Profile',
                      splashRadius: 35,
                      highlightColor: Colors.teal[100],
                      focusNode: FocusNode(),
                      icon: Icon(Icons.check_circle_rounded,
                          color: Colors.teal[900]),
                      onPressed: () {
                        voiceModelProviderC.selectProfileAsCurrent(profile);
                        Navigator.of(context).pop();
                        setState(() {
                          voiceModelProviderC.selectedProfileName =
                              '${profile.modelName}-${profile.modelLanguage}';
                        });
                        refreshAndFetchData();
                      },
                    ),
                    onTap: () => _showProfileDetails(context, profile),
                  ),
                  const Divider(
                    color: Colors.white,
                    indent: 20,
                    endIndent: 20,
                  ), // Add a divider after each ListTile
                ];
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  void _showProfileDetails(BuildContext context, VoiceProfile profile) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          insetPadding: const EdgeInsets.all(30),
          shape: const ContinuousRectangleBorder(
            side:
                BorderSide(color: Color.fromARGB(253, 226, 196, 121), width: 4),
            borderRadius: BorderRadius.all(
              Radius.circular(90),
            ),
          ),
          backgroundColor: Colors.blueGrey,
          content: Column(
            mainAxisSize: MainAxisSize
                .min, // Use this to make the column wrap its content
            children: [
              const SizedBox(height: 10),
              Flexible(
                flex: -5,
                child: Text(
                  '${profile.modelName}-${profile.modelLanguage}',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.merriweather(
                    fontSize: 20,
                    color: const Color.fromARGB(252, 247, 234, 203),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    backgroundBlendMode: BlendMode.hardLight,
                    borderRadius: BorderRadius.circular(10),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color.fromARGB(253, 226, 196, 121),
                        Color.fromARGB(255, 240, 216, 154),
                      ],
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      children: profile.additionalFields.entries.map((entry) {
                        String formattedFieldName = entry.key
                            .split('_')
                            .map((word) =>
                                word[0].toUpperCase() + word.substring(1))
                            .join(' ');
                        return Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          formattedFieldName,
                                          style: GoogleFonts.bebasNeue(
                                              fontSize: 20,
                                              color: const Color.fromARGB(
                                                  255, 99, 97, 97)),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          ':${entry.value}',
                                          style: GoogleFonts.merriweather(
                                              fontSize: 17,
                                              color: const Color.fromARGB(
                                                  255, 25, 89, 97)),
                                        ),
                                        const SizedBox(height: 10),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Divider(
                              color: Colors.white,
                              thickness: 1,
                              indent: 10,
                              endIndent: 10,
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ],
          ),
          actions: <Widget>[
            Center(
              child: TextButton(
                child: const Text(
                  'OK',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      shadows: [Shadow(color: Colors.black, blurRadius: 10)]),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

// ================================================================================================================================
// adjust_voice_profile_page.dart
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// import '../../../../model/voice_profile_model.dart';
// import '../../../../provider/voice_profile_provider.dart';

// class AdjustVoiceProfilePage extends StatelessWidget {
//   const AdjustVoiceProfilePage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Adjust Voice Profile'),
//       ),
//       body: Consumer<VoiceProfileProvider>(
//         builder: (context, provider, child) {
//           return ListView(
//             padding: const EdgeInsets.all(16.0),
//             children: [
//               DropdownButtonFormField<String>(
//                 value: provider.selectedProfileName,
//                 onChanged: (String? newValue) {
//                   provider.selectedProfileName = newValue;
//                 },
//                 items: provider.voiceProfiles
//                     .map<DropdownMenuItem<String>>((VoiceProfile profile) {
//                   return DropdownMenuItem<String>(
//                     value: profile.modelName,
//                     child: Text(profile.modelName),
//                   );
//                 }).toList(),
//                 decoration: const InputDecoration(labelText: 'Select Profile'),
//               ),
//               // Add TextFormField, Slider, and other input widgets here
//               DropdownButtonFormField<String>(
//                 decoration: const InputDecoration(
//                   labelText: 'Select Model',
//                 ),
//                 value: provider.selectedModel,
//                 items: provider.models.map((String model) {
//                   return DropdownMenuItem<String>(
//                     value: model,
//                     child: SizedBox(
//                       width: 300, // Set a fixed width for the container
//                       child: Text(
//                         model,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     ),
//                   );
//                 }).toList(),
//                 onChanged: (String? newValue) {
//                   provider.selectedModel = newValue!;
//                 },
//               ),
//               const SizedBox(height: 10),
//               DropdownButtonFormField<String>(
//                 decoration: const InputDecoration(
//                   labelText: 'Select Index',
//                 ),
//                 value: provider.selectedIndex,
//                 items: provider.indexes.map((String index) {
//                   return DropdownMenuItem<String>(
//                     value: index,
//                     child: SizedBox(
//                       width: 300, // Set a fixed width for the container
//                       child: Text(
//                         index,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     ),
//                   );
//                 }).toList(),
//                 onChanged: (String? newValue) {
//                   provider.selectedIndex = newValue!;
//                 },
//               ),
//               const SizedBox(height: 10),
//               DropdownButtonFormField<String>(
//                 menuMaxHeight: 300,
//                 decoration: const InputDecoration(
//                   labelText: 'Select Voice',
//                 ),
//                 value: provider.selectedVoice,
//                 items: provider.voices.map((voice) {
//                   return DropdownMenuItem<String>(
//                     value: voice.shortName,
//                     child: SizedBox(
//                       width: 300,
//                       child: Row(
//                         children: [
//                           Expanded(
//                             child: Text(
//                               voice.shortName,
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                           ),
//                           const SizedBox(width: 10),
//                           Text(
//                             "(${voice.gender})",
//                             style: const TextStyle(
//                               fontStyle: FontStyle.italic,
//                               color: Colors.grey,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   );
//                 }).toList(),
//                 onChanged: (String? newValue) {
//                   provider.selectedVoice = newValue!;
//                 },
//               ),
//               const SizedBox(height: 20),
//               Text('TTS Rate: ${provider.ttsRate}'),
//               Slider(
//                 label: "TTS Rate",
//                 value: provider.ttsRate.toDouble(),
//                 min: 0,
//                 max: 100,
//                 divisions: 100,
//                 onChanged: (newValue) {
//                   provider.ttsRate = newValue.round();
//                 },
//               ),
//               Text('Pitch: ${provider.pitch}'),
//               Slider(
//                 label: "Pitch",
//                 value: provider.pitch,
//                 min: -100,
//                 max: 100,
//                 onChanged: (newValue) {
//                   provider.pitch = newValue;
//                 },
//               ),
//               Text('Filter Radius: ${provider.filterRadius}'),
//               Slider(
//                 label: "Filter Radius",
//                 value: provider.filterRadius,
//                 min: 1,
//                 max: 10,
//                 onChanged: (newValue) {
//                   provider.filterRadius = newValue;
//                 },
//               ),
//               Text('Index Rate: ${provider.indexRate}'),
//               Slider(
//                 label: "Index Rate",
//                 value: provider.indexRate,
//                 min: 0,
//                 max: 1,
//                 onChanged: (newValue) {
//                   provider.indexRate = newValue;
//                 },
//               ),
//               Text('RMS Mix Rate: ${provider.rmsMixRate}'),
//               Slider(
//                 label: "RMS Mix Rate",
//                 value: provider.rmsMixRate,
//                 min: 0,
//                 max: 1,
//                 onChanged: (newValue) {
//                   provider.rmsMixRate = newValue;
//                 },
//               ),
//               Text('Protect: ${provider.protect}'),
//               Slider(
//                 label: "Protect",
//                 value: provider.protect,
//                 min: 0,
//                 max: 1,
//                 onChanged: (newValue) {
//                   provider.protect = newValue;
//                 },
//               ),
//               Text('Hop Length: ${provider.hopLength}'),
//               Slider(
//                 label: "Hop Length",
//                 value: provider.hopLength,
//                 min: 64,
//                 max: 512,
//                 onChanged: (newValue) {
//                   provider.hopLength = newValue;
//                 },
//               ),
//               const Text('F0 Method:'),
//               ...provider.f0method.map((method) => RadioListTile<String>(
//                     title: Text(method),
//                     value: method,
//                     groupValue: provider.selectedF0Method,
//                     onChanged: (String? value) {
//                       provider.selectedF0Method = value!;
//                     },
//                   )),
//               // that update the provider's fields accordingly
//               TextField(
//                 decoration: const InputDecoration(
//                   labelText: 'Enter Text to synthesize',
//                 ),
//                 onChanged: (text) {
//                   provider.textInput = text;
//                 },
//               ),
//               ElevatedButton(
//                 onPressed: provider.generateTTS,
//                 child: const Text('Generate TTS'),
//               ),
//               ElevatedButton(
//                 onPressed: provider.convertVoice,
//                 child: const Text('Convert Voice'),
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }
// }

// ================================================================================================================================


// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:gonoam_v1/features/presentation/widgets/orange_button.dart';
// import 'package:gonoam_v1/provider/voice_profile_provider.dart';
// import 'package:provider/provider.dart';
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import '../../../../model/voice_profile_model.dart';

// class AdjustVoiceProfilePage extends StatefulWidget {
//   const AdjustVoiceProfilePage({super.key});

//   @override
//   State<AdjustVoiceProfilePage> createState() => _AdjustVoiceProfilePageState();
// }

// class _AdjustVoiceProfilePageState extends State<AdjustVoiceProfilePage> {
//   late VoiceProfileProvider voiceProfileProviderC;
//   late Map<String, dynamic> initialData = {};
//   TextEditingController modelNameController = TextEditingController();
//   TextEditingController modelLanguageController = TextEditingController();
//   TextEditingController textInputController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) async {
//       voiceProfileProviderC =
//           Provider.of<VoiceProfileProvider>(context, listen: false);
//       await voiceProfileProviderC.fetchVoiceProfiles();
//       await fetchInitialData();
//       await voiceProfileProviderC.fetchModels();
//       await voiceProfileProviderC.fetchIndexes();
//       await voiceProfileProviderC.fetchVoices();
//     });
//   }

//   Future<void> fetchInitialData() async {
//     var snapshot = await FirebaseFirestore.instance
//         .collection('voice_model_setting')
//         .where('currentVoiceProfile', isEqualTo: 1)
//         .get()
//         .then((snapshot) => snapshot.docs.first);
//     setState(() {
//       initialData = snapshot.data();
//       voiceProfileProviderC.initializeFromData(initialData);
//       modelNameController.text = voiceProfileProviderC.modelName;
//       modelLanguageController.text = voiceProfileProviderC.modelLanguage;
//       textInputController.text = voiceProfileProviderC.textInput;
//     });
//   }

//   DropdownButtonFormField<String> buildDropdown<T>({
//     required String labelText,
//     required String? selectedValue,
//     required List<T> items,
//     required String Function(T) getName,
//     required void Function(String?) onChanged,
//   }) {
//     return DropdownButtonFormField<String>(
//       decoration: InputDecoration(
//         labelText: labelText,
//       ),
//       value: selectedValue,
//       items: items.map((T item) {
//         return DropdownMenuItem<String>(
//           value: getName(item),
//           child: SizedBox(
//             width: 300, // Set a fixed width for the container
//             child: Text(
//               getName(item),
//               overflow: TextOverflow.ellipsis,
//             ),
//           ),
//         );
//       }).toList(),
//       onChanged: onChanged,
//     );
//   }

//   Widget _buildSlider(String label, double value, double min, double max,
//       int divisions, Function(double) onChanged) {
//     return Column(
//       children: [
//         Text('$label: $value'),
//         Slider(
//           label: label,
//           value: value,
//           min: min,
//           max: max,
//           divisions: divisions,
//           onChanged: onChanged,
//         ),
//       ],
//     );
//   }

//   Widget _buildTextInputField(
//       String label, TextEditingController controller, Function(String) onChanged) {
//     return TextField(
//       controller: controller,
//       decoration: InputDecoration(labelText: label),
//       onChanged: onChanged,
//     );
//   }

//   Widget _buildRadioButtons(
//       String groupValue, List<String> options, Function(String?) onChanged) {
//     return Column(
//       children: options
//           .map((option) => RadioListTile<String>(
//                 title: Text(option),
//                 value: option,
//                 groupValue: groupValue,
//                 onChanged: onChanged,
//               ))
//           .toList(),
//     );
//   }

//   Widget _buildButton(String text, VoidCallback onPressed) {
//     return OrangeButton(
//       onPressed: onPressed,
//       text: text,
//     );
//   }

//   Future<void> refreshAndFetchData() async {
//     var snapshot = await FirebaseFirestore.instance
//         .collection('voice_model_setting')
//         .where('currentVoiceProfile', isEqualTo: 1)
//         .get()
//         .then((snapshot) => snapshot.docs.first);

//     setState(() {
//       initialData = snapshot.data() as Map<String, dynamic>;
//       voiceProfileProviderC.initializeFromData(initialData);
//     });
//   }

//   @override
//   void dispose() {
//     modelNameController.dispose();
//     modelLanguageController.dispose();
//     textInputController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final voiceModelProviderC = Provider.of<VoiceProfileProvider>(context);

//     return Scaffold(
//       appBar: AppBar(
//         title:
//             const Text('Adjust Voice', style: TextStyle(color: Colors.white)),
//         backgroundColor: Colors.blue,
//         foregroundColor: Colors.white,
//       ),
//       body: Center(
//         child: SingleChildScrollView(
//           child: Column(
//             children: <Widget>[
//               const SizedBox(height: 20),
//               ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.blueGrey[900],
//                     foregroundColor: Colors.white),
//                 onPressed: () async {
//                   await _showVoiceProfileDialog(context, voiceModelProviderC);
//                   setState(() {
//                     refreshAndFetchData();
//                   }); // Refresh the page after selecting a profile
//                 },
//                 child: Text(voiceModelProviderC.selectedProfileName ??
//                     'Choose Current Voice Profile'),
//               ),
//               Container(
//                 padding: const EdgeInsets.all(15.0),
//                 child: Column(
//                   children: [
//                     initialData.isEmpty
//                         ? const CircularProgressIndicator()
//                         : Column(
//                             children: [
//                               buildDropdown<String>(
//                                 labelText: 'Select Model',
//                                 selectedValue:
//                                     voiceModelProviderC.selectedModel,
//                                 items: voiceModelProviderC.models,
//                                 getName: (model) => model,
//                                 onChanged: (String? newValue) {
//                                   if (newValue != null) {
//                                     voiceModelProviderC.selectedModel =
//                                         newValue;
//                                   }
//                                 },
//                               ),
//                               buildDropdown<String>(
//                                 labelText: 'Select Index',
//                                 selectedValue:
//                                     voiceModelProviderC.selectedIndex,
//                                 items: voiceModelProviderC.indexes,
//                                 getName: (index) => index,
//                                 onChanged: (String? newValue) {
//                                   if (newValue != null) {
//                                     voiceModelProviderC.selectedIndex =
//                                         newValue;
//                                   }
//                                 },
//                               ),
//                               buildDropdown<String>(
//                                 labelText: 'Select Voice',
//                                 selectedValue:
//                                     voiceModelProviderC.selectedVoice,
//                                 items: voiceModelProviderC.voices
//                                     .map((voice) => voice.shortName)
//                                     .toList(),
//                                 getName: (voice) => voice,
//                                 onChanged: (String? newValue) {
//                                   if (newValue != null) {
//                                     voiceModelProviderC.selectedVoice =
//                                         newValue;
//                                   }
//                                 },
//                               ),
//                               const SizedBox(height: 10),
//                               _buildTextInputField(
//                                   'Model Name', modelNameController, (value) {
//                                 voiceModelProviderC.modelName = value;
//                               }),
//                               _buildTextInputField('Model Language',
//                                   modelLanguageController, (value) {
//                                 voiceModelProviderC.modelLanguage = value;
//                               }),
//                               const SizedBox(height: 20),
//                               _buildSlider(
//                                   'TTS Rate',
//                                   voiceModelProviderC.ttsRate.toDouble(),
//                                   0,
//                                   100,
//                                   100, (newValue) {
//                                 voiceModelProviderC.ttsRate = newValue.round();
//                               }),
//                               _buildSlider(
//                                   'Pitch',
//                                   voiceModelProviderC.pitch.toDouble(),
//                                   -100,
//                                   100,
//                                   200, (newValue) {
//                                 voiceModelProviderC.pitch = newValue;
//                               }),
//                               _buildSlider(
//                                   'Filter Radius',
//                                   voiceModelProviderC.filterRadius.toDouble(),
//                                   1,
//                                   10,
//                                   9, (newValue) {
//                                 voiceModelProviderC.filterRadius = newValue;
//                               }),
//                               _buildSlider(
//                                   'Index Rate',
//                                   voiceModelProviderC.indexRate.toDouble(),
//                                   0,
//                                   1,
//                                   1, (newValue) {
//                                 voiceModelProviderC.indexRate = newValue;
//                               }),
//                               _buildSlider(
//                                   'RMS Mix Rate',
//                                   voiceModelProviderC.rmsMixRate.toDouble(),
//                                   0,
//                                   1,
//                                   1, (newValue) {
//                                 voiceModelProviderC.rmsMixRate = newValue;
//                               }),
//                               _buildSlider(
//                                   'Protect',
//                                   voiceModelProviderC.protect.toDouble(),
//                                   0,
//                                   1,
//                                   1, (newValue) {
//                                 voiceModelProviderC.protect = newValue;
//                               }),
//                               const SizedBox(height: 20),
//                               _buildTextInputField(
//                                   'Text Input', textInputController, (value) {
//                                 voiceModelProviderC.textInput = value;
//                               }),
//                               const SizedBox(height: 20),
//                               _buildRadioButtons(
//                                   voiceModelProviderC.mode,
//                                   const ['CPU', 'CUDA'],
//                                   (String? newValue) {
//                                 if (newValue != null) {
//                                   voiceModelProviderC.mode = newValue;
//                                 }
//                               }),
//                               const SizedBox(height: 20),
//                               _buildButton(
//                                 'Convert',
//                                 () async {
//                                   await voiceModelProviderC.convertTextToVoice();
//                                   ScaffoldMessenger.of(context).showSnackBar(
//                                     const SnackBar(
//                                         content: Text(
//                                             'Converting text to voice...')),
//                                   );
//                                 },
//                               ),
//                             ],
//                           ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Future<void> _showVoiceProfileDialog(BuildContext context,
//       VoiceProfileProvider voiceProfileProviderC) async {
//     await showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: const Text('Select Voice Profile'),
//           content: Consumer<VoiceProfileProvider>(
//             builder: (context, voiceProfileProvider, child) {
//               return SizedBox(
//                 width: double.maxFinite,
//                 child: ListView.builder(
//                   shrinkWrap: true,
//                   itemCount: voiceProfileProviderC.voiceProfiles.length,
//                   itemBuilder: (context, index) {
//                     final profile =
//                         voiceProfileProviderC.voiceProfiles[index];
//                     return ListTile(
//                       title: Text(profile.name),
//                       onTap: () {
//                         voiceProfileProviderC.setCurrentVoiceProfile(profile);
//                         Navigator.of(context).pop();
//                       },
//                     );
//                   },
//                 ),
//               );
//             },
//           ),
//         );
//       },
//     );
//   }
// }