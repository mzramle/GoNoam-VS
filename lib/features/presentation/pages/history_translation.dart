import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../widgets/app_bottom_navigation_bar.dart';

class HistoryTranslation extends StatelessWidget {
  const HistoryTranslation({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History Translation'),
      ),
      body: const Center(
        child: Text('History Translation Page Content'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.toNamed('/favorites');
        },
        child: const Icon(Icons.star),
      ),
      bottomNavigationBar: BottomNavigationBarWidget(
        selectedIndex: 1,
        onItemSelected: (index) {
          if (index == 1) return;
          if (index == 0) {
            Get.offNamed('/home');
          } else if (index == 2) Get.offNamed('/voice_synthesis');
        },
      ),
    );
  }
}
