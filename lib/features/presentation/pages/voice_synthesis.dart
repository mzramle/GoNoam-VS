// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// import '../widgets/app_bottom_navigation_bar.dart';

// class VoiceSynthesis extends StatelessWidget {
//   const VoiceSynthesis({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Voice Synthesis'),
//       ),
//       body: Center(
//         child: Text('Voice Synthesis Page Content'),
//       ),
//       bottomNavigationBar: BottomNavigationBarWidget(
//         selectedIndex: 2,
//         onItemSelected: (index) {
//           if (index == 2) return;
//           if (index == 0)
//             Get.offNamed('/home');
//           else if (index == 1) Get.offNamed('/history_translation');
//         },
//       ),
//     );
//   }
// }

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VoiceSynthesis extends StatelessWidget {
  const VoiceSynthesis({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voice Synthesis'),
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
        child: Text('Voice Synthesis Page Content'),
      ),
    );
  }
}
