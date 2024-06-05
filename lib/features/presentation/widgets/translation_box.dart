import 'package:flutter/material.dart';
import '../../../model/translation_model.dart';

class TranslationBox extends StatefulWidget {
  final TranslationModel translation;
  final bool isSelected;
  final VoidCallback onFavorite;
  final ValueChanged<bool?> onSelect;

  const TranslationBox({
    super.key,
    required this.translation,
    required this.isSelected,
    required this.onFavorite,
    required this.onSelect,
  });

  @override
  State<TranslationBox> createState() => _TranslationBoxState();
}

class _TranslationBoxState extends State<TranslationBox> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.translation.sourceLanguage,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8.0),
                Text(
                  widget.translation.originalText,
                  style: TextStyle(color: Colors.blue[900]),
                ),
                const Divider(color: Colors.black),
                Text(
                  widget.translation.targetLanguage,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8.0),
                Text(
                  widget.translation.translatedText,
                  style: TextStyle(color: Colors.orange[800]),
                ),
              ],
            ),
          ),
          Column(
            children: [
              IconButton(
                icon: Icon(
                  widget.translation.favorite ? Icons.star : Icons.star_border,
                  color:
                      widget.translation.favorite ? Colors.yellow : Colors.grey,
                ),
                onPressed: widget.onFavorite,
              ),
              Checkbox(
                value: widget.isSelected,
                onChanged: widget.onSelect,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
