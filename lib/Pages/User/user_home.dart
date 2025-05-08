// import 'package:flutter/material.dart';
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:user_profile_app/Pages/User/edit_profile_page.dart';
// class UserHomePage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     final currentUserId = FirebaseAuth.instance.currentUser!.uid;

//     return Scaffold(
//       appBar: AppBar(title: Text('User Directory')),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: FirebaseFirestore.instance.collection('users').snapshots(),
//         builder: (context, snapshot) {
//           if (!snapshot.hasData) return CircularProgressIndicator();
          
//           return ListView.builder(
//             itemCount: snapshot.data!.docs.length,
//             itemBuilder: (context, index) {
//               var user = snapshot.data!.docs[index];
//               return ListTile(
//                 title: Text(user['email']),
//                 subtitle: Text('Role: ${user['role']}'),
//                 trailing: user.id == currentUserId 
//                   ? IconButton(
//                       icon: Icon(Icons.edit),
//                       onPressed: () => _editOwnProfile(context),
//                     )
//                   : null,
//               );
//             },
//           );
//         },
//       ),
//     );
//   }

//   void _editOwnProfile(BuildContext context) {
//     Navigator.push(context, MaterialPageRoute(
//       builder: (_) => EditProfilePage(),
//     ));
//   }
// }