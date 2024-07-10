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
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gonoam_v1/features/presentation/widgets/form_container_widget.dart';
import 'package:gonoam_v1/helper/toast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  bool _isEditing = false;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();

  final currentUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getUserData();
    });
  }

  Future<void> getUserData() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser?.uid)
          .get();
      if (snapshot.exists) {
        final userData = snapshot.data() as Map<String, dynamic>;
        setState(() {
          _usernameController.text = userData['username'] ?? '';
          _emailController.text = userData['email'] ?? '';
        });
      }
    } catch (e) {
      showErrorToast('Failed to fetch user data: $e');
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
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        showErrorToast('No user currently signed in');
        return;
      }

      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: _currentPasswordController.text,
      );

      await FirebaseAuth.instance.currentUser!
          .reauthenticateWithCredential(credential);

      if (_newPasswordController.text.isNotEmpty &&
          _newPasswordController.text != _currentPasswordController.text) {
        showErrorToast('New password and re-entered new password do not match');
        return;
      }

      if (_emailController.text.trim() != user.email) {
        await user.verifyBeforeUpdateEmail(_emailController.text.trim());
        await user.sendEmailVerification();
      }

      // Update password only if new password is entered
      if (_newPasswordController.text.isNotEmpty) {
        await user.updatePassword(_newPasswordController.text);
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'username': _usernameController.text.trim(),
        'email': _emailController.text.trim(),
      });

      showSuccessToast('User profile updated successfully');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        showErrorToast('Invalid current password');
      } else {
        showErrorToast('Failed to update user profile: ${e.message}');
        if (kDebugMode) {
          print("Error in updattuing the dodfn : $e");
        }
      }
    } catch (e) {
      showErrorToast('An unexpected error occurred: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Profile',
            style:
                GoogleFonts.robotoCondensed(fontSize: 30, color: Colors.white)),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          Row(
            children: [
              Text(
                _isEditing ? 'Done' : 'Edit',
                style: const TextStyle(fontSize: 16, color: Colors.white),
              ),
              IconButton(
                icon: Icon(_isEditing
                    ? Icons.done_outline_rounded
                    : Icons.edit_document),
                style: ButtonStyle(
                  foregroundColor: WidgetStateProperty.all<Color>(Colors.white),
                  iconSize: WidgetStateProperty.all<double>(25),
                ),
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
            .doc(currentUser?.uid)
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
                hintText: _isEditing
                    ? userData["username"] ?? "Username"
                    : userData["username"],
                isPasswordField: false,
                enabled: _isEditing,
                fieldName: "Username",
              ),
              const SizedBox(height: 10),
              FormContainerWidget(
                controller: _emailController,
                hintText: _isEditing
                    ? userData["email"] ?? "Email"
                    : userData["email"],
                isPasswordField: false,
                enabled: _isEditing,
                fieldName: "Email",
              ),
              const SizedBox(height: 20),
              if (_isEditing) ...[
                FormContainerWidget(
                  controller: _currentPasswordController,
                  hintText: "New Password",
                  isPasswordField: true,
                  enabled: true,
                  fieldName: "New Password",
                ),
                const SizedBox(height: 10),
                FormContainerWidget(
                  controller: _newPasswordController,
                  hintText: "Re-enter again New Password",
                  isPasswordField: true,
                  enabled: true,
                  fieldName: "Re-enter again New Password",
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
