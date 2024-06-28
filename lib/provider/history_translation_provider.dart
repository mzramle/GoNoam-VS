import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../model/translation_model.dart';
import 'package:fluttertoast/fluttertoast.dart';

class HistoryTranslationProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<TranslationModel> _translations = [];

  List<TranslationModel> get translations => _translations;

  Future<void> fetchTranslationHistory() async {
    final querySnapshot =
        await _firestore.collection('history_translation').get();
    _translations = querySnapshot.docs
        .map((doc) => TranslationModel.fromDocument(doc))
        .toList();
    notifyListeners();
  }

  Future<void> toggleFavorite(TranslationModel translation) async {
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

    _translations = _translations.where((t) => t.id != translation.id).toList();
    notifyListeners();
  }

  Future<void> confirmToggleFavorite(
      BuildContext context, TranslationModel translation) async {
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
        await toggleFavorite(translation);
      } else {
        await toggleFavorite(translation);
        await deleteTranslation(translation);
        await fetchTranslationHistory();
      }
    }
  }

  Future<void> deleteTranslation(TranslationModel translation) async {
    await _firestore
        .collection('history_translation')
        .doc(translation.id)
        .delete();
    await fetchTranslationHistory();
  }

  void deleteSelected(
      List<String> selectedTranslations, BuildContext context) async {
    if (selectedTranslations.isEmpty) {
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
                for (String id in selectedTranslations) {
                  _firestore.collection('history_translation').doc(id).delete();
                }
                selectedTranslations.clear();
                fetchTranslationHistory();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void toggleSelectAll(
      List<String> translationIds, List<String> selectedTranslations) {
    if (selectedTranslations.length == translationIds.length) {
      selectedTranslations.clear();
    } else {
      selectedTranslations.clear();
      selectedTranslations.addAll(translationIds);
    }
    notifyListeners();
  }
}
