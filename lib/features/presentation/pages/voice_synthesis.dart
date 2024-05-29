import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../widgets/app_bottom_navigation_bar.dart';

class VoiceSynthesis extends StatelessWidget {
  const VoiceSynthesis({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voice Synthesis'),
      ),
      body: Center(
        child: Text('Voice Synthesis Page Content'),
      ),
      bottomNavigationBar: BottomNavigationBarWidget(
        selectedIndex: 2,
        onItemSelected: (index) {
          if (index == 2) return;
          if (index == 0)
            Get.offNamed('/home');
          else if (index == 1) Get.offNamed('/history_translation');
        },
      ),
    );
  }
}
