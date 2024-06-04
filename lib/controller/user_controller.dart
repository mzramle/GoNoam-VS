import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/user_crud_model.dart';

class UserController {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Creates user Data and refer the model data from user_crud_model.dart
  // Private method to create user data the underscore (_) is used to make the method private
  Future<void> _createUserData(UserModel userModel) async {
    final userCollection = firestore.collection('users');
    String id = userModel.id ?? userCollection.doc().id;

    final newUser = UserModel(
      username: userModel.username,
      address: userModel.address,
      age: userModel.age,
      id: id,
    ).toJson();

    await userCollection.doc(id).set(newUser);
  }

  // Read User Collection
  // Private method to read user data the underscore (_) is used to make the method private
  Stream<List<UserModel>> _readData() {
    // Create an instance of the user collection
    // To be used to read data from the firestore.
    final userCollection = FirebaseFirestore.instance.collection('users');

    // listens to the changes in the users collection
    // and returns a stream fof query snapshots. The Stream emits
    // a new snapshot every time there is a change in the collection
    return userCollection.snapshots().map((query) => query.docs
        .map(
          //Maps each query snapshots to a list of user object
          (e) => UserModel.fromSnapshot(
              e), // for each document snapshots 'e' in the query snapshots
        ) // it calls the users from the snapshot, calls  UserModel.fromSnapshot
        .toList()); // to convert the document snapshot into a user model object and
    // the list method convert the resulting user obejct into a list
    // and finally the method returns a Stream of list of user model object Stream<List<UserModel>>
    // This means that any widget listening to this stream will be updated with
    // the new list of user model objects whenever there is a change in the users collection
  }

  // Public method to expose the private _createUserData method
  Future<void> addUser(UserModel userModel) {
    return _createUserData(userModel);
  }

  // Public method to expose the private _readData method
  Stream<List<UserModel>> getUserDataStream() {
    return _readData();
  }
}
