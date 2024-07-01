import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';
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
    // Access VoiceSampleProvider from the context
    final voiceSampleProvider =
        Provider.of<VoiceSampleProvider>(context, listen: false);
    return voiceSampleProvider.fetchVoiceSamples();
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
                                // Card for chosen language
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
                                // Card for delete button
                                color: Colors.deepOrange,
                                child: IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.white),
                                  onPressed: () async {
                                    await voiceSampleProvider
                                        .deleteVoiceSample(doc.id);
                                    setState(() {
                                      _voiceSamplesFuture =
                                          _fetchVoiceSamples(); // Refresh the list
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 15),
                            ],
                          );
                        },
                        separatorBuilder: (context, index) => const SizedBox(
                            height: 10), // Add space between rows
                      ),
                    ),
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
