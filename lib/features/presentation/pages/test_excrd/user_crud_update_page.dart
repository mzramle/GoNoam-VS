import 'package:flutter/material.dart';
import 'package:gonoam_v1/controller/user_crud_controller.dart';
import 'package:gonoam_v1/helper/toast.dart';
import 'package:gonoam_v1/model/user_crud_model.dart';
import '../../widgets/form_container_widget.dart';

class UpdateUserPage extends StatefulWidget {
  final String userId;

  const UpdateUserPage({super.key, required this.userId});

  @override
  State<UpdateUserPage> createState() => _UpdateUserPageState();
}

class _UpdateUserPageState extends State<UpdateUserPage> {
  final _usernameController = TextEditingController();
  final _addressController = TextEditingController();
  final _ageController = TextEditingController();

  final UserCrudTestController _userCRUDTestController =
      UserCrudTestController();

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      final user = await _userCRUDTestController.getUserById(widget.userId);
      if (user != null) {
        _usernameController.text = user.username!;
        _addressController.text = user.address!;
        _ageController.text = user.age.toString();
      }
    } catch (e) {
      showErrorToast('Failed to load user data: $e');
    }
  }

  Future<void> _updateUser() async {
    try {
      await _userCRUDTestController.updateUser(UserTestCrudModel(
        id: widget.userId,
        username: _usernameController.text,
        address: _addressController.text,
        age: int.parse(_ageController.text),
      ));
      showSuccessToast('User updated successfully');
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      showErrorToast('Failed to update user: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update User',
            style: TextStyle(color: Colors.white, fontSize: 27)),
        backgroundColor: const Color.fromARGB(255, 243, 173, 33),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Update User',
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
                  inputType: TextInputType.number,
                  fieldName: "Age",
                ),
                const SizedBox(
                  height: 15,
                ),
                ElevatedButton(
                  onPressed: _updateUser,
                  style: ButtonStyle(
                    foregroundColor:
                        WidgetStateProperty.all<Color>(Colors.white),
                    backgroundColor: WidgetStateProperty.all<Color>(
                        const Color.fromARGB(255, 22, 62, 220)),
                    shape: WidgetStateProperty.all<RoundedRectangleBorder>(
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
                          "Update User".toUpperCase(),
                          style: const TextStyle(fontSize: 14),
                          softWrap: true,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
