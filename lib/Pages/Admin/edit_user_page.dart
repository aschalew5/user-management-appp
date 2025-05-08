// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';


// class EditUserPage extends StatefulWidget {
//   final DocumentSnapshot user;
//   EditUserPage({required this.user});

//   @override
//   _EditUserPageState createState() => _EditUserPageState();
// }

// class _EditUserPageState extends State<EditUserPage> {
//   final _formKey = GlobalKey<FormState>();
//   late String _email, _role;

//   @override
//   void initState() {
//     super.initState();
//     _email = widget.user['email'];
//     _role = widget.user['role'] ?? 'user';
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Edit User')),
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
//               DropdownButtonFormField<String>(
//                 value: _role,
//                 items: ['admin', 'user'].map((role) {
//                   return DropdownMenuItem(
//                     value: role,
//                     child: Text(role.toUpperCase()),
//                   );
//                 }).toList(),
//                 onChanged: (value) => setState(() => _role = value!),
//               ),
//               ElevatedButton(
//                 child: Text('Save'),
//                 onPressed: () async {
//                   if (_formKey.currentState!.validate()) {
//                     await FirebaseFirestore.instance
//                         .collection('Users')
//                         .doc(widget.user.id)
//                         .update({
//                           'email': _email,
//                           'role': _role,
//                         });
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