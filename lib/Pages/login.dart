import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'register.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();

  String? errorMessage = '';
  bool isPasswordVisible = false;
  bool rememberMe = false;

  Future<void> signInWithEmailAndPassword() async {
  try {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: _controllerEmail.text.trim(),
      password: _controllerPassword.text.trim(),
    );
  } on FirebaseAuthException catch (e) {
    setState(() {
      errorMessage = e.message;
      _errorMessage();
    });
  }
}

  void _errorMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          errorMessage == '' ? '' : 'Humm? $errorMessage',
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildTextField(
      {required String hint,
      required TextEditingController controller,
      bool isPassword = false}) {
    return TextField(
      controller: controller,
      obscureText: isPassword && !isPasswordVisible,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () {
                  setState(() => isPasswordVisible = !isPasswordVisible);
                },
              )
            : null,
      ),
    );
  }

  Widget _submitButton() {
    return ElevatedButton(
      onPressed: signInWithEmailAndPassword,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xff4c505b),
        foregroundColor: Colors.white,
        alignment: Alignment.center,
      ),
      child: const Text('Login'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/login.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            Container(
              padding: const EdgeInsets.only(left: 37, top: 120),
              child: const Text(
                'Welcome to User Management App',
                style: TextStyle(color: Colors.black, fontSize: 28),
              ),
            ),
            SingleChildScrollView(
              child: Container(
                padding:
                    EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 35),
                      child: Column(
                        children: [
                          _buildTextField(
                              hint: 'Email', controller: _controllerEmail),
                          const SizedBox(height: 20),
                          _buildTextField(
                              hint: 'Password',
                              controller: _controllerPassword,
                              isPassword: true),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Checkbox(
                                    value: rememberMe,
                                    onChanged: (val) {
                                      setState(() => rememberMe = val ?? false);
                                    },
                                  ),
                                  const Text("Remember Me"),
                                ],
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pushNamed(context, '/forgot-password');
                                },
                                child: const Text(
                                  "Forgot Password?",
                                  style: TextStyle(
                                      decoration: TextDecoration.underline,
                                      color: Color(0xff4c505b)),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 30),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Sign In',
                                style: TextStyle(
                                  fontSize: 27,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              _submitButton(),
                            ],
                          ),
                          const SizedBox(height: 30),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const Text("Don't have an account? "),
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => MyRegister()),
                                  );
                                },
                                child: const Text(
                                  'Sign Up',
                                  style: TextStyle(
                                    decoration: TextDecoration.underline,
                                    color: Color(0xff4c505b),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
