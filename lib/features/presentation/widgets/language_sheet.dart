import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../controller/language_provider.dart';

class LanguageSheet extends StatefulWidget {
  final String selectedLanguage;
  final Function(String) onLanguageSelected;

  const LanguageSheet({
    super.key,
    required this.selectedLanguage,
    required this.onLanguageSelected,
  });

  @override
  State<LanguageSheet> createState() => _LanguageSheetState();
}

class _LanguageSheetState extends State<LanguageSheet> {
  String _search = '';

  @override
  Widget build(BuildContext context) {
    //final languageProvider = Provider.of<LanguageProvider>(context);

    return Container(
      height: MediaQuery.of(context).size.height * .5,
      padding: EdgeInsets.only(
          left: MediaQuery.of(context).size.width * .04,
          right: MediaQuery.of(context).size.width * .04,
          top: MediaQuery.of(context).size.height * .02),
      decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(15), topRight: Radius.circular(15))),
      child: Column(
        children: [
          TextFormField(
            onChanged: (s) {
              setState(() {
                _search = s.toLowerCase();
              });
            },
            decoration: const InputDecoration(
                prefixIcon: Icon(Icons.translate_rounded, color: Colors.blue),
                hintText: 'Search Language...',
                hintStyle: TextStyle(fontSize: 14),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)))),
          ),
          Expanded(
            child: Consumer<LanguageProvider>(
              builder: (context, languageProvider, child) {
                final List<String> list = _search.isEmpty
                    ? languageProvider.languages
                    : languageProvider.languages
                        .where((e) => e.toLowerCase().contains(_search))
                        .toList();

                return ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: list.length,
                  padding: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height * .02, left: 6),
                  itemBuilder: (ctx, i) {
                    return InkWell(
                      onTap: () {
                        widget.onLanguageSelected(list[i]);
                        log(list[i]);
                        Navigator.of(context).pop();
                      },
                      child: Padding(
                        padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).size.height * .02),
                        child: Text(list[i]),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
