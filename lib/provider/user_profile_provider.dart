import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../model/user_profile_model.dart';

class UserProfileProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  UserProfile? userProfile;
  bool isEditing = false;
  TextEditingController usernameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController currentPasswordController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();

  UserProfileProvider() {
    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        fetchUserProfile();
      } else {
        userProfile = null;
      }
      notifyListeners();
    });
  }

  User? get currentUser => _auth.currentUser;

  Future<void> fetchUserProfile() async {
    if (currentUser != null) {
      try {
        final snapshot =
            await _firestore.collection('users').doc(currentUser!.uid).get();
        if (snapshot.exists) {
          userProfile =
              UserProfile.fromMap(snapshot.data() as Map<String, dynamic>);
          usernameController.text = userProfile!.username;
          emailController.text = userProfile!.email;
          notifyListeners();
        }
      } catch (e) {
        if (kDebugMode) {
          print('Failed to fetch user data: $e');
        }
      }
    }
  }

  Future<void> signUp({required String email, required String password}) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      UserProfile newUserProfile =
          UserProfile(username: 'DefaultUsername', email: email);
      await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .set(newUserProfile.toMap());
      userProfile = newUserProfile;
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }

  Future<void> signIn({required String email, required String password}) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      fetchUserProfile();
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    userProfile = null;
    notifyListeners();
  }

  Future<void> passwordReset({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }

  Future<void> updateUserProfile() async {
    if (currentUser != null) {
      try {
        AuthCredential credential = EmailAuthProvider.credential(
            email: currentUser!.email!,
            password: currentPasswordController.text);
        await currentUser!.reauthenticateWithCredential(credential);
        if (newPasswordController.text.isNotEmpty &&
            newPasswordController.text != currentPasswordController.text) {
          await currentUser!.updatePassword(newPasswordController.text);
        }
        final newUserProfile = UserProfile(
            username: usernameController.text.trim(),
            email: emailController.text.trim());
        await _firestore
            .collection('users')
            .doc(currentUser!.uid)
            .update(newUserProfile.toMap());
        userProfile = newUserProfile;
        notifyListeners();
      } on FirebaseAuthException catch (e) {
        throw Exception(e.message);
      } catch (e) {
        throw Exception('An unexpected error occurred: $e');
      }
    }
  }

  void toggleEditing() {
    isEditing = !isEditing;
    notifyListeners();
  }

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    currentPasswordController.dispose();
    newPasswordController.dispose();
    super.dispose();
  }
}
