// import 'package:flutter/material.dart';

// class BottomNavigationBarWidget extends StatelessWidget {
//   final int selectedIndex;
//   final Function(int) onItemSelected;

//   const BottomNavigationBarWidget({
//     required this.selectedIndex,
//     required this.onItemSelected,
//     Key? key,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return BottomNavigationBar(
//       currentIndex: selectedIndex,
//       onTap: onItemSelected,
//       items: const [
//         BottomNavigationBarItem(
//           icon: Icon(Icons.home),
//           label: 'Home',
//         ),
//         BottomNavigationBarItem(
//           icon: Icon(Icons.history),
//           label: 'History',
//         ),
//         BottomNavigationBarItem(
//           icon: Icon(Icons.record_voice_over),
//           label: 'Voice Synthesis',
//         ),
//       ],
//     );
//   }
// }

// import 'package:flutter/material.dart';

// class BottomNavigationBarWidget extends StatelessWidget {
//   final int selectedIndex;
//   final Function(int) onItemSelected;

//   const BottomNavigationBarWidget({
//     super.key,
//     required this.selectedIndex,
//     required this.onItemSelected,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return BottomNavigationBar(
//       items: const <BottomNavigationBarItem>[
//         BottomNavigationBarItem(
//           icon: Icon(Icons.home),
//           label: 'Home',
//         ),
//         BottomNavigationBarItem(
//           icon: Icon(Icons.history),
//           label: 'History',
//         ),
//         BottomNavigationBarItem(
//           icon: Icon(Icons.record_voice_over),
//           label: 'Voice Synthesis',
//         ),
//       ],
//       currentIndex: selectedIndex,
//       onTap: onItemSelected,
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';

import '../pages/favorite_translation_page.dart';
import '../pages/history_translation_page.dart';
import '../pages/home_page.dart';
import '../pages/voice_synthesis.dart';

List<PersistentTabConfig> buildScreens() {
  return [
    PersistentTabConfig(
      screen: const HomePage(),
      item: ItemConfig(
        icon: const Icon(Icons.home),
        title: "Home",
      ),
    ),
    PersistentTabConfig(
      screen: const HistoryTranslationPage(),
      item: ItemConfig(
        icon: const Icon(Icons.history),
        title: "History Translation",
      ),
    ),
    PersistentTabConfig(
      screen: const FavoriteTranslationPage(),
      item: ItemConfig(
        icon: const Icon(Icons.favorite),
        title: "Favorite Translation",
      ),
    ),
    PersistentTabConfig(
      screen: const VoiceSynthesis(),
      item: ItemConfig(
        icon: const Icon(Icons.record_voice_over),
        title: "Voice",
      ),
    ),
  ];
}
