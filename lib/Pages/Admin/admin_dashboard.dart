// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:user_profile_app/Pages/AddUser.dart';
// import 'package:user_profile_app/Pages/Admin/edit_user_page.dart'; // For edit functionality


// class AdminDashboard extends StatelessWidget {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Admin Dashboard'), actions: [
//         IconButton(
//           icon: Icon(Icons.add),
//           onPressed: () => Navigator.push(context, 
//               MaterialPageRoute(builder: (_) => AddUser()))),
//       ]),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: _firestore.collection('users').snapshots(),
//         builder: (context, snapshot) {
//           if (!snapshot.hasData) return CircularProgressIndicator();
          
//           return ListView.builder(
//             itemCount: snapshot.data!.docs.length,
//             itemBuilder: (context, index) {
//               var user = snapshot.data!.docs[index];
//               return ListTile(
//                 title: Text(user['email']),
//                 subtitle: Text('Role: ${user['role']}'),
//                 trailing: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     IconButton(
//                       icon: Icon(Icons.edit),
//                       onPressed: () => _editUser(context, user),
//                     ),
//                     IconButton(
//                       icon: Icon(Icons.delete),
//                       onPressed: () => _deleteUser(user.id),
//                     ),
//                   ],
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }

//   void _editUser(BuildContext context, DocumentSnapshot user) {
//     Navigator.push(context, MaterialPageRoute(
//       builder: (_) => EditUserPage(user: user),
//     ));
//   }

//   void _deleteUser(String userId) async {
//     await _firestore.collection('users').doc(userId).delete();
//   }
// }