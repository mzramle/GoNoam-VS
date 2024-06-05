import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../model/translation_model.dart';
import '../widgets/translation_box.dart';
import 'package:fluttertoast/fluttertoast.dart';

class FavoriteTranslationPage extends StatefulWidget {
  const FavoriteTranslationPage({Key? key}) : super(key: key);

  @override
  State<FavoriteTranslationPage> createState() =>
      _FavoriteTranslationPageState();
}

class _FavoriteTranslationPageState extends State<FavoriteTranslationPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final List<String> _selectedTranslations = [];
  late ValueNotifier<List<TranslationModel>> _translationsNotifier;

  @override
  void initState() {
    super.initState();
    _translationsNotifier = ValueNotifier<List<TranslationModel>>([]);
    _fetchFavoriteTranslations();
  }

  Future<void> _fetchFavoriteTranslations() async {
    final querySnapshot =
        await _firestore.collection('favorite_translation').get();
    final translations = querySnapshot.docs
        .map((doc) => TranslationModel.fromDocument(doc))
        .toList();
    _translationsNotifier.value = translations;
  }

  void _toggleFavorite(TranslationModel translation) async {
    if (translation.favorite) {
      await _firestore
          .collection('favorite_translation')
          .doc(translation.id)
          .delete();
    } else {
      await _firestore
          .collection('favorite_translation')
          .doc(translation.id)
          .set(translation.toMap());
    }

    await _firestore
        .collection('history_translation')
        .doc(translation.id)
        .update({'favorite': translation.favorite});

    setState(() {
      _translationsNotifier.value = _translationsNotifier.value
          .where((t) => t.id != translation.id)
          .toList();
    });
  }

  void _deleteSelected() async {
    if (_selectedTranslations.isEmpty) {
      Fluttertoast.showToast(
        msg: "Select a translation box to delete!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text(
              'Are you sure you want to delete selected translations?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                for (String id in _selectedTranslations) {
                  _firestore
                      .collection('favorite_translation')
                      .doc(id)
                      .delete();
                }
                setState(() {
                  _selectedTranslations.clear();
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _toggleSelectAll(List<String> translationIds) {
    setState(() {
      if (_selectedTranslations.length == translationIds.length) {
        _selectedTranslations.clear(); // Clear all selections
      } else {
        _selectedTranslations.clear();
        _selectedTranslations.addAll(translationIds); // Select all translations
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorite Translations',
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
        actions: [
          TextButton.icon(
            onPressed: () {
              _toggleSelectAll(
                  _translationsNotifier.value.map((t) => t.id).toList());
            },
            icon: const Icon(Icons.select_all, color: Colors.white),
            label: const Text(
              'Select All',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _fetchFavoriteTranslations();
        },
        child: ValueListenableBuilder<List<TranslationModel>>(
          valueListenable: _translationsNotifier,
          builder: (context, translations, _) {
            if (translations.isEmpty) {
              return const Center(
                  child: Text('No favorite translations found.'));
            } else {
              return ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: translations.length,
                itemBuilder: (context, index) {
                  final translation = translations[index];
                  return TranslationBox(
                    translation: translation,
                    isSelected: _selectedTranslations.contains(translation.id),
                    onFavorite: () => _toggleFavorite(translation),
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
        onPressed: _deleteSelected,
        backgroundColor: Colors.deepOrangeAccent,
        icon: const Icon(Icons.delete, color: Colors.white),
        label: const Text(
          'Delete',
          style: TextStyle(fontSize: 16, color: Colors.white),
        ),
      ),
    );
  }
}
