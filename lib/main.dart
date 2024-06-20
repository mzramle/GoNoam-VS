import 'dart:io';
<<<<<<< Updated upstream

=======
import 'package:firebase_app_check/firebase_app_check.dart';
>>>>>>> Stashed changes
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gonoam_v1/features/app/splash_screen/splash_screen.dart';
<<<<<<< Updated upstream

import 'features/presentation/pages/history_translation.dart';
import 'features/presentation/pages/home_page.dart';
import 'features/presentation/pages/login_page.dart';
import 'features/presentation/pages/sign_up_page.dart';
import 'features/presentation/pages/voice_synthesis.dart';
import 'helper/global.dart';
=======
import 'package:gonoam_v1/features/presentation/pages/test_excrd/crud_page.dart';
import 'package:gonoam_v1/features/presentation/pages/voice_synthesis/voice_synthesis_main_page.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';
import 'package:provider/provider.dart';

import 'controller/language_controller.dart';
import 'features/presentation/pages/translation/favorite_translation_page.dart';
import 'features/presentation/pages/translation/history_translation_page.dart';
import 'features/presentation/pages/auth/login_page.dart';
import 'features/presentation/pages/auth/sign_up_page.dart';
import 'features/presentation/pages/user_profile/user_profile_page.dart';
import 'features/presentation/widgets/app_bottom_navigation_bar.dart';
import 'provider/voice_sample_provider.dart';
>>>>>>> Stashed changes

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Platform.isAndroid
      ? await Firebase.initializeApp(
          options: const FirebaseOptions(
          apiKey: 'AIzaSyAPbVt3YaG46KwOCNKp7NvShhXKIPC_5Rw',
          appId: '1:404868130577:android:51279e8b70cfe1ca8d4eb',
          messagingSenderId: '404868130577',
          projectId: 'gonoam-v1',
        ))
      : await Firebase.initializeApp();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => VoiceSampleProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(
              child: LoginPage(),
            ),
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignUpPage(),
        '/home': (context) => const HomePage(),
        '/history_translation': (context) => const HistoryTranslation(),
        '/voice_synthesis': (context) => const VoiceSynthesis(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}

extension AppTheme on ThemeData {
  //light text color
  Color get lightTextColor =>
      brightness == Brightness.dark ? Colors.white70 : Colors.black54;

  //button color
  Color get buttonColor =>
      brightness == Brightness.dark ? Colors.cyan.withOpacity(.5) : Colors.blue;
}
