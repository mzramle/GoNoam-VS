import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class CustomLoadingTranslate extends StatelessWidget {
  const CustomLoadingTranslate({super.key});

  @override
  Widget build(BuildContext context) {
    return Lottie.asset('assets/lottie/loading.json', width: 100);
  }
}
