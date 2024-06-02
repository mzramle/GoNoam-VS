import 'dart:io';

import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gonoam_v1/features/app/splash_screen/splash_screen.dart';
import 'package:gonoam_v1/features/presentation/pages/crud_page.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';

import 'features/presentation/pages/login_page.dart';
import 'features/presentation/pages/sign_up_page.dart';
import 'features/presentation/pages/user_profile/update_profile.dart';

import 'features/presentation/widgets/app_bottom_navigation_bar.dart';

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

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'GoNoam Translation',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
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
        GetPage(name: '/update_profile', page: () => const UpdateProfilePage()),
        GetPage(name: '/example_crd', page: () => const CRUDPage()),
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
      navBarBuilder: (navBarConfig) => Style1BottomNavBar(
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
