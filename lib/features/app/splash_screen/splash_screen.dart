import 'package:flutter/material.dart';
import '../../../helper/global.dart';

class SplashScreen extends StatefulWidget {
  final Function? onInitializationComplete;

  const SplashScreen({super.key, this.onInitializationComplete});

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

    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/images/GoNoam_bg_L.png',
                  fit: BoxFit.cover,
                ),
                const SizedBox(height: 20),
                const Text(
                  "Welcome To GoNoam",
                  style: TextStyle(
                    color: Colors.indigoAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
