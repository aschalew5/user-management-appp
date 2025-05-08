import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:user_profile_app/Model/user.dart';
import 'package:user_profile_app/Pages/home_page.dart';
import 'package:image_picker/image_picker.dart';

class AddUser extends StatefulWidget {
  const AddUser({Key? key}) : super(key: key);

  @override
  _AddUserState createState() => _AddUserState();
}

class _AddUserState extends State<AddUser> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  String firstName = "";
  String lastName = "";
  String Email = "";
  String PhoneNumber = "";
  String Adresse = "";
  String img = "";
  String role= "";
  final List<String> roles = ['admin', 'user'];


  Future createUser() async {
    final docUser = FirebaseFirestore.instance.collection('Users').doc();
    final user = Users(
      uid: docUser.id,
      firstName: firstName,
      lastName: lastName,
      email: Email,
      phoneNumber: PhoneNumber,
      adresse: Adresse,
      img: img,
      role: role
    );
    final json = user.toJson();
    await docUser.set(json);
  }

  void _submit() {
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(32.0))),
          title: const Text('Your information has been submitted'),
          content: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                const Align(
                    alignment: Alignment.topLeft,
                    child: Text("Full name:",
                        style: TextStyle(fontWeight: FontWeight.w700))),
                Align(
                  alignment: Alignment.topLeft,
                  child: Text("$firstName $lastName"),
                ),
                const SizedBox(height: 10),
                const Align(
                    alignment: Alignment.topLeft,
                    child: Text("Address, Phone Number",
                        style: TextStyle(fontWeight: FontWeight.w700))),
                Align(
                  alignment: Alignment.topLeft,
                  child: Text("$Adresse, $PhoneNumber"),
                )
              ],
            ),
          ),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.grey,
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                  ),
                  child: const Text('Go to profile'),
                  onPressed: () async {
                    FocusScope.of(context).unfocus();
                    Navigator.pop(context);
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => HomePage()),
                    ).then((_) => _formKey.currentState?.reset());
                    setState(() {});
                  },
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.blue,
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                  ),
                  child: const Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    FocusScope.of(context).unfocus();
                    _formKey.currentState?.reset();
                    Navigator.pop(context, MaterialPageRoute(builder: (context) => HomePage()));
                  },
                )
              ],
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        backgroundColor: Colors.grey.shade900,
        foregroundColor: Colors.white,
        title: const Text("Add User"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                const Align(
                  alignment: Alignment.topLeft,
                  child: Text("Enter your Information",
                      style: TextStyle(fontSize: 24)),
                ),
                const SizedBox(height: 20),
                IconButton(
                  icon: const Icon(Icons.camera_alt),
                  onPressed: () async {
                    final ImagePicker picker = ImagePicker();
                    final XFile? file = await picker.pickImage(source: ImageSource.gallery);
                    if (file == null) return;

                    final bytes = await file.readAsBytes();
                    const uploadUrl = 'https://api.cloudinary.com/v1_1/dbv0ls0dx/image/upload';
                    const uploadPreset = 'profile_preset';

                    final request = http.MultipartRequest('POST', Uri.parse(uploadUrl));
                    request.fields['upload_preset'] = uploadPreset;
                    request.files.add(http.MultipartFile.fromBytes(
                      'file',
                      bytes,
                      filename: 'upload.jpg',
                    ));

                    final response = await request.send();
                    final res = await http.Response.fromStream(response);

                    if (response.statusCode == 200) {
                      final data = json.decode(res.body);
                      setState(() {
                        img = data['secure_url'];
                      });
                    } else {
                      print('Upload failed: ${res.body}');
                    }
                  },
                ),
                const SizedBox(height: 20),
                Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      TextFormField(
                        decoration: const InputDecoration(
                            labelText: 'First Name',
                            border: OutlineInputBorder()),
                        validator: (value) {
                          if (value == null || value.isEmpty || value.length < 3) {
                            return 'First Name must contain at least 3 characters';
                          }
                          return null;
                        },
                        onChanged: (value) => setState(() => firstName = value.capitalize()),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        decoration: const InputDecoration(
                            labelText: 'Last Name',
                            border: OutlineInputBorder()),
                        validator: (value) {
                          if (value == null || value.isEmpty || value.length < 3) {
                            return 'Last Name must contain at least 3 characters';
                          }
                          return null;
                        },
                        onChanged: (value) => setState(() => lastName = value.capitalize()),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        decoration: const InputDecoration(
                            labelText: 'Email',
                            border: OutlineInputBorder()),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Email is required';
                          }
                          final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
                          if (!emailRegex.hasMatch(value)) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                        onChanged: (value) => setState(() => Email = value),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        decoration: const InputDecoration(
                            labelText: 'Phone Number',
                            border: OutlineInputBorder()),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty || value.length < 7) {
                            return 'Phone number must be more than 7 digits';
                          }
                          return null;
                        },
                        onChanged: (value) => setState(() => PhoneNumber = value),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        decoration: const InputDecoration(
                            labelText: 'Address',
                            border: OutlineInputBorder()),
                        validator: (value) {
                          if (value == null || value.isEmpty || value.length < 3) {
                            return 'Address must contain at least 3 characters';
                          }
                          return null;
                        },
                        onChanged: (value) => setState(() => Adresse = value.capitalize()),
                      ),
                      const SizedBox(height: 20),
                      DropdownButtonFormField<String>(
  value: role.isNotEmpty ? role : null,
  items: roles.map((String value) {
    return DropdownMenuItem<String>(
      value: value,
      child: Text(value[0].toUpperCase() + value.substring(1)),
    );
  }).toList(),
  onChanged: (value) => setState(() => role = value ?? ''),
  decoration: const InputDecoration(
    labelText: 'Select Role',
    border: OutlineInputBorder(),
  ),
  validator: (value) {
    if (value == null || value.isEmpty) {
      return 'Please select a role';
    }
    return null;
  },
),
const SizedBox(height: 20),

                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey.shade900,
                            minimumSize: const Size.fromHeight(60)),
                        onPressed: () {
  if (_formKey.currentState!.validate()) {
    if (img.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please upload a profile image")),
      );
      return;
    }

    _submit();
    createUser();
  }
},

                        child: const Text("Submit"),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
