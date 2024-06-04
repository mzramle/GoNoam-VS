import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfileModel {
  String? username;
  String? email;

  UserProfileModel({this.username, this.email});

  factory UserProfileModel.fromSnapshot(DocumentSnapshot snapshot) {
    return UserProfileModel(
      username: snapshot['username'],
      email: snapshot['email'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
    };
  }
}
