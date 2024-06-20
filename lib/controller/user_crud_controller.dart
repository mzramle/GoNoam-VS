import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/user_crud_model.dart';

class UserCrudTestController {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Creates user Data and refer the model data from user_crud_model.dart
  // Private method to create user data the underscore (_) is used to make the method private
  Future<void> _createUserData(UserTestCrudModel userCrudModel) async {
    final userCollection = firestore.collection('users_test_crud');
    String id = userCrudModel.id ?? userCollection.doc().id;

    final newUser = UserTestCrudModel(
      username: userCrudModel.username,
      address: userCrudModel.address,
      age: userCrudModel.age,
      id: id,
    ).toJson();

    await userCollection.doc(id).set(newUser);
  }

  // Public method to expose the private _createUserData method
  Future<void> addUser(UserTestCrudModel userCrudModel) {
    return _createUserData(userCrudModel);
  }

  // Read User Collection
  // Private method to read user data the underscore (_) is used to make the method private
  Stream<List<UserTestCrudModel>> _readData() {
    // Create an instance of the user collection
    // To be used to read data from the firestore.
    final userCollection =
        FirebaseFirestore.instance.collection('users_test_crud');

    // listens to the changes in the users_test_crud collection
    // and returns a stream fof query snapshots. The Stream emits
    // a new snapshot every time there is a change in the collection
    return userCollection.snapshots().map((query) => query.docs
        .map(
          //Maps each query snapshots to a list of user object
          (e) => UserTestCrudModel.fromSnapshot(
              e), // for each document snapshots 'e' in the query snapshots
        ) // it calls the users_test_crud from the snapshot, calls  UserCrudModel.fromSnapshot
        .toList()); // to convert the document snapshot into a user model object and
    // the list method convert the resulting user obejct into a list
    // and finally the method returns a Stream of list of user model object Stream<List<UserCrudModel>>
    // This means that any widget listening to this stream will be updated with
    // the new list of user model objects whenever there is a change in the users_test_crud collection
  }

  // Public method to expose the private _readData method
  Stream<List<UserTestCrudModel>> getUserDataStream() {
    return _readData();
  }

  Future<void> _updateUserData(UserTestCrudModel userCrudModel) async {
    final userCollection = firestore.collection('users_test_crud');
    //await userCollection.doc(userCrudModel.id).update(userCrudModel.toJson());

    final newUser = UserTestCrudModel(
      username: userCrudModel.username,
      address: userCrudModel.address,
      age: userCrudModel.age,
      id: userCrudModel.id,
    ).toJson();

    await userCollection.doc(userCrudModel.id).update(newUser);
  }

  Future<void> updateUser(UserTestCrudModel userCrudModel) {
    return _updateUserData(userCrudModel);
  }

  Future<UserTestCrudModel?> getUserById(String id) async {
    final doc = await firestore.collection('users_test_crud').doc(id).get();
    if (doc.exists) {
      return UserTestCrudModel.fromSnapshot(doc);
    }
    return null;
  }

  // _ private Delete method
  Future<void> _deleteUserData(String userId) async {
    final userCollection = firestore.collection('users_test_crud');
    await userCollection.doc(userId).delete();
  }

// call the public method to access the private delete method. Ensuring encapsulation
  Future<void> deleteUser(String userId) {
    return _deleteUserData(userId);
  }
}
