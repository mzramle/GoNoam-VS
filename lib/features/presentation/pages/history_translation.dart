// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// import '../widgets/app_bottom_navigation_bar.dart';

// class HistoryTranslation extends StatelessWidget {
//   const HistoryTranslation({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('History Translation'),
//       ),
//       body: const Center(
//         child: Text('History Translation Page Content'),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           Get.toNamed('/favorites');
//         },
//         child: const Icon(Icons.star),
//       ),
//       bottomNavigationBar: BottomNavigationBarWidget(
//         selectedIndex: 1,
//         onItemSelected: (index) {
//           if (index == 1) return;
//           if (index == 0) {
//             Get.offNamed('/home');
//           } else if (index == 2) Get.offNamed('/voice_synthesis');
//         },
//       ),
//     );
//   }
// }

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HistoryTranslation extends StatelessWidget {
  const HistoryTranslation({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History Translation'),
        actions: [
          PopupMenuButton<String>(
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'update_profile',
                child: Text('Update Profile'),
              ),
              const PopupMenuItem<String>(
                value: 'log_out',
                child: Text('Log Out'),
              ),
            ],
            onSelected: (String value) {
              if (value == 'update_profile') {
                // Handle update profile action
              } else if (value == 'log_out') {
                // Handle log out action
                FirebaseAuth.instance.signOut();
              }
            },
          ),
        ],
      ),
      body: const Center(
        child: Text('History Translation Page Content'),
      ),
    );
  }
}
