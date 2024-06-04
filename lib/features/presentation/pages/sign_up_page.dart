import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gonoam_v1/features/presentation/pages/login_page.dart';
import 'package:gonoam_v1/features/presentation/widgets/form_container_widget.dart';
import 'package:gonoam_v1/helper/toast.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  bool _isSigningUp = false;
  bool _passwordsMatch = true;

  //final FirebaseAuthService _auth = FirebaseAuthService();

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _validatePasswords(String value) {
    setState(() {
      _passwordsMatch =
          _passwordController.text == _confirmPasswordController.text;
    });
  }

  void _signUp() async {
    String username = _usernameController.text.trim();
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    String confirmPassword = _confirmPasswordController.text.trim();

    if (password.isEmpty || confirmPassword.isEmpty) {
      showErrorToast('Password and Confirm Password fields cannot be empty');
      return;
    }

    if (!_passwordsMatch) {
      showErrorToast('Passwords do not match');
      return;
    }

    setState(() {
      _isSigningUp = true;
    });

    try {
      //User? user = await _auth.signUpWithEmailAndPassword(email, password);
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'username': username,
        'email': email,
      });

      if (mounted) {
        setState(() {
          _isSigningUp = false;
        });
        showSuccessToast("User is successfully created");
        Navigator.pushNamed(context, '/login');
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _isSigningUp = false;
      });
      showErrorToast("Some error happened: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Register",
                    style:
                        TextStyle(fontSize: 27, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                FormContainerWidget(
                  controller: _usernameController,
                  hintText: "Enter your username",
                  isPasswordField: false,
                  fieldName: "Name",
                ),
                const SizedBox(height: 10),
                FormContainerWidget(
                  controller: _emailController,
                  hintText: "Enter your email address",
                  isPasswordField: false,
                  fieldName: "Email Address",
                ),
                const SizedBox(height: 10),
                FormContainerWidget(
                  controller: _passwordController,
                  hintText: "Enter your password",
                  isPasswordField: true,
                  fieldName: "Password",
                ),
                const SizedBox(height: 10),
                FormContainerWidget(
                  controller: _confirmPasswordController,
                  hintText: "Re-enter your password",
                  isPasswordField: true,
                  fieldName: "Re-enter Password",
                  showError: !_passwordsMatch,
                  onChanged: _validatePasswords,
                ),
                const SizedBox(height: 30),
                GestureDetector(
                  onTap: _signUp,
                  child: Container(
                    width: double.infinity,
                    height: 45,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 255, 123, 0),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: _isSigningUp
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              "Sign Up",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already have an account?"),
                    const SizedBox(width: 5),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const LoginPage()),
                          (route) => false,
                        );
                      },
                      child: const Text(
                        "Login",
                        style: TextStyle(
                          color: Color.fromARGB(255, 255, 123, 0),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
