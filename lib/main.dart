import 'dart:io';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gonoam_v1/features/app/splash_screen/splash_screen.dart';
import 'package:gonoam_v1/features/presentation/pages/voice_synthesis/adjust_voice_page.dart';
import 'package:gonoam_v1/provider/trained_voice_library_work_provider.dart';
import 'features/presentation/pages/translation/favorite_translation_page.dart';
import 'features/presentation/pages/translation/history_translation_page.dart';
import 'features/presentation/pages/auth/login_page.dart';
import 'features/presentation/pages/auth/sign_up_page.dart';
import 'features/presentation/pages/user_profile/user_profile_page.dart';
import 'package:gonoam_v1/features/presentation/pages/voice_synthesis/create_voice_sample_page.dart';
import 'package:gonoam_v1/features/presentation/pages/voice_synthesis/voice_synthesis_main_page.dart';
import 'features/presentation/pages/voice_synthesis/delete_voices_page.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';
import 'features/presentation/pages/voice_synthesis/trained_voice_library_work_page.dart';
import 'features/presentation/widgets/app_bottom_navigation_bar.dart';
import 'package:provider/provider.dart';
import 'provider/user_profile_provider.dart';
import 'provider/voice_profile_provider.dart';
import 'provider/voice_sample_provider.dart';
import 'provider/history_translation_provider.dart';
import 'provider/language_provider.dart';
import 'provider/translator_provider.dart';

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
  await FirebaseAppCheck.instance.activate(
    webProvider: ReCaptchaV3Provider('recaptcha-v3-site-key'),
    androidProvider: AndroidProvider.debug,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => HistoryTranslationProvider()),
        ChangeNotifierProvider(create: (_) => TranslateProvider()),
        ChangeNotifierProvider(create: (_) => TrainedVoiceProvider()),
        ChangeNotifierProvider(create: (_) => UserProfileProvider()),
        ChangeNotifierProvider(create: (_) => VoiceSampleProvider()),
        ChangeNotifierProvider(create: (_) => VoiceProfileProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'GoNoam Translation',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
        useMaterial3: true,
      ),
      initialRoute: '/splash',
      getPages: [
        GetPage(
          name: '/splash',
          page: () => SplashScreen(
            onInitializationComplete: () {
              Get.offNamed('/login');
            },
          ),
        ),
        GetPage(name: '/login', page: () => const LoginPage()),
        GetPage(name: '/signup', page: () => const SignUpPage()),
        GetPage(name: '/main', page: () => MainScreen()),
        GetPage(name: '/user_profile', page: () => const UserProfilePage()),
        // GetPage(name: '/stt_test', page: () => const SttTestWidget()),
        // GetPage(name: '/example_crd', page: () => const CRUDPage()),
        GetPage(
            name: '/history_translation_page',
            page: () => const HistoryTranslationPage()),
        GetPage(
            name: '/favorite_translation_page',
            page: () => const FavoriteTranslationPage()),
        GetPage(
            name: '/voice_synthesis_page',
            page: () => const VoiceSynthesisMainPage()),
        GetPage(
            name: '/create_voice_sample_page',
            page: () => const CreateVoiceSamplePage()),
        GetPage(
            name: '/adjust_voice_profile_page',
            page: () => const AdjustVoiceProfilePage()),
        GetPage(
            name: '/trained_voice_library_work_page',
            page: () => const TrainedVoiceLibraryWork()),
        GetPage(
            name: '/delete_voices_page', page: () => const DeleteVoicesPage()),
        GetPage(name: '/logout_sign_in_page', page: () => const SplashScreen()),
      ],
    );
  }
}

class MainScreen extends StatelessWidget {
  final PersistentTabController _controller =
      PersistentTabController(initialIndex: 0);
  MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PersistentTabView(
      controller: _controller,
      tabs: buildScreens(),
      navBarBuilder: (navBarConfig) => Style2BottomNavBar(
        navBarDecoration: NavBarDecoration(
          borderRadius: BorderRadius.circular(4),
        ),
        navBarConfig: navBarConfig,
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
