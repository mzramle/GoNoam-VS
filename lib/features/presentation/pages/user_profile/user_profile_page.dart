import 'package:flutter/material.dart';
import 'package:gonoam_v1/provider/user_profile_provider.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../widgets/form_container_widget.dart';

class UserProfilePage extends StatelessWidget {
  const UserProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => UserProfileProvider()..fetchUserProfile(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'User Profile',
            style:
                GoogleFonts.robotoCondensed(fontSize: 30, color: Colors.white),
          ),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          actions: [
            Consumer<UserProfileProvider>(
              builder: (context, userProfileProvC, _) {
                return Row(
                  children: [
                    Text(
                      userProfileProvC.isEditing ? 'Done' : 'Edit',
                      style: const TextStyle(fontSize: 16, color: Colors.white),
                    ),
                    IconButton(
                      icon: Icon(userProfileProvC.isEditing
                          ? Icons.done_outline_rounded
                          : Icons.edit_document),
                      onPressed: userProfileProvC.toggleEditing,
                    ),
                  ],
                );
              },
            ),
          ],
        ),
        body: Consumer<UserProfileProvider>(
          builder: (context, userProfileProvC, _) {
            if (userProfileProvC.userProfile == null) {
              return const Center(child: CircularProgressIndicator());
            }

            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                FormContainerWidget(
                  controller: userProfileProvC.usernameController,
                  hintText: userProfileProvC.isEditing
                      ? userProfileProvC.userProfile!.username
                      : userProfileProvC.userProfile!.username,
                  isPasswordField: false,
                  enabled: userProfileProvC.isEditing,
                  fieldName: "Username",
                ),
                const SizedBox(height: 10),
                FormContainerWidget(
                  controller: userProfileProvC.emailController,
                  hintText: userProfileProvC.isEditing
                      ? userProfileProvC.userProfile!.email
                      : userProfileProvC.userProfile!.email,
                  isPasswordField: false,
                  enabled: userProfileProvC.isEditing,
                  fieldName: "Email",
                ),
                const SizedBox(height: 20),
                if (userProfileProvC.isEditing) ...[
                  FormContainerWidget(
                    controller: userProfileProvC.currentPasswordController,
                    hintText: "Current Password",
                    isPasswordField: true,
                    enabled: true,
                    fieldName: "Current Password",
                  ),
                  const SizedBox(height: 10),
                  FormContainerWidget(
                    controller: userProfileProvC.newPasswordController,
                    hintText: "New Password",
                    isPasswordField: true,
                    enabled: true,
                    fieldName: "New Password",
                  ),
                  const SizedBox(height: 20),
                ],
                ElevatedButton(
                  onPressed: userProfileProvC.isEditing
                      ? userProfileProvC.updateUserProfile
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: userProfileProvC.isEditing
                        ? const Color(0xFFFF6600)
                        : Colors.grey,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 50, vertical: 15),
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
      ),
    );
  }
}
