import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home_page.dart';

class MyRegister extends StatefulWidget {
  const MyRegister({Key? key}) : super(key: key);

  @override
  _MyRegisterState createState() => _MyRegisterState();
}

class _MyRegisterState extends State<MyRegister> {
  String? errorMessage = '';
  bool _submitted = false;

  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();
  final TextEditingController _controllerName = TextEditingController();
  final TextEditingController _controllerPhone = TextEditingController();

  Future<void> createUserWithEmailAndPassword() async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: _controllerEmail.text.trim(),
        password: _controllerPassword.text.trim(),
      );

      // Save user data to Firestore
      final newUser = {
  'uid': userCredential.user!.uid,
  'firstName': _controllerName.text.trim(),
  'lastName': '',
  'email': _controllerEmail.text.trim(),
  'phoneNumber': _controllerPhone.text.trim(),
  'adresse': '',
  'img': '',
  'role': 'user',
};
await FirebaseFirestore.instance
    .collection('Users')
    .doc(userCredential.user!.uid)
    .set(newUser);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
        _errorMessage();
      });
    }
  }

  Widget _title() {
    return const Text('Create\nAccount',
        style: TextStyle(color: Colors.white, fontSize: 33));
  }

  String? get _errorText {
    final password = _controllerPassword.value.text;
    final email = _controllerEmail.value.text;
    if (password.isEmpty && email.isEmpty) {
      return 'Can\'t be empty';
    }
    return null;
  }

  Widget _entryField(String title, TextEditingController controller) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: Colors.white,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: Colors.black,
          ),
        ),
        errorText: _submitted ? _errorText : null,
        hintText: title,
        hintStyle: const TextStyle(color: Colors.white),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _errorMessage() {
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      SnackBar(
        content: Text(
          errorMessage == '' ? '' : 'Humm ? $errorMessage',
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _submitButton() {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _submitted = true;
        });
        createUserWithEmailAndPassword();
      },
      style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 229, 231, 237),
          alignment: Alignment.center),
      child: const Text('Register'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
            image: AssetImage('assets/register.png'), fit: BoxFit.cover),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Stack(
          children: [
            Container(
                padding: const EdgeInsets.only(left: 35, top: 30),
                child: _title()),
            SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(left: 35, right: 35),
                      child: Column(
                        children: [
                          _entryField("Name", _controllerName),
                          const SizedBox(height: 30),
                          _entryField("Phone Number", _controllerPhone),
                          const SizedBox(height: 30),
                          _entryField("Email", _controllerEmail),
                          const SizedBox(height: 30),
                          _entryField("Password", _controllerPassword),
                          const SizedBox(height: 40),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Flexible(
                                child: Text(
                                  'Sign Up',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 27,
                                      fontWeight: FontWeight.w700),
                                ),
                              ),
                              _submitButton(),
                            ],
                          ),
                          const SizedBox(height: 40),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            style: const ButtonStyle(),
                            child: const Text(
                              'Sign In',
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                  decoration: TextDecoration.underline,
                                  color: Colors.white,
                                  fontSize: 18),
                            ),
                          ),
                        ],
                      ),
                    ),
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
