import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../provider/history_translation_provider.dart';
import '../../widgets/translation_box.dart';
import 'package:provider/provider.dart';

class HistoryTranslationPage extends StatefulWidget {
  const HistoryTranslationPage({super.key});

  @override
  State<HistoryTranslationPage> createState() => _HistoryTranslationPageState();
}

class _HistoryTranslationPageState extends State<HistoryTranslationPage> {
  final List<String> _selectedTranslations = [];

  @override
  void initState() {
    super.initState();
    final provider =
        Provider.of<HistoryTranslationProvider>(context, listen: false);
    provider.fetchTranslationHistory();
  }

  @override
  Widget build(BuildContext context) {
    final historyProvider = Provider.of<HistoryTranslationProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Translation History',
            style:
                GoogleFonts.robotoCondensed(fontSize: 30, color: Colors.white)),
        backgroundColor: Colors.blue,
        actions: [
          TextButton.icon(
            onPressed: () {
              historyProvider.toggleSelectAll(
                  historyProvider.translations.map((t) => t.id).toList(),
                  _selectedTranslations);
              setState(() {});
            },
            icon: const Icon(Icons.select_all, color: Colors.white),
            label:
                const Text('Select All', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await historyProvider.fetchTranslationHistory();
        },
        child: Consumer<HistoryTranslationProvider>(
          builder: (context, provider, child) {
            if (provider.translations.isEmpty) {
              return const Center(child: Text('No translation history found.'));
            } else {
              return ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: provider.translations.length,
                itemBuilder: (context, index) {
                  final translation = provider.translations[index];
                  return TranslationBox(
                    translation: translation,
                    isSelected: _selectedTranslations.contains(translation.id),
                    onFavorite: () async {
                      await provider.confirmToggleFavorite(
                          context, translation);
                      setState(() {});
                    },
                    onSelect: (isSelected) {
                      setState(() {
                        if (isSelected ?? false) {
                          _selectedTranslations.add(translation.id);
                        } else {
                          _selectedTranslations.remove(translation.id);
                        }
                      });
                    },
                  );
                },
              );
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          historyProvider.deleteSelected(_selectedTranslations, context);
          setState(() {});
        },
        backgroundColor: Colors.deepOrangeAccent,
        icon: const Icon(Icons.delete, color: Colors.white),
        label: const Text('Delete',
            style: TextStyle(fontSize: 16, color: Colors.white)),
        heroTag: 'history_translation_Del',
      ),
    );
  }
}
