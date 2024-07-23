import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gonoam_v1/features/presentation/widgets/orange_button.dart';
import 'package:gonoam_v1/provider/voice_profile_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../helper/debouncer.dart';
import '../../../../model/voice_profile_model.dart';
import '../../widgets/custom_slider_widget.dart';
import '../../widgets/custom_slider_zero_to_one_widget.dart';
import '../../widgets/searchable_dropdown.dart';

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
    voiceProfileProviderC = context.read<VoiceProfileProvider>();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      context.read<VoiceProfileProvider>().fetchVoiceProfiles();
      setup();
    });
  }

  Future<void> setup() async {
    await fetchInitialData();

    await voiceProfileProviderC.initialize();
  }

  Future<void> fetchInitialData() async {
    var querySnapshot = await FirebaseFirestore.instance
        .collection('voice_model_setting')
        .where('currentVoiceProfile', isEqualTo: 1)
        .get();

    if (querySnapshot.docs.isEmpty) {
      setState(() {
        voiceProfileProviderC.models = [];
        voiceProfileProviderC.indexes = [];
        voiceProfileProviderC.voices = [];
        voiceProfileProviderC.selectedModel = '';
        voiceProfileProviderC.selectedIndex = '';
        voiceProfileProviderC.selectedVoice = '';
        voiceProfileProviderC.textInput = '';
        voiceProfileProviderC.outputFile = '';
        voiceProfileProviderC.ttsRate = 0;
        voiceProfileProviderC.pitch = 0;
        voiceProfileProviderC.filterRadius = 3;
        voiceProfileProviderC.indexRate = 0.75;
        voiceProfileProviderC.rmsMixRate = 1;
        voiceProfileProviderC.protect = 0.5;
        voiceProfileProviderC.hopLength = 128;
        voiceProfileProviderC.f0method = [
          "pm",
          "harvest",
          "dio",
          "crepe",
          "crepe-tiny",
          "rmvpe",
          "fcpe",
          "hybrid[rmvpe+fcpe]",
        ];
        voiceProfileProviderC.selectedF0Method = "rmvpe";
        voiceProfileProviderC.splitAudio = false;
        voiceProfileProviderC.autotune = false;
        voiceProfileProviderC.cleanAudio = true;
        voiceProfileProviderC.cleanStrength = 0.5;
        voiceProfileProviderC.upscaleAudio = false;
        voiceProfileProviderC.outputTTSPath = '';
        voiceProfileProviderC.outputRVCPath = '';
        voiceProfileProviderC.exportFormat = "WAV";
        voiceProfileProviderC.embedderModel = "contentvec";
        voiceProfileProviderC.embedderModelCustom = null;
        voiceProfileProviderC.searchQuery = '';
        voiceProfileProviderC.modelName = '';
        voiceProfileProviderC.modelLanguage = '';
      });
    } else {
      var snapshot = querySnapshot.docs.first;
      setState(() {
        initialData = snapshot.data();
        voiceProfileProviderC.initializeFromData(initialData);
      });
    }
  }

  DropdownButtonFormField<String> buildDropdown<T>({
    required String labelText,
    required String? selectedValue,
    required List<T> items,
    required String Function(T) getName,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      menuMaxHeight: 250,
      decoration: InputDecoration(
        labelText: labelText,
      ),
      value: selectedValue,
      items: items.map((T item) {
        return DropdownMenuItem<String>(
          value: getName(item),
          child: SizedBox(
            width: 300,
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

  Widget _buildTextInputField(
      String label, String initialValue, Function(String) onChanged) {
    return TextField(
      controller: TextEditingController(text: initialValue),
      decoration: InputDecoration(
        labelText: label,
        hintStyle: GoogleFonts.robotoCondensed(
          fontSize: 20,
          color: Colors.black,
        ),
      ),
      onChanged: onChanged,
      style: GoogleFonts.robotoCondensed(
        fontSize: 20,
        color: Colors.black,
      ),
    );
  }

  Widget _buildRadioButtons(
      String groupValue, List<String> options, Function(String?) onChanged) {
    return Column(
      children: options
          .map((option) => RadioListTile<String>(
                activeColor: Colors.deepOrange,
                title: Text(
                  option,
                  style: GoogleFonts.robotoCondensed(
                    fontSize: 20,
                    color: Colors.black,
                  ),
                ),
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
        title: Text('Adjust Voice',
            style:
                GoogleFonts.robotoCondensed(fontSize: 30, color: Colors.white)),
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
                    });
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
                                CustomSearchableDropdown(
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
                                CustomSearchableDropdown(
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
                                CustomSearchableDropdown(
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
                                CustomSliderWidget(
                                    label: 'TTS Rate',
                                    value:
                                        voiceModelProviderC.ttsRate.toDouble(),
                                    min: 0,
                                    max: 100,
                                    divisions: 100,
                                    onChanged: (newValue) {
                                      voiceModelProviderC.ttsRate =
                                          newValue.round();
                                    }),
                                CustomSliderWidget(
                                    label: 'Pitch',
                                    value: voiceModelProviderC.pitch.toDouble(),
                                    min: -100,
                                    max: 100,
                                    divisions: 200,
                                    onChanged: (newValue) {
                                      voiceModelProviderC.pitch = newValue;
                                    }),
                                CustomSliderWidget(
                                    label: 'Filter Radius',
                                    value: voiceModelProviderC.filterRadius
                                        .toDouble(),
                                    min: 1,
                                    max: 10,
                                    divisions: 9,
                                    onChanged: (newValue) {
                                      voiceModelProviderC.filterRadius =
                                          newValue;
                                    }),
                                CustomSliderZeroToOneWidget(
                                  label: 'Index Rate',
                                  value:
                                      voiceModelProviderC.indexRate.toDouble(),
                                  min: 0,
                                  max: 1,
                                  divisions: 0.5,
                                  increment: 0.05,
                                  onChanged: (newValue) {
                                    voiceModelProviderC.indexRate = newValue;
                                  },
                                ),
                                CustomSliderZeroToOneWidget(
                                  label: 'RMS Mix Rate',
                                  value:
                                      voiceModelProviderC.rmsMixRate.toDouble(),
                                  min: 0,
                                  max: 1,
                                  divisions: 1,
                                  increment: 0.05,
                                  onChanged: (newValue) {
                                    voiceModelProviderC.rmsMixRate = newValue;
                                  },
                                ),
                                CustomSliderZeroToOneWidget(
                                  label: "Protect",
                                  value: voiceModelProviderC.protect.toDouble(),
                                  min: 0,
                                  max: 1,
                                  divisions: 0.5,
                                  increment: 0.05,
                                  onChanged: (newValue) {
                                    voiceModelProviderC.protect = newValue;
                                  },
                                ),
                                CustomSliderWidget(
                                    label: 'Hop Length',
                                    value: voiceModelProviderC.hopLength
                                        .toDouble(),
                                    min: 64,
                                    max: 512,
                                    divisions: 448,
                                    onChanged: (newValue) {
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
                                  setState(() {
                                    fetchInitialData();
                                  });
                                }),
                                const SizedBox(height: 80),
                              ],
                            ),
                    ],
                  ),
                ),
              ],
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
                  ),
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
            mainAxisSize: MainAxisSize.min,
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
