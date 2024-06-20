// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../../../model/translation_model.dart';
// import '../widgets/translation_box.dart';
// import 'package:fluttertoast/fluttertoast.dart';

// class HistoryTranslationPage extends StatefulWidget {
//   const HistoryTranslationPage({Key? key}) : super(key: key);

//   @override
//   State<HistoryTranslationPage> createState() => _HistoryTranslationPageState();
// }

// class _HistoryTranslationPageState extends State<HistoryTranslationPage> {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final List<String> _selectedTranslations = [];

//   Future<List<TranslationModel>> _fetchTranslationHistory() async {
//     final querySnapshot =
//         await _firestore.collection('history_translation').get();
//     return querySnapshot.docs
//         .map((doc) => TranslationModel.fromDocument(doc))
//         .toList();
//   }

//   void _toggleFavorite(TranslationModel translation) async {
//     setState(() {
//       translation.favorite = !translation.favorite;
//     });

//     if (translation.favorite) {
//       await _firestore
//           .collection('favourite_translation')
//           .doc(translation.id)
//           .set(translation.toMap());
//     } else {
//       await _firestore
//           .collection('favourite_translation')
//           .doc(translation.id)
//           .delete();
//     }

//     await _firestore
//         .collection('history_translation')
//         .doc(translation.id)
//         .update({'favorite': translation.favorite});
//   }

//   void _deleteSelected() async {
//     if (_selectedTranslations.isEmpty) {
//       Fluttertoast.showToast(
//         msg: "Select a translation box to delete!",
//         toastLength: Toast.LENGTH_SHORT,
//         gravity: ToastGravity.CENTER,
//       );
//       return;
//     }

//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('Confirm Deletion'),
//           content: const Text(
//               'Are you sure you want to delete selected translations?'),
//           actions: <Widget>[
//             TextButton(
//               child: const Text('Cancel'),
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//             ),
//             TextButton(
//               child: const Text('Delete'),
//               onPressed: () {
//                 for (String id in _selectedTranslations) {
//                   _firestore.collection('history_translation').doc(id).delete();
//                 }
//                 setState(() {
//                   _selectedTranslations.clear();
//                 });
//                 Navigator.of(context).pop();
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }

//   void _toggleSelectAll(List<String> translationIds) {
//     setState(() {
//       if (_selectedTranslations.length == translationIds.length) {
//         _selectedTranslations.clear(); // Clear all selections
//       } else {
//         _selectedTranslations.clear();
//         _selectedTranslations.addAll(translationIds); // Select all translations
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Translation History',
//             style: TextStyle(color: Colors.white)),
//         backgroundColor: Colors.blue,
//         actions: [
//           TextButton.icon(
//             onPressed: () {
//               _fetchTranslationHistory().then((translations) {
//                 final translationIds = translations.map((t) => t.id).toList();
//                 _toggleSelectAll(translationIds);
//               });
//             },
//             icon: const Icon(Icons.select_all, color: Colors.white),
//             label: const Text(
//               'Select All',
//               style: TextStyle(color: Colors.white),
//             ),
//           ),
//         ],
//       ),
//       body: RefreshIndicator(
//         onRefresh: () => _fetchTranslationHistory(),
//         child: SingleChildScrollView(
//           child: Container(
//             padding: const EdgeInsets.all(16.0),
//             child: FutureBuilder<List<TranslationModel>>(
//               future: _fetchTranslationHistory(),
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return const Center(child: CircularProgressIndicator());
//                 } else if (snapshot.hasError) {
//                   return Center(child: Text('Error: ${snapshot.error}'));
//                 } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//                   return const Center(
//                       child: Text('No translation history found.'));
//                 } else {
//                   final translations = snapshot.data!;
//                   return ListView.builder(
//                     shrinkWrap: true,
//                     physics: const NeverScrollableScrollPhysics(),
//                     itemCount: translations.length,
//                     itemBuilder: (context, index) {
//                       final translation = translations[index];
//                       return TranslationBox(
//                         translation: translation,
//                         isSelected:
//                             _selectedTranslations.contains(translation.id),
//                         onFavorite: () => _toggleFavorite(translation),
//                         onSelect: (isSelected) {
//                           setState(() {
//                             if (isSelected ?? false) {
//                               _selectedTranslations.add(translation.id);
//                             } else {
//                               _selectedTranslations.remove(translation.id);
//                             }
//                           });
//                         },
//                       );
//                     },
//                   );
//                 }
//               },
//             ),
//           ),
//         ),
//       ),
//       floatingActionButton: FloatingActionButton.extended(
//         onPressed: _deleteSelected,
//         backgroundColor: Colors.deepOrangeAccent,
//         icon: const Icon(Icons.delete, color: Colors.white),
//         label: const Text(
//           'Delete',
//           style: TextStyle(fontSize: 16, color: Colors.white),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../model/translation_model.dart';
import '../../widgets/translation_box.dart';
import 'package:fluttertoast/fluttertoast.dart';

class HistoryTranslationPage extends StatefulWidget {
  const HistoryTranslationPage({Key? key}) : super(key: key);

  @override
  State<HistoryTranslationPage> createState() => _HistoryTranslationPageState();
}

class _HistoryTranslationPageState extends State<HistoryTranslationPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final List<String> _selectedTranslations = [];
  late ValueNotifier<List<TranslationModel>> _translationsNotifier;

  @override
  void initState() {
    super.initState();
    _translationsNotifier = ValueNotifier<List<TranslationModel>>([]);
    _fetchTranslationHistory();
  }

  Future<void> _fetchTranslationHistory() async {
    final querySnapshot =
        await _firestore.collection('history_translation').get();
    final translations = querySnapshot.docs
        .map((doc) => TranslationModel.fromDocument(doc))
        .toList();
    _translationsNotifier.value = translations;
  }

  Future<void> _toggleFavorite(TranslationModel translation) async {
    translation.favorite = !translation.favorite;

    if (translation.favorite) {
      await _firestore
          .collection('favorite_translation')
          .doc(translation.id)
          .set(translation.toMap());
    } else {
      await _firestore
          .collection('favorite_translation')
          .doc(translation.id)
          .delete();
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

  Future<void> _confirmToggleFavorite(TranslationModel translation) async {
    final bool isFavorite = translation.favorite;
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm ${isFavorite ? "Remove" : "Add"} Favorite'),
          content: Text(
              'Are you sure you want to ${isFavorite ? "remove" : "add"} this translation to favorites?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );

    if (confirm != null && confirm) {
      if (isFavorite) {
        // If the translation was already favorited, remove it from the favorites collection
        await _toggleFavorite(translation);
      } else {
        // If the translation was not favorited, toggle the favorite status and delete it
        await _toggleFavorite(translation);
        await _deleteTranslation(translation);
        await _fetchTranslationHistory();
      }
    }
  }

  Future<void> _deleteTranslation(TranslationModel translation) async {
    await _firestore
        .collection('history_translation')
        .doc(translation.id)
        .delete();
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
                  _firestore.collection('history_translation').doc(id).delete();
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
        title: const Text('Translation History',
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
          await _fetchTranslationHistory();
        },
        child: ValueListenableBuilder<List<TranslationModel>>(
          valueListenable: _translationsNotifier,
          builder: (context, translations, _) {
            if (translations.isEmpty) {
              return const Center(child: Text('No translation history found.'));
            } else {
              return ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: translations.length,
                itemBuilder: (context, index) {
                  final translation = translations[index];
                  return TranslationBox(
                    translation: translation,
                    isSelected: _selectedTranslations.contains(translation.id),
                    onFavorite: () => _confirmToggleFavorite(translation),
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
        heroTag: 'history_translation_Del',
      ),
    );
  }
}
