// import 'package:flutter/material.dart';
// import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';
// import '../features/app/splash_screen/splash_screen.dart';
// import '../features/presentation/pages/history_translation.dart';
// import '../features/presentation/pages/home_page.dart';
// import '../features/presentation/pages/login_page.dart';
// import '../features/presentation/pages/sign_up_page.dart';
// import '../features/presentation/pages/voice_synthesis.dart';

// class Routes {
//   static Route<dynamic> generateRoute(RouteSettings settings) {
//     switch (settings.name) {
//       case '/':
//         return MaterialPageRoute(builder: (_) => const SplashScreen());
//       case '/login':
//         return MaterialPageRoute(builder: (_) => const LoginPage());
//       case '/signup':
//         return MaterialPageRoute(builder: (_) => const SignUpPage());
//       case '/main':
//         return MaterialPageRoute(builder: (_) => const MainScreen());
//       default:
//         return MaterialPageRoute(
//           builder: (_) => Scaffold(
//             body: Center(
//               child: Text('No route defined for ${settings.name}'),
//             ),
//           ),
//         );
//     }
//   }
// }

// class MainScreen extends StatelessWidget {
//   const MainScreen({Key? key}) : super(key: key);

//   List<PersistentTabConfig> _buildScreens() {
//     return [
//       PersistentTabConfig(
//         screen: const HomePage(),
//         item: ItemConfig(
//           icon: const Icon(Icons.home),
//           title: "Home",
//         ),
//       ),
//       PersistentTabConfig(
//         screen: const HistoryTranslation(),
//         item: ItemConfig(
//           icon: const Icon(Icons.history),
//           title: "History",
//         ),
//       ),
//       PersistentTabConfig(
//         screen: const VoiceSynthesis(),
//         item: ItemConfig(
//           icon: const Icon(Icons.record_voice_over),
//           title: "Voice",
//         ),
//       ),
//     ];
//   }

//   @override
//   Widget build(BuildContext context) {
//     return PersistentTabView(
//       controller: PersistentTabController(initialIndex: 0),
//       screens: _buildScreens(),
//       navBarBuilder: (navBarConfig) => buildCustomNavBar(navBarConfig),
//     );
//   }

//   Widget buildCustomNavBar(NavBarConfig navBarConfig) {
//     // Build your custom navigation bar here
//     return Container(
//       color: Colors.blue, // Example color, replace with your custom style
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceAround,
//         children: navBarConfig.items.map((item) {
//           return InkWell(
//             onTap: () {
//               navBarConfig.onItemSelected(navBarConfig.items.indexOf(item));
//             },
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Icon(item.icon),
//                 Text(item.title),
//               ],
//             ),
//           );
//         }).toList(),
//       ),
//     );
//   }
// }
