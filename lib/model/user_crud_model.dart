import 'package:cloud_firestore/cloud_firestore.dart';

class UserTestCrudModel {
  final String? username;
  final String? address;
  final int? age;
  final String? id;

  UserTestCrudModel(
      {required this.username,
      required this.address,
      required this.age,
      required this.id});

// Static method takes document snapshot as a parameter andd create a user
  // instance from the snapshot. It extraxts values from the snapshot using
  // the key values (username, address, age and id) and use them
  // to initialize new user object
  static UserTestCrudModel fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    return UserTestCrudModel(
      username: snapshot['username'],
      address: snapshot['address'],
      age: snapshot['age'],
      id: snapshot['id'],
    );
  }

// This method convert an instance of the user class to a Json like Map
// This method returns a Map with keys (username, address, age and id)
  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'address': address,
      'age': age,
      'id': id,
    };
  }
}
