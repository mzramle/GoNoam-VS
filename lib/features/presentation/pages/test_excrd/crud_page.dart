// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:gonoam_v1/controller/user_controller.dart';
// import 'package:gonoam_v1/helper/toast.dart';

// import '../../../model/user_crud_model.dart';
// import '../widgets/form_container_widget.dart';

// class CRUDPage extends StatefulWidget {
//   const CRUDPage({super.key});

//   @override
//   State<CRUDPage> createState() => _CRUDPageState();
// }

// class _CRUDPageState extends State<CRUDPage> {
//   final _usernameController = TextEditingController();
//   final _addressController = TextEditingController();
//   final _ageController = TextEditingController();

//   final UserController _userTestCRUDController = UserController();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('CRUD Page',
//             style: TextStyle(color: Colors.white, fontSize: 27)),
//         backgroundColor: const Color.fromARGB(255, 243, 173, 33),
//       ),
//       body: Center(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 25.0),
//           child: Column(
//             mainAxisSize: MainAxisSize.min, // Center the column vertically
//             children: [
//               const Text(
//                 'CRUD',
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                   fontSize: 18,
//                 ),
//               ),
//               FormContainerWidget(
//                 controller: _usernameController,
//                 hintText: "Username",
//               ),
//               FormContainerWidget(
//                 controller: _addressController,
//                 hintText: "Address",
//               ),
//               FormContainerWidget(
//                 controller: _ageController,
//                 hintText: "Age",
//               ),
//               const SizedBox(
//                 height: 15,
//               ),
//               ElevatedButton(
//                 onPressed: () async {
//                   try {
//                     final firestore = FirebaseFirestore.instance;
//                     await firestore.collection("users").doc("1").set({
//                       "name": "John Doe",
//                       "age": 30,
//                       "email": "ade@gmail.com",
//                     });
//                     showSuccessToast('User created successfully');
//                   } on Exception catch (e) {
//                     showErrorToast(e.toString());
//                   }
//                 },
//                 style: ButtonStyle(
//                   foregroundColor:
//                       MaterialStateProperty.all<Color>(Colors.white),
//                   backgroundColor: MaterialStateProperty.all<Color>(
//                       const Color.fromARGB(255, 22, 62, 220)),
//                   shape: MaterialStateProperty.all<RoundedRectangleBorder>(
//                     RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(18.0),
//                       side: const BorderSide(color: Colors.red),
//                     ),
//                   ),
//                 ),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Flexible(
//                       child: Text(
//                         "Basic Create User Without User Model (Not Dynamic)"
//                             .toUpperCase(),
//                         style: const TextStyle(fontSize: 14),
//                         softWrap: true,
//                         textAlign: TextAlign.center,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               ElevatedButton(
//                 onPressed: () async {
//                   try {
//                     await _userTestCRUDController.addUser(UserModel(
//                       username: _usernameController.text,
//                       address: _addressController.text,
//                       age: int.parse(_ageController.text),
//                       id: null,
//                     ));
//                     showSuccessToast('User created successfully');
//                   } catch (e) {
//                     showErrorToast(e.toString());
//                   }
//                 },
//                 style: ButtonStyle(
//                   foregroundColor:
//                       MaterialStateProperty.all<Color>(Colors.white),
//                   backgroundColor: MaterialStateProperty.all<Color>(
//                       const Color.fromARGB(255, 187, 244, 54)),
//                   shape: MaterialStateProperty.all<RoundedRectangleBorder>(
//                     RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(18.0),
//                       side: const BorderSide(
//                           color: Color.fromARGB(255, 54, 244, 139)),
//                     ),
//                   ),
//                 ),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Flexible(
//                       child: Text(
//                         "Create User With User Model (Dynamic)".toUpperCase(),
//                         style:
//                             const TextStyle(fontSize: 14, color: Colors.black),
//                         softWrap: true,
//                         textAlign: TextAlign.center,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(
//                 height: 15,
//               ),
//               const Text("Read User Database",
//                   style: TextStyle(
//                     fontWeight: FontWeight.bold,
//                   )),
//               StreamBuilder<List<UserModel>>(
//                 stream: _userTestCRUDController.getUserDataStream(),
//                 builder: (context, snapshot) {
//                   if (snapshot.connectionState == ConnectionState.waiting) {
//                     return const Center(child: CircularProgressIndicator());
//                   }
//                   if (snapshot.data!.isEmpty) {
//                     return const Center(child: Text("No Data found"));
//                   }
//                   final users =
//                       snapshot.data; // this users reference is used below for
//                   //getting the users data from firebase
//                   return Row(
//                     children: users!.map(
//                       (user) {
//                         return ListTile(
//                           leading: GestureDetector(
//                             child: const Icon(Icons.delete),
//                           ),
//                           trailing: GestureDetector(
//                             child: const Icon(Icons.update),
//                           ),
//                           title: Text(user.username!),
//                           subtitle: Text(user.address!),
//                         );
//                       },
//                     ).toList(),
//                   );
//                 },
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gonoam_v1/controller/user_crud_controller.dart';
import 'package:gonoam_v1/helper/toast.dart';

import '../../../../model/user_crud_model.dart';
import '../../widgets/form_container_widget.dart';
import 'user_crud_update_page.dart';

class CRUDPage extends StatefulWidget {
  const CRUDPage({super.key});

  @override
  State<CRUDPage> createState() => _CRUDPageState();
}

class _CRUDPageState extends State<CRUDPage> {
  final _usernameController = TextEditingController();
  final _addressController = TextEditingController();
  final _ageController = TextEditingController();

  final UserCrudTestController _userTestCRUDController =
      UserCrudTestController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CRUD Page',
            style: TextStyle(color: Colors.white, fontSize: 27)),
        backgroundColor: const Color.fromARGB(255, 243, 173, 33),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Column(
              mainAxisSize: MainAxisSize.min, // Center the column vertically
              children: [
                const Text(
                  'Create User',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
                FormContainerWidget(
                  controller: _usernameController,
                  hintText: "Username",
                  fieldName: "Username",
                ),
                FormContainerWidget(
                  controller: _addressController,
                  hintText: "Address",
                  fieldName: "Address",
                ),
                FormContainerWidget(
                  controller: _ageController,
                  hintText: "Age",
                  fieldName: "Age",
                ),
                const SizedBox(
                  height: 15,
                ),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      final firestore = FirebaseFirestore.instance;
                      await firestore
                          .collection("users_test_crud")
                          .doc("1")
                          .set({
                        "name": "John Doe",
                        "age": 30,
                        "email": "ade@gmail.com",
                      });
                      showSuccessToast('User created successfully');
                    } on Exception catch (e) {
                      showErrorToast(e.toString());
                    }
                  },
                  style: ButtonStyle(
                    foregroundColor:
                        MaterialStateProperty.all<Color>(Colors.white),
                    backgroundColor: MaterialStateProperty.all<Color>(
                        const Color.fromARGB(255, 22, 62, 220)),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                        side: const BorderSide(color: Colors.red),
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          "Basic Create User Without User Model (Not Dynamic)"
                              .toUpperCase(),
                          style: const TextStyle(fontSize: 14),
                          softWrap: true,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      await _userTestCRUDController.addUser(UserTestCrudModel(
                        username: _usernameController.text,
                        address: _addressController.text,
                        age: int.parse(_ageController.text),
                        id: null,
                      ));
                      showSuccessToast('User created successfully');
                    } catch (e) {
                      showErrorToast(e.toString());
                    }
                  },
                  style: ButtonStyle(
                    foregroundColor:
                        MaterialStateProperty.all<Color>(Colors.white),
                    backgroundColor: MaterialStateProperty.all<Color>(
                        const Color.fromARGB(255, 187, 244, 54)),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                        side: const BorderSide(
                            color: Color.fromARGB(255, 54, 244, 139)),
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          "Create User With User Model (Dynamic)".toUpperCase(),
                          style: const TextStyle(
                              fontSize: 14, color: Colors.black),
                          softWrap: true,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                const Text("Read User Database",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    )),
                StreamBuilder<List<UserTestCrudModel>>(
                  //StreamBuilder is a widget that listens to a stream and rebuilds itself when the stream emits an event.
                  //Listens to a change in UserModel state
                  stream: _userTestCRUDController
                      .getUserDataStream(), // Stream takes list of data UserController object, _userTestCRUDController to get the getUserDataStream() for read.
                  builder: (context, snapshot) {
                    // Snapshot takes latest interaction with asyncschronous state
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return const Center(child: Text("An error occurred"));
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text("No Data found"));
                    }
                    final users = snapshot.data;
                    return ListView(
                      shrinkWrap: true,
                      children: users!.map(
                        (user) {
                          return ListTile(
                            leading: GestureDetector(
                              onTap: () async {
                                if (user.id != null) {
                                  try {
                                    await _userTestCRUDController
                                        .deleteUser(user.id!);
                                    showSuccessToast(
                                        'User deleted successfully');
                                  } catch (e) {
                                    showErrorToast('Failed to delete user: $e');
                                  }
                                } else {
                                  showErrorToast('User ID is null');
                                }
                              },
                              child: const Icon(Icons.delete),
                            ),
                            trailing: GestureDetector(
                              // for immediate testing to see if users data will be updated
                              // Commented because only the update page will be used for updating user data
                              // based on user inputs.
                              // onTap: () {
                              //   _userTestCRUDController.updateUser(
                              //     UserModel(
                              //       username: _usernameController.text,
                              //       address: _addressController.text,
                              //       age: int.parse(_ageController.text),
                              //       id: user.id,
                              //     ),
                              //   );
                              // },
                              onTap: () {
                                if (user.id != null) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          UpdateUserPage(userId: user.id!),
                                    ),
                                  );
                                } else {
                                  showErrorToast('User ID is null');
                                }
                              },
                              child: const Icon(Icons.update),
                            ),
                            title: Text(user.username!),
                            subtitle: Text(user.address!),
                          );
                        },
                      ).toList(), // Used toList() because the widget type is ListTile convert it into a list
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
