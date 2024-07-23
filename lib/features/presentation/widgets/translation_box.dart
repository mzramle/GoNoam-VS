import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gonoam_v1/provider/voice_profile_provider.dart';
import 'package:provider/provider.dart';
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
    final voiceProfileProvider = Provider.of<VoiceProfileProvider>(context);
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
                Column(
                  children: [
                    Row(
                      children: [
                        Text(
                          widget.translation.sourceLanguage,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8.0),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.translation.originalText,
                            style: TextStyle(color: Colors.blue[900]),
                          ),
                        ),
                        IconButton(
                          alignment: AlignmentDirectional.bottomEnd,
                          tooltip: 'Copy?',
                          onPressed: () {
                            Clipboard.setData(ClipboardData(
                                    text: widget.translation.originalText))
                                .then((value) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Copied to Clipboard')),
                              );
                            });
                          },
                          icon: const Icon(Icons.copy, color: Colors.blue),
                        ),
                        IconButton(
                          onPressed: () {
                            voiceProfileProvider.decideAndExecuteTTS(
                                widget.translation.originalText,
                                widget.translation.sourceLanguage);
                          },
                          icon: const Icon(Icons.volume_up, color: Colors.blue),
                        ),
                      ],
                    ),
                  ],
                ),
                const Divider(color: Colors.black),
                Column(
                  children: [
                    Row(
                      children: [
                        Text(
                          widget.translation.targetLanguage,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8.0),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.translation.translatedText,
                            style: TextStyle(color: Colors.orange[800]),
                          ),
                        ),
                        IconButton(
                          alignment: AlignmentDirectional.bottomEnd,
                          tooltip: 'Copy?',
                          onPressed: () {
                            Clipboard.setData(ClipboardData(
                                    text: widget.translation.translatedText))
                                .then((value) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Copied to Clipboard')),
                              );
                            });
                          },
                          icon: const Icon(Icons.copy, color: Colors.blue),
                        ),
                        IconButton(
                          onPressed: () {
                            voiceProfileProvider.decideAndExecuteTTS(
                                widget.translation.translatedText,
                                widget.translation.targetLanguage);
                          },
                          icon: const Icon(Icons.volume_up, color: Colors.blue),
                        ),
                      ],
                    )
                  ],
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
