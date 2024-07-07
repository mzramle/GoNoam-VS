// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import '../widgets/form_container_widget.dart';

// class ForgotPasswordPage extends StatefulWidget {
//   const ForgotPasswordPage({super.key});

//   @override
//   State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
// }

// class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
//   final TextEditingController _emailController = TextEditingController();

//   @override
//   void dispose() {
//     _emailController.dispose();
//     super.dispose();
//   }

//   Future<void> passwordReset() async {
//     try {
//       await FirebaseAuth.instance
//           .sendPasswordResetEmail(email: _emailController.text.trim());
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Password reset email sent!')),
//       );
//     } on FirebaseAuthException catch (e) {
//       String errorMessage;
//       if (e.code == 'user-not-found') {
//         errorMessage = 'No user found for that email.';
//       } else if (e.code == 'invalid-email') {
//         errorMessage = 'The email address is not valid.';
//       } else {
//         errorMessage = 'An error occurred: ${e.code}';
//       }
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text(errorMessage)),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Forgot Password'),
//         backgroundColor: Colors.orangeAccent,
//         elevation: 0,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 25.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Text(
//                 'Enter your email and we will send you a password reset link.',
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                   fontSize: 18,
//                 )),
//             const SizedBox(
//               height: 15,
//             ),
//             FormContainerWidget(
//               controller: _emailController,
//               hintText: "Email",
//             ),
//             const SizedBox(
//               height: 15,
//             ),
//             ElevatedButton(
//                 style: ButtonStyle(
//                     foregroundColor:
//                         MaterialStateProperty.all<Color>(Colors.white),
//                     backgroundColor:
//                         MaterialStateProperty.all<Color>(Colors.red),
//                     shape: MaterialStateProperty.all<RoundedRectangleBorder>(
//                         RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(18.0),
//                             side: const BorderSide(color: Colors.red)))),
//                 onPressed: passwordReset,
//                 child: Text("Reset Password".toUpperCase(),
//                     style: const TextStyle(fontSize: 14))),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../widgets/forgot_password_keyp.dart';
import '../../widgets/form_container_widget.dart';
import '../../../../helper/toast.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> passwordReset() async {
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: _emailController.text.trim());
      showSuccessToast('Password reset email sent! Check your email.');
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      if (e.code == 'user-not-found') {
        errorMessage = 'No user found for that email.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'The email address is not valid.';
      } else if (e.code == 'invalid-credential') {
        errorMessage = 'The email address does not exist';
      } else {
        errorMessage = 'An error occurred: ${e.code}';
      }
      showErrorToast(errorMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Forgot Password'),
        backgroundColor: Colors.orangeAccent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const ForgotPasswordKeyp(),
            const Text(
                'Enter your email and we will send you a password reset link.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                )),
            const SizedBox(
              height: 15,
            ),
            FormContainerWidget(
              controller: _emailController,
              hintText: "Email",
            ),
            const SizedBox(
              height: 15,
            ),
            ElevatedButton(
                style: ButtonStyle(
                    foregroundColor:
                        WidgetStateProperty.all<Color>(Colors.white),
                    backgroundColor: WidgetStateProperty.all<Color>(Colors.red),
                    shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18.0),
                            side: const BorderSide(color: Colors.red)))),
                onPressed: passwordReset,
                child: Text("Reset Password".toUpperCase(),
                    style: const TextStyle(fontSize: 14))),
          ],
        ),
      ),
    );
  }
}
