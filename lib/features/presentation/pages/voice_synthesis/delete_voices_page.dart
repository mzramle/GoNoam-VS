import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:gonoam_v1/helper/toast.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../../../../provider/voice_sample_provider.dart'; // For date formatting

class DeleteVoicesPage extends StatefulWidget {
  const DeleteVoicesPage({super.key});

  @override
  State<DeleteVoicesPage> createState() => _DeleteVoicesPageState();
}

class _DeleteVoicesPageState extends State<DeleteVoicesPage> {
  late Future<List<QueryDocumentSnapshot>> _voiceSamplesFuture;

  @override
  void initState() {
    super.initState();
    _voiceSamplesFuture = _fetchVoiceSamples();
  }

  Future<List<QueryDocumentSnapshot>> _fetchVoiceSamples() {
    final voiceSampleProvider =
        Provider.of<VoiceSampleProvider>(context, listen: false);
    return voiceSampleProvider.fetchVoiceSamples();
  }

  Future<List<QueryDocumentSnapshot>> _fetchVoiceModels() async {
    return FirebaseFirestore.instance
        .collection('voice_model_setting')
        .get()
        .then((snapshot) => snapshot.docs);
  }

  Widget _buildVoiceModelList() {
    return FutureBuilder<List<QueryDocumentSnapshot>>(
      future: _fetchVoiceModels(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.data == null || snapshot.data!.isEmpty) {
          return const Center(child: Text('No voice model settings found'));
        } else {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final doc = snapshot.data![index];
              final voiceModelSetting = doc.data() as Map<String, dynamic>;
              // Define colors
              final bgColor = index % 2 == 0
                  ? const Color.fromARGB(255, 199, 222, 232)
                  : const Color(0xFFFFE0E0); // Light cherry color as an example
              return Container(
                color: bgColor,
                child: ExpansionTile(
                  title: Text(
                      '${voiceModelSetting['model_name']} - ${voiceModelSetting['model_language']}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteVoiceModel(doc.id),
                  ),
                  children: voiceModelSetting.entries.map<Widget>((entry) {
                    // Use the utility function to format field names
                    String formattedFieldName = formatFieldName(entry.key);
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Card(
                        elevation: 4, // Adds shadow
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(10), // Rounded corners
                        ),
                        child: ListTile(
                          title: Text(
                            '$formattedFieldName: ${entry.value}',
                            style: const TextStyle(
                              color: Colors.deepPurple, // Custom text color
                              fontWeight: FontWeight.bold, // Makes text bold
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              );
            },
          );
        }
      },
    );
  }

  String formatFieldName(String fieldName) {
    // Split the string by underscores, capitalize each word, and join them with spaces
    return fieldName
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  Future<void> moveAudioFileToAccessibleLocation(String docId) async {
    try {
      // Fetch the document from Firestore
      DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
          .collection('voice_samples')
          .doc(docId)
          .get();

      if (!docSnapshot.exists) {
        showErrorToast('Document does not exist');
        return;
      }

      String? audioPath = docSnapshot['audioPath'];
      if (audioPath == null) {
        showErrorToast('Audio path is missing');
        return;
      }

      File originalFile = File(audioPath);
      if (!await originalFile.exists()) {
        showErrorToast('Original audio file does not exist');
        return;
      }

      // Determine the new location (e.g., external storage directory)
      Directory? externalDir = await getExternalStorageDirectory();
      if (externalDir == null) {
        showErrorToast('External storage directory not found');
        return;
      }

      String newFilePath =
          '${externalDir.path}/${originalFile.uri.pathSegments.last}';
      await originalFile.copy(newFilePath);

      // Optionally, delete the original file
      // await originalFile.delete();

      showNormalToast('File moved to $newFilePath');
    } catch (e) {
      showErrorToast('Failed to move file: $e');
    }
  }

  Future<void> _deleteVoiceModel(String docId) async {
    await FirebaseFirestore.instance
        .collection('voice_models')
        .doc(docId)
        .delete();
    setState(() {
      _voiceSamplesFuture = _fetchVoiceSamples();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Access VoiceSampleProvider from the context
    final voiceSampleProvider = Provider.of<VoiceSampleProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Delete Voices', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Consumer<VoiceSampleProvider>(
        builder: (context, provider, child) {
          return FutureBuilder<List<QueryDocumentSnapshot>>(
            future: _voiceSamplesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (snapshot.data == null || snapshot.data!.isEmpty) {
                return const Center(child: Text('No voice samples found'));
              } else {
                return Column(
                  children: [
                    const SizedBox(height: 15),
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Voice Samples',
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold)),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal:
                              45.0), // Adjust the horizontal padding as needed
                      child: Divider(color: Colors.black),
                    ),
                    Expanded(
                      child: ListView.separated(
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          final doc = snapshot.data![index];
                          final voiceSample =
                              doc.data() as Map<String, dynamic>;
                          final creationDate =
                              (voiceSample['timeCreated'] as Timestamp)
                                  .toDate();
                          final formattedDate =
                              DateFormat('dd/MM/yyyy').format(creationDate);
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              const SizedBox(width: 15),
                              Card(
                                color: const Color.fromARGB(255, 237, 223, 223),
                                child: Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Text(voiceSample['chosenLanguage']),
                                ),
                              ),
                              Expanded(
                                child: Card(
                                  color: const Color(0xFF242C75),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(voiceSample['voiceSampleName'],
                                            style: const TextStyle(
                                                color: Colors.white)),
                                        Text(formattedDate,
                                            style: const TextStyle(
                                                color: Colors.white70)),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Card(
                                color: Colors.deepOrange,
                                child: IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.white),
                                  onPressed: () async {
                                    await voiceSampleProvider
                                        .deleteVoiceSample(doc.id);
                                    setState(() {
                                      _voiceSamplesFuture =
                                          _fetchVoiceSamples();
                                    });
                                  },
                                ),
                              ),
                              Card(
                                color: Colors.blueGrey[900],
                                child: IconButton(
                                  icon: const Icon(Icons.drive_file_move,
                                      color: Colors.white),
                                  onPressed: () =>
                                      moveAudioFileToAccessibleLocation(doc.id),
                                ),
                              ),
                              const SizedBox(width: 15),
                            ],
                          );
                        },
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 10),
                      ),
                    ),
                    const Text('Voice Model Profiles',
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold)),
                    const Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal:
                              45.0), // Adjust the horizontal padding as needed
                      child: Divider(color: Colors.black),
                    ),
                    Expanded(child: _buildVoiceModelList()),
                  ],
                );
              }
            },
          );
        },
      ),
    );
  }
}
