import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gonoam_v1/model/user_profile_model.dart';
import 'package:gonoam_v1/helper/toast.dart';

class UserProfileController {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<UserProfileModel?> getUserProfile(String userId) async {
    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    if (userDoc.exists) {
      final userData = userDoc.data();
      return UserProfileModel(
        username: userData?['username'],
        email: userData?['email'],
      );
    } else {
      return null;
    }
  }

  Future<void> updateUserProfile(
    String uid,
    String username,
    String email,
    String currentPassword,
    String newPassword,
  ) async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // Reauthenticate user
      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      try {
        await user.reauthenticateWithCredential(credential);

        // Update email
        await user.verifyBeforeUpdateEmail(email);

        // Update password
        await user.updatePassword(newPassword);

        // Update Firestore
        await firestore.collection('users').doc(uid).update({
          'username': username,
          'email': email,
        });
      } catch (e) {
        throw Exception("Failed to update user profile: $e");
      }
    } else {
      throw Exception("User not logged in");
    }
  }
}
