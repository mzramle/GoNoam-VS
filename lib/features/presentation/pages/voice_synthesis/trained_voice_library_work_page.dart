import 'package:flutter/material.dart';
import 'package:gonoam_v1/features/presentation/widgets/orange_button.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../provider/trained_voice_library_work_provider.dart';
import '../../widgets/custom_slider_widget.dart';
import '../../widgets/custom_slider_zero_to_one_widget.dart';
import '../../widgets/searchable_dropdown.dart';

class TrainedVoiceLibraryWork extends StatefulWidget {
  const TrainedVoiceLibraryWork({super.key});

  @override
  State<TrainedVoiceLibraryWork> createState() =>
      _TrainedVoiceLibraryWorkState();
}

class _TrainedVoiceLibraryWorkState extends State<TrainedVoiceLibraryWork> {
  late TrainedVoiceProvider trainedVoiceProvider;

  @override
  void initState() {
    super.initState();
    setup();
    context.read<TrainedVoiceProvider>().initialize();

    // WidgetsBinding.instance.addPostFrameCallback((_) async {});
  }

  Future<void> setup() async {
    await fetchInitialFirstWorkData();
  }

  Future<void> fetchInitialFirstWorkData() async {
    setState(() {
      trainedVoiceProvider.models = [];
      trainedVoiceProvider.indexes = [];
      trainedVoiceProvider.voices = [];
      trainedVoiceProvider.selectedModel = '';
      trainedVoiceProvider.selectedIndex = '';
      trainedVoiceProvider.selectedVoice = '';
      trainedVoiceProvider.textInput = '';
      trainedVoiceProvider.outputFile = '';
      trainedVoiceProvider.ttsRate = 0;
      trainedVoiceProvider.pitch = 0;
      trainedVoiceProvider.filterRadius = 3;
      trainedVoiceProvider.indexRate = 0.75;
      trainedVoiceProvider.rmsMixRate = 1;
      trainedVoiceProvider.protect = 0.5;
      trainedVoiceProvider.hopLength = 128;
      trainedVoiceProvider.f0method = [
        "pm",
        "harvest",
        "dio",
        "crepe",
        "crepe-tiny",
        "rmvpe",
        "fcpe",
        "hybrid[rmvpe+fcpe]",
      ];
      trainedVoiceProvider.selectedF0Method = "rmvpe";
      trainedVoiceProvider.splitAudio = false;
      trainedVoiceProvider.autotune = false;
      trainedVoiceProvider.cleanAudio = true;
      trainedVoiceProvider.cleanStrength = 0.5;
      trainedVoiceProvider.upscaleAudio = false;
      trainedVoiceProvider.outputTTSPath = '';
      trainedVoiceProvider.outputRVCPath = '';
      trainedVoiceProvider.exportFormat = "WAV";
      trainedVoiceProvider.embedderModel = "contentvec";
      trainedVoiceProvider.embedderModelCustom = null;
      trainedVoiceProvider.searchQuery = '';
      trainedVoiceProvider.modelName = '';
      trainedVoiceProvider.modelLanguage = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TrainedVoiceProvider(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Manage Trained Voice Library',
              style: GoogleFonts.robotoCondensed(
                  fontSize: 25, color: Colors.white)),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Consumer<TrainedVoiceProvider>(
            builder: (context, trainedVoiceProvider, child) {
              return ListView(
                children: [
                  CustomSearchableDropdown(
                    labelText: 'Select Model',
                    selectedValue: trainedVoiceProvider.selectedModel,
                    items: trainedVoiceProvider.models.isNotEmpty
                        ? trainedVoiceProvider.models
                        : [''],
                    getName: (models) => models,
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        trainedVoiceProvider.selectedModel = newValue;
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                  CustomSearchableDropdown(
                    labelText: 'Select Index',
                    selectedValue: trainedVoiceProvider.selectedIndex,
                    items: trainedVoiceProvider.indexes.isNotEmpty
                        ? trainedVoiceProvider.indexes
                        : [''],
                    getName: (indexes) => indexes,
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        trainedVoiceProvider.selectedIndex = newValue;
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                  CustomSearchableDropdown(
                    labelText: 'Select Voice',
                    selectedValue: trainedVoiceProvider.selectedVoice,
                    items: trainedVoiceProvider.voices.isNotEmpty
                        ? trainedVoiceProvider.voices
                            .map((voices) => voices.shortName)
                            .toList()
                        : [''],
                    getName: (voices) => voices,
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        trainedVoiceProvider.selectedVoice = newValue;
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  Text('TTS Rate: ${trainedVoiceProvider.ttsRate}'),
                  CustomSliderWidget(
                    label: "TTS Rate",
                    value: trainedVoiceProvider.ttsRate.toDouble(),
                    min: 0,
                    max: 100,
                    divisions: 100,
                    onChanged: (newValue) {
                      trainedVoiceProvider.ttsRate = newValue.round();
                    },
                  ),
                  Text('Pitch: ${trainedVoiceProvider.pitch}'),
                  CustomSliderWidget(
                    label: "Pitch",
                    value: trainedVoiceProvider.pitch,
                    min: -100,
                    max: 100,
                    onChanged: (newValue) {
                      trainedVoiceProvider.pitch = newValue;
                    },
                  ),
                  Text('Filter Radius: ${trainedVoiceProvider.filterRadius}'),
                  CustomSliderWidget(
                    label: "Filter Radius",
                    value: trainedVoiceProvider.filterRadius,
                    min: 1,
                    max: 10,
                    onChanged: (newValue) {
                      trainedVoiceProvider.filterRadius = newValue;
                    },
                  ),
                  Text('Index Rate: ${trainedVoiceProvider.indexRate}'),
                  CustomSliderZeroToOneWidget(
                    label: "Index Rate",
                    value: trainedVoiceProvider.indexRate,
                    min: 0,
                    max: 1,
                    divisions: 0.5,
                    increment: 0.05,
                    onChanged: (newValue) {
                      trainedVoiceProvider.indexRate = newValue;
                    },
                  ),
                  Text('RMS Mix Rate: ${trainedVoiceProvider.rmsMixRate}'),
                  CustomSliderZeroToOneWidget(
                    label: "RMS Mix Rate",
                    value: trainedVoiceProvider.rmsMixRate,
                    min: 0,
                    max: 1,
                    divisions: 1,
                    increment: 0.05,
                    onChanged: (newValue) {
                      trainedVoiceProvider.rmsMixRate = newValue;
                    },
                  ),
                  Text('Protect: ${trainedVoiceProvider.protect}'),
                  CustomSliderZeroToOneWidget(
                    label: "Protect",
                    value: trainedVoiceProvider.protect,
                    min: 0,
                    max: 1,
                    divisions: 0.5,
                    increment: 0.05,
                    onChanged: (newValue) {
                      trainedVoiceProvider.protect = newValue;
                    },
                  ),
                  Text('Hop Length: ${trainedVoiceProvider.hopLength}'),
                  CustomSliderWidget(
                    label: "Hop Length",
                    value: trainedVoiceProvider.hopLength,
                    min: 64,
                    max: 512,
                    onChanged: (newValue) {
                      trainedVoiceProvider.hopLength = newValue;
                    },
                  ),
                  const Text('F0 Method:'),
                  ...trainedVoiceProvider.f0method
                      .map((method) => RadioListTile<String>(
                            activeColor: Colors.deepOrange,
                            title: Text(
                              method,
                              style: GoogleFonts.robotoCondensed(
                                fontSize: 20,
                                color: Colors.black,
                              ),
                            ),
                            value: method,
                            groupValue: trainedVoiceProvider.selectedF0Method,
                            onChanged: (String? value) {
                              trainedVoiceProvider.selectedF0Method = value!;
                            },
                          )),
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Enter Text to synthesize',
                    ),
                    onChanged: (text) {
                      trainedVoiceProvider.textInput = text;
                    },
                  ),
                  const SizedBox(height: 20),
                  OrangeButton(
                    text: 'Generate TTS',
                    onPressed: trainedVoiceProvider.generateTTS,
                  ),
                  const SizedBox(height: 20),
                  const Divider(
                    // Add a divider
                    color: Colors.black,
                    thickness: 5,
                  ),
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Enter Model Name',
                    ),
                    onChanged: (text) {
                      trainedVoiceProvider.modelName = text;
                    },
                  ),
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Enter Model Language',
                    ),
                    onChanged: (text) {
                      trainedVoiceProvider.modelLanguage = text;
                    },
                  ),
                  const SizedBox(height: 20),
                  OrangeButton(
                    text: 'Save voice model profiles',
                    onPressed:
                        trainedVoiceProvider.saveTrainedVoiceModelSetting,
                  ),
                  const SizedBox(height: 20),
                  if (trainedVoiceProvider.outputFile.isNotEmpty) ...[
                    // const Text('Success!'),
                    // Text(trainedVoiceProvider.outputFile),
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
