// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:gonoam_v1/controller/user_profile_controller.dart';
// import 'package:gonoam_v1/features/presentation/widgets/form_container_widget.dart';
// import 'package:gonoam_v1/helper/toast.dart';
// import 'package:gonoam_v1/model/user_profile_model.dart';

// class UserProfilePage extends StatefulWidget {
//   final String userId;

//   const UserProfilePage({super.key, required this.userId});

//   @override
//   State<UserProfilePage> createState() => _UserProfilePageState();
// }

// class _UserProfilePageState extends State<UserProfilePage> {
//   bool _isEditing = false;
//   final _usernameController = TextEditingController();
//   final _emailController = TextEditingController();
//   final _currentPasswordController = TextEditingController();
//   final _newPasswordController = TextEditingController();

//   final UserProfileController _userProfileController = UserProfileController();
//   late UserProfileModel _userProfile;

//   @override
//   void initState() {
//     super.initState();
//     _loadUserProfile();
//   }

//   void _loadUserProfile() async {
//     _userProfile = await _userProfileController.getUserProfile(widget.userId);
//     setState(() {
//       _usernameController.text = _userProfile.username!;
//       _emailController.text = _userProfile.email!;
//     });
//   }

//   @override
//   void dispose() {
//     _usernameController.dispose();
//     _emailController.dispose();
//     _currentPasswordController.dispose();
//     _newPasswordController.dispose();
//     super.dispose();
//   }

//   void _updateUserProfile() async {
//     User? user = FirebaseAuth.instance.currentUser;
//     if (user != null) {
//       String username = _usernameController.text.trim();
//       String email = _emailController.text.trim();
//       String currentPassword = _currentPasswordController.text.trim();
//       String newPassword = _newPasswordController.text.trim();

//       if (currentPassword.isEmpty || newPassword.isEmpty) {
//         showErrorToast('Current password and new password cannot be empty');
//         return;
//       }

//       try {
//         await _userProfileController.updateUserProfile(
//           widget.userId,
//           username,
//           email,
//           currentPassword,
//           newPassword,
//         );
//         showSuccessToast('User profile updated successfully');
//       } catch (e) {
//         showErrorToast(e.toString());
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('User Profile'),
//         actions: [
//           IconButton(
//             icon: Icon(_isEditing ? Icons.done : Icons.edit),
//             onPressed: () {
//               setState(() {
//                 _isEditing = !_isEditing;
//               });
//             },
//           )
//         ],
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             FormContainerWidget(
//               controller: _usernameController,
//               hintText: "Username",
//               isPasswordField: false,
//               enabled: _isEditing,
//             ),
//             const SizedBox(height: 10),
//             FormContainerWidget(
//               controller: _emailController,
//               hintText: "Email",
//               isPasswordField: false,
//               enabled: _isEditing,
//             ),
//             const SizedBox(height: 10),
//             if (_isEditing) ...[
//               FormContainerWidget(
//                 controller: _currentPasswordController,
//                 hintText: "Current Password",
//                 isPasswordField: true,
//                 enabled: true,
//               ),
//               const SizedBox(height: 10),
//               FormContainerWidget(
//                 controller: _newPasswordController,
//                 hintText: "New Password",
//                 isPasswordField: true,
//                 enabled: true,
//               ),
//               const SizedBox(height: 20),
//             ],
//             ElevatedButton(
//               onPressed: _isEditing ? _updateUserProfile : null,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFFFF6600),
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//               ),
//               child: const Text(
//                 'Update',
//                 style: TextStyle(fontSize: 18, color: Colors.white),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gonoam_v1/features/presentation/widgets/form_container_widget.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gonoam_v1/features/presentation/widgets/form_container_widget.dart';
import 'package:gonoam_v1/helper/toast.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({Key? key}) : super(key: key);

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  bool _isEditing = false;
  late final TextEditingController _usernameController;
  late final TextEditingController _emailController;
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();

  final currentUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    // Initialize controller values if not editing
    _usernameController = TextEditingController(text: '');
    _emailController = TextEditingController(text: '');

    // Fetch user data and update controller values if not editing
    if (!_isEditing) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser?.uid)
          .get()
          .then((snapshot) {
        if (snapshot.exists) {
          final userData = snapshot.data() as Map<String, dynamic>;
          setState(() {
            _usernameController.text = userData['username'];
            _emailController.text = userData['email'];
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  Future<void> updateUserProfile() async {
    try {
      // Validate current password
      final credential = EmailAuthProvider.credential(
        email: currentUser!.email!,
        password: _currentPasswordController.text,
      );
      await currentUser?.reauthenticateWithCredential(credential);

      // Update user profile
      final user = FirebaseAuth.instance.currentUser;
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .update({
        'username': _usernameController.text.trim(),
        'email': _emailController.text.trim(),
      });

      showSuccessToast('User profile updated successfully');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-credential') {
        showErrorToast('Invalid current password');
      } else {
        showErrorToast('Failed to update user profile');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
        actions: [
          Row(
            children: [
              Text(
                _isEditing ? 'Done' : 'Edit',
                style: const TextStyle(fontSize: 16),
              ),
              IconButton(
                icon: Icon(_isEditing ? Icons.done : Icons.edit),
                onPressed: () {
                  setState(() {
                    _isEditing = !_isEditing;
                  });
                },
              ),
            ],
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser?.uid) // Use uid instead of email
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('An error occurred: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('No data available'));
          }

          final userData = snapshot.data!.data() as Map<String, dynamic>;

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              FormContainerWidget(
                controller: _usernameController,
                hintText: _isEditing ? "Username" : userData["username"],
                isPasswordField: false,
                enabled: _isEditing,
                fieldName: "Username",
              ),
              const SizedBox(height: 10),
              FormContainerWidget(
                controller: _emailController,
                hintText: _isEditing ? "Email" : userData["email"],
                isPasswordField: false,
                enabled: _isEditing,
                fieldName: "Email",
              ),
              const SizedBox(height: 20),
              if (_isEditing) ...[
                FormContainerWidget(
                  controller: _currentPasswordController,
                  hintText: "Current Password",
                  isPasswordField: true,
                  enabled: true,
                  fieldName: "Current Password",
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter your current password';
                    }
                    // Add validation for current password
                    // Example: Check if the current password matches with the user's actual password
                    // If not, return an error message
                    // If it matches, return null
                    // For simplicity, we're not implementing the actual validation logic here
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                FormContainerWidget(
                  controller: _newPasswordController,
                  hintText: "New Password",
                  isPasswordField: true,
                  enabled: true,
                  fieldName: "New Password",
                ),
                const SizedBox(height: 20),
              ],
              ElevatedButton(
                onPressed: _isEditing ? updateUserProfile : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      _isEditing ? const Color(0xFFFF6600) : Colors.grey,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Update',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
