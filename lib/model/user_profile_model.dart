class UserProfile {
  final String username;
  final String email;

  UserProfile({required this.username, required this.email});

  factory UserProfile.fromMap(Map<String, dynamic> data) {
    return UserProfile(
      username: data['username'] ?? '',
      email: data['email'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'email': email,
    };
  }
}
































// =====================================================================================================

// import 'package:cloud_firestore/cloud_firestore.dart';

// class UserProfileModel {
//   String? username;
//   String? email;

//   UserProfileModel({this.username, this.email});

//   factory UserProfileModel.fromSnapshot(DocumentSnapshot snapshot) {
//     return UserProfileModel(
//       username: snapshot['username'],
//       email: snapshot['email'],
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'username': username,
//       'email': email,
//     };
//   }
// }
