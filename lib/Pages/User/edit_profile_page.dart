// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// class EditProfilePage extends StatefulWidget {
//   @override
//   _EditProfilePageState createState() => _EditProfilePageState();
// }

// class _EditProfilePageState extends State<EditProfilePage> {
//   final _formKey = GlobalKey<FormState>();
//   late String _email;

//   @override
//   void initState() {
//     super.initState();
//     _email = FirebaseAuth.instance.currentUser!.email!;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Edit Profile')),
//       body: Form(
//         key: _formKey,
//         child: Padding(
//           padding: EdgeInsets.all(16.0),
//           child: Column(
//             children: [
//               TextFormField(
//                 initialValue: _email,
//                 decoration: InputDecoration(labelText: 'Email'),
//                 validator: (value) => value!.isEmpty ? 'Required' : null,
//                 onChanged: (value) => _email = value,
//               ),
//               ElevatedButton(
//                 child: Text('Save'),
//                 onPressed: () async {
//                   if (_formKey.currentState!.validate()) {
//                     // Update both auth email and Firestore
//                     final user = FirebaseAuth.instance.currentUser!;
//                     await user.updateEmail(_email);
//                     await FirebaseFirestore.instance
//                         .collection('users')
//                         .doc(user.uid)
//                         .update({'email': _email});
//                     Navigator.pop(context);
//                   }
//                 },
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }