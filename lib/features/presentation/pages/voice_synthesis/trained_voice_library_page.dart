import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class TrainedVoiceLibraryPage extends StatefulWidget {
  const TrainedVoiceLibraryPage({super.key});

  @override
  State<TrainedVoiceLibraryPage> createState() =>
      _TrainedVoiceLibraryPageState();
}

class _TrainedVoiceLibraryPageState extends State<TrainedVoiceLibraryPage> {
  late Future<List<QueryDocumentSnapshot>> _voiceModelsFuture;
  Map<String, dynamic>? _currentSelectedModel;
  String? _selectedFileName;
  final TextEditingController _textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _voiceModelsFuture = _fetchVoiceModels();
    _fetchCurrentVoiceModel();
  }

  Future<List<QueryDocumentSnapshot>> _fetchVoiceModels() async {
    return FirebaseFirestore.instance
        .collection('voice_models')
        .get()
        .then((snapshot) => snapshot.docs);
  }

  Future<void> _fetchCurrentVoiceModel() async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('voice_models')
        .where('currentVoiceModel', isEqualTo: true)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      setState(() {
        _currentSelectedModel = querySnapshot.docs.first.data();
      });
    }
  }

  Future<void> _addVoiceModel() async {
    String? name;
    String? language;
    String? modelPath;

    final existingModelsCount = await FirebaseFirestore.instance
        .collection('voice_models')
        .get()
        .then((snapshot) => snapshot.docs.length);

    if (existingModelsCount >= 5 && mounted) {
      // If 5 or more models exist, inform the user and do not proceed
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Limit Reached'),
          content: const Text('You cannot add more than 5 voice models.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }
    if (!mounted) return;
    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          // Use StatefulBuilder to update the dialog's state
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add Voice Model'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    onChanged: (value) => name = value,
                    decoration: const InputDecoration(hintText: "Name"),
                  ),
                  TextField(
                    onChanged: (value) => language = value,
                    decoration: const InputDecoration(hintText: "Language"),
                  ),
                  TextButton(
                    onPressed: () async {
                      final result = await FilePicker.platform.pickFiles();
                      if (result != null) {
                        modelPath = result.files.single.path;
                        setState(() {
                          // Update the dialog's state to show the selected file name
                          _selectedFileName = result.files.single.name;
                        });
                      }
                    },
                    child: Text(_selectedFileName != null
                        ? 'File: $_selectedFileName'
                        : 'Select Model'),
                  ),
                  if (_selectedFileName !=
                      null) // Display the selected file name if available
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(_selectedFileName!,
                          style: const TextStyle(
                              fontSize: 16, color: Colors.grey)),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    if (name != null && language != null && modelPath != null) {
                      FirebaseFirestore.instance
                          .collection('voice_models')
                          .add({
                        'name': name,
                        'language': language,
                        'modelPath': modelPath,
                        'currentVoiceModel': true,
                      });
                      Navigator.of(context).pop();
                      setState(() {
                        _voiceModelsFuture = _fetchVoiceModels();
                        _fetchCurrentVoiceModel(); // Update the current voice model after adding a new one
                      });
                    }
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void setCurrentVoiceModel(
      String docId, Map<String, dynamic> voiceModel) async {
    // Step 1: Set all models' currentVoiceModel to false
    final batch = FirebaseFirestore.instance.batch();
    final querySnapshot =
        await FirebaseFirestore.instance.collection('voice_models').get();
    for (var doc in querySnapshot.docs) {
      batch.update(doc.reference, {'currentVoiceModel': false});
    }

    // Step 2: Set the selected model's currentVoiceModel to true
    batch.update(
        FirebaseFirestore.instance.collection('voice_models').doc(docId),
        {'currentVoiceModel': true});

    // Execute all updates
    await batch.commit();

    // Step 3: Refresh the UI
    setState(() {
      _currentSelectedModel = voiceModel;
      _voiceModelsFuture =
          _fetchVoiceModels(); // Refresh the list of voice models
    });
  }

  void _readText(String text) {
    // Implement TTS functionality here
    // This is a placeholder for TTS implementation
    // You would typically use a TTS package or API that supports ONNX models
    if (kDebugMode) {
      print("Reading Text: $text");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trained Voice Library',
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              const SizedBox(height: 15),
              if (_currentSelectedModel != null) ...[
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Current Trained Voice Model',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 45.0),
                  child: Divider(color: Colors.black),
                ),
                ListTile(
                  title: Text(_currentSelectedModel!['name'],
                      style: const TextStyle(color: Color(0xFF242C75))),
                  subtitle: Text(_currentSelectedModel!['language'],
                      style: const TextStyle(color: Colors.grey)),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _textEditingController,
                    decoration:
                        const InputDecoration(hintText: 'Enter text here'),
                  ),
                ),
                // 4. Add a Button
                ElevatedButton(
                  onPressed: () {
                    // 5. Implement TTS Functionality
                    _readText(_textEditingController.text);
                  },
                  child: const Text('Read Text'),
                ),
              ],
              Align(
                alignment: Alignment.bottomCenter,
                child: Draggable(
                  feedback: Material(
                    type: MaterialType
                        .transparency, // Needed to avoid any background color
                    child: Row(
                      mainAxisSize:
                          MainAxisSize.min, // To wrap the content of the row
                      children: [
                        FloatingActionButton(
                          onPressed: _addVoiceModel,
                          backgroundColor: Colors.orange,
                          child: const Icon(Icons.add),
                        ),
                        const SizedBox(
                            width: 8), // Space between button and text
                        const Text("Add Voice Model",
                            style: TextStyle(
                                color: Color(
                                    0xFF242C75))), // Assuming you want white text
                      ],
                    ),
                  ),
                  childWhenDragging:
                      Container(), // Display nothing when dragging
                  child: Material(
                    type:
                        MaterialType.transparency, // Avoid any background color
                    child: Row(
                      mainAxisSize: MainAxisSize.min, // Wrap the content
                      children: [
                        FloatingActionButton(
                          onPressed: _addVoiceModel,
                          backgroundColor: Colors.orange,
                          child: const Icon(Icons.add),
                        ),
                        const SizedBox(
                            width: 8), // Space between button and text
                        const Text("Add Voice Model",
                            style: TextStyle(
                                color: Color(
                                    0xFF242C75))), // Assuming you want white text
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 23,
              ),
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('Choose Trained Voice Model',
                    style:
                        TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 45.0),
                child: Divider(color: Colors.black),
              ),
              Flexible(
                child: FutureBuilder<List<QueryDocumentSnapshot>>(
                  future: _voiceModelsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (snapshot.data == null ||
                        snapshot.data!.isEmpty) {
                      return const Center(child: Text('No voice models found'));
                    } else {
                      return ListView.separated(
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          final doc = snapshot.data![index];
                          final voiceModel = doc.data() as Map<String, dynamic>;
                          return ListTile(
                            title: Text(
                              voiceModel['name'],
                              style: const TextStyle(color: Color(0xFF242C75)),
                            ),
                            subtitle: Text(voiceModel['language']),
                            trailing: IconButton(
                              icon: const Icon(
                                Icons.check_circle_rounded,
                                color: Colors.orange,
                                size: 35,
                              ),
                              onPressed: () =>
                                  setCurrentVoiceModel(doc.id, voiceModel),
                            ),
                          );
                        },
                        separatorBuilder: (context, index) => const Divider(),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
