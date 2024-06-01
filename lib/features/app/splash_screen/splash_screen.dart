import 'package:flutter/material.dart';
import 'package:gonoam_v1/features/presentation/pages/login_page.dart';

import '../../../helper/global.dart';

class SplashScreen extends StatefulWidget {
  final Function? onInitializationComplete;

  const SplashScreen({Key? key, this.onInitializationComplete})
      : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  void _navigateToNextScreen() async {
    await Future.delayed(const Duration(seconds: 3));

    if (widget.onInitializationComplete != null) {
      widget.onInitializationComplete!();
    }
  }

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.sizeOf(context);

    return const Scaffold(
      body: Center(
        child: Text(
          "Welcome To GoNoam",
          style: TextStyle(
            color: Colors.blue,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
