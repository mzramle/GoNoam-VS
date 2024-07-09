import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class CustomSplashGlobalTranslate extends StatelessWidget {
  const CustomSplashGlobalTranslate({super.key});

  @override
  Widget build(BuildContext context) {
    return Lottie.asset('assets/lottie/GlobalWorldTranslation.json',
        width: 200, height: 200);
  }
}
