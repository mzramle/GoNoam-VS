import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';

import '../pages/translation/favorite_translation_page.dart';
import '../pages/translation/history_translation_page.dart';
import '../pages/home_page.dart';
import '../pages/voice_synthesis/voice_synthesis_main_page.dart';

List<PersistentTabConfig> buildScreens() {
  return [
    PersistentTabConfig(
      screen: const HomePage(),
      item: ItemConfig(
        icon: const Icon(Icons.home),
        title: "Home",
        activeForegroundColor: Colors.lightBlue,
        activeColorSecondary: Colors.amber,
      ),
    ),
    PersistentTabConfig(
      screen: const HistoryTranslationPage(),
      item: ItemConfig(
          icon: const Icon(Icons.history),
          title: "History Translation",
          activeForegroundColor: Colors.teal,
          activeColorSecondary: Colors.lime[200]),
    ),
    PersistentTabConfig(
      screen: const FavoriteTranslationPage(),
      item: ItemConfig(
        icon: const Icon(Icons.favorite),
        title: "Favorite Translation",
        activeForegroundColor: Colors.red,
        activeColorSecondary: Colors.yellowAccent,
      ),
    ),
    PersistentTabConfig(
      screen: const VoiceSynthesisMainPage(),
      item: ItemConfig(
        icon: const Icon(Icons.record_voice_over),
        title: "Voice",
        activeForegroundColor: Color.fromARGB(255, 249, 207, 102),
        activeColorSecondary: Colors.blueGrey[600],
      ),
    ),
  ];
}
