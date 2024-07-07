import 'package:flutter/material.dart';
import 'package:gonoam_v1/features/presentation/widgets/orange_button.dart';
import 'package:provider/provider.dart';
import '../../../../provider/trained_voice_library_work_provider.dart';

class TrainedVoiceLibraryWork extends StatelessWidget {
  const TrainedVoiceLibraryWork({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TrainedVoiceProvider(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Manage Trained Voice Library'),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Consumer<TrainedVoiceProvider>(
            builder: (context, trainedVoiceProvider, child) {
              return ListView(
                children: [
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Select Model',
                    ),
                    value: trainedVoiceProvider.selectedModel,
                    items: trainedVoiceProvider.models.map((String model) {
                      return DropdownMenuItem<String>(
                        value: model,
                        child: SizedBox(
                          width: 300, // Set a fixed width for the container
                          child: Text(
                            model,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      trainedVoiceProvider.selectedModel = newValue;
                    },
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Select Index',
                    ),
                    value: trainedVoiceProvider.selectedIndex,
                    items: trainedVoiceProvider.indexes.map((String index) {
                      return DropdownMenuItem<String>(
                        value: index,
                        child: SizedBox(
                          width: 300, // Set a fixed width for the container
                          child: Text(
                            index,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      trainedVoiceProvider.selectedIndex = newValue;
                    },
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    menuMaxHeight: 300,
                    decoration: const InputDecoration(
                      labelText: 'Select Voice',
                    ),
                    value: trainedVoiceProvider.selectedVoice,
                    items: trainedVoiceProvider.voices.map((voice) {
                      return DropdownMenuItem<String>(
                        value: voice.shortName,
                        child: SizedBox(
                          width: 300,
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  voice.shortName,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                "(${voice.gender})",
                                style: const TextStyle(
                                  fontStyle: FontStyle.italic,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      trainedVoiceProvider.selectedVoice = newValue;
                    },
                  ),
                  const SizedBox(height: 20),
                  Text('TTS Rate: ${trainedVoiceProvider.ttsRate}'),
                  Slider(
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
                  Slider(
                    label: "Pitch",
                    value: trainedVoiceProvider.pitch,
                    min: -100,
                    max: 100,
                    onChanged: (newValue) {
                      trainedVoiceProvider.pitch = newValue;
                    },
                  ),
                  Text('Filter Radius: ${trainedVoiceProvider.filterRadius}'),
                  Slider(
                    label: "Filter Radius",
                    value: trainedVoiceProvider.filterRadius,
                    min: 1,
                    max: 10,
                    onChanged: (newValue) {
                      trainedVoiceProvider.filterRadius = newValue;
                    },
                  ),
                  Text('Index Rate: ${trainedVoiceProvider.indexRate}'),
                  Slider(
                    label: "Index Rate",
                    value: trainedVoiceProvider.indexRate,
                    min: 0,
                    max: 1,
                    onChanged: (newValue) {
                      trainedVoiceProvider.indexRate = newValue;
                    },
                  ),
                  Text('RMS Mix Rate: ${trainedVoiceProvider.rmsMixRate}'),
                  Slider(
                    label: "RMS Mix Rate",
                    value: trainedVoiceProvider.rmsMixRate,
                    min: 0,
                    max: 1,
                    onChanged: (newValue) {
                      trainedVoiceProvider.rmsMixRate = newValue;
                    },
                  ),
                  Text('Protect: ${trainedVoiceProvider.protect}'),
                  Slider(
                    label: "Protect",
                    value: trainedVoiceProvider.protect,
                    min: 0,
                    max: 1,
                    onChanged: (newValue) {
                      trainedVoiceProvider.protect = newValue;
                    },
                  ),
                  Text('Hop Length: ${trainedVoiceProvider.hopLength}'),
                  Slider(
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
                            title: Text(method),
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
