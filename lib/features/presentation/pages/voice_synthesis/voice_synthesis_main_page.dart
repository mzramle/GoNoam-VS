// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// import '../widgets/app_bottom_navigation_bar.dart';

// class VoiceSynthesisMainPage extends StatelessWidget {
//   const VoiceSynthesisMainPage({Key? key}) : super(key: key);

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

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:gonoam_v1/features/presentation/pages/voice_synthesis/create_voice_sample_page.dart';

import '../../widgets/orange_button.dart';

class VoiceSynthesisMainPage extends StatelessWidget {
  const VoiceSynthesisMainPage({Key? key}) : super(key: key);

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    Get.offAllNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voice Synthesis',
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
        automaticallyImplyLeading: false,
        actions: [
          PopupMenuButton<String>(
            onSelected: (String result) {
              if (result == 'user_profile') {
                Get.toNamed('/user_profile');
              } else if (result == 'logout') {
                _signOut();
              } else if (result == 'settings') {
                Get.toNamed('/settings');
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'user_profile',
                child: Text('User Profile'),
              ),
              const PopupMenuItem<String>(
                value: 'logout',
                child: Text('Log Out'),
              ),
              const PopupMenuItem<String>(
                value: 'settings',
                child: Text('Settings'),
              ),
            ],
            icon: const Icon(Icons.person, color: Colors.white),
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: OrangeButton(
                  text: 'Adjust Voice',
                  onPressed: () {},
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: OrangeButton(
                  text: 'Create Voice Sample',
                  onPressed: () {
                    Get.to(const CreateVoiceSamplePage());
                  },
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: OrangeButton(
                  text: 'Trained Voice Library',
                  onPressed: () {},
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: OrangeButton(
                  text: 'Delete Voices',
                  onPressed: () {},
                ),
              ),
              const SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[200],
                    padding: const EdgeInsets.symmetric(
                        horizontal: 50, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'English',
                    style: TextStyle(fontSize: 18, color: Colors.black),
                  ),
                ),
              ),
              const SizedBox(height: 50),
              Container(
                alignment: Alignment.bottomLeft,
                margin: const EdgeInsets.only(left: 50.0),
                child: const Text('Current Voice Model',
                    style: TextStyle(fontSize: 18, color: Colors.black),
                    textAlign: TextAlign.start),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 30.0),
                child: const Divider(color: Colors.black, thickness: 2.0),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff003366),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100),
                          ),
                          minimumSize: const Size(30, 70)),
                      child: const Icon(
                        Icons.mic,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff003366),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 50, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Current Voice Model',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
