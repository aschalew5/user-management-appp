import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:user_profile_app/Pages/home_page.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:url_launcher/url_launcher.dart';
import '../Model/user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:qr_flutter/qr_flutter.dart' as qr_flutter;
import 'dart:convert';



class Profile extends StatefulWidget {
  const Profile({super.key, required this.user});
  final Users user;

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String currentUserId = '';
  String currentUserRole = 'user';
  String currentImage = '';

  @override
  void initState() {
    super.initState();
    currentImage = widget.user.img;
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      currentUserId = user.uid;
      FirebaseFirestore.instance
          .collection('Users')
          .doc(currentUserId)
          .get()
          .then((doc) {
        if (doc.exists) {
          setState(() {
            currentUserRole = doc['role'] ?? 'user';
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.grey.shade900,
          foregroundColor: Colors.white,
          title: const Text("Profile Page"),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.home, size: 32.0),
            
              tooltip: 'Home',
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HomePage(),
                    ));
              },
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 120,
                    backgroundImage: NetworkImage(currentImage),
                  ),
                  if (currentUserId == widget.user.uid || currentUserRole == 'admin')
                    IconButton(
                      icon: const Icon(Icons.camera_alt, color: Colors.black),
                      onPressed: _pickAndUploadImage,
                    ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                "${widget.user.firstName} ${widget.user.lastName}",
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 18),
              Text(widget.user.email),
              const SizedBox(height: 20),
              buildQRCode(),
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    icon: const FaIcon(FontAwesomeIcons.phoneFlip),
                    onPressed: () async {
                      final Uri launchUri = Uri(
                        scheme: 'tel',
                        path: widget.user.phoneNumber,
                      );
                      await launchUrl(launchUri);
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                      backgroundColor: Colors.grey.shade900,
                      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                    ),
                    label: Text(widget.user.phoneNumber),
                  ),
                  const SizedBox(width: 18),
                  ElevatedButton.icon(
                    icon: const FaIcon(Icons.location_city),
                    onPressed: () async {
                      MapsLauncher.launchQuery(widget.user.adresse);
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                      backgroundColor: Colors.grey.shade900,
                      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                    ),
                    label: Text(widget.user.adresse),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (currentUserRole == 'admin' || currentUserId == widget.user.uid)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.edit),
                      label: const Text("Edit"),
                      onPressed: () => _showEditProfileDialog(widget.user),
                    ),
                    const SizedBox(width: 10),
                    if (currentUserRole == 'admin')
                      ElevatedButton.icon(
                        icon: const Icon(Icons.delete),
                        label: const Text("Delete"),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        onPressed: () => _confirmDelete(widget.user.uid),
                      ),
                  ],
                ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          heroTag: "btn3",
          onPressed: () async {
            final Uri launchUri = Uri(
              scheme: 'mailto',
              path: widget.user.email,
            );
            await launchUrl(launchUri);
          },
          backgroundColor: Colors.grey.shade900,
          child: const Icon(Icons.send),
        ),
      ),
    );
  }
  Widget buildQRCode() {
  final userData = {
    'firstName': widget.user.firstName,
    'lastName': widget.user.lastName,
    'email': widget.user.email,
    'role': widget.user.role,
    'uid': widget.user.uid,
  };
  final jsonStr = jsonEncode(userData);

  return Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      const SizedBox(height: 20),
      const Text("Scan this QR to view user profile:"),
      const SizedBox(height: 10),
      
      qr_flutter.QrImageView(
        data: jsonStr,
        version:qr_flutter.QrVersions.auto,
        size: 100.0,
        backgroundColor: Colors.white,

      ),
    ],
  );
}


  void _showEditProfileDialog(Users user) {
    final firstNameCtrl = TextEditingController(text: user.firstName);
    final lastNameCtrl = TextEditingController(text: user.lastName);
    final addressCtrl = TextEditingController(text: user.adresse);
    final phoneCtrl = TextEditingController(text: user.phoneNumber);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit Profile"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: firstNameCtrl, decoration: const InputDecoration(labelText: "First Name")),
              TextField(controller: lastNameCtrl, decoration: const InputDecoration(labelText: "Last Name")),
              TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: "Phone")),
              TextField(controller: addressCtrl, decoration: const InputDecoration(labelText: "Address")),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            child: const Text("Save"),
           onPressed: () {
  FirebaseFirestore.instance.collection('Users').doc(user.uid).update({
    'firstName': firstNameCtrl.text,
    'lastName': lastNameCtrl.text,
    'phoneNumber': phoneCtrl.text,
    'adresse': addressCtrl.text,
  }).then((_) {
    widget.user.firstName = firstNameCtrl.text;
    widget.user.lastName = lastNameCtrl.text;
    widget.user.phoneNumber = phoneCtrl.text;
    widget.user.adresse = addressCtrl.text;

    Navigator.of(context).pop();
    setState(() {});
  });
},

          ),
        ],
      ),
    );
  }

  void _confirmDelete(String uid) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Confirm Delete"),
        content: const Text("Are you sure you want to delete this profile?"),
        actions: [
          TextButton(
            child: const Text("Cancel"),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: const Text("Delete"),
            onPressed: () {
              FirebaseFirestore.instance.collection('Users').doc(uid).delete();
              Navigator.pop(context);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _pickAndUploadImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? file = await picker.pickImage(source: ImageSource.gallery);
    if (file == null) return;

    final bytes = await file.readAsBytes();

    const cloudinaryUrl = 'https://api.cloudinary.com/v1_1/dbv0ls0dx/image/upload';
    const uploadPreset = 'profile_preset';

    final request = http.MultipartRequest('POST', Uri.parse(cloudinaryUrl));
    request.fields['upload_preset'] = uploadPreset;
    request.files.add(http.MultipartFile.fromBytes('file', bytes, filename: 'profile.jpg'));

    final response = await request.send();
    final result = await http.Response.fromStream(response);

    if (response.statusCode == 200) {
      final data = json.decode(result.body);
      final imageUrl = data['secure_url'];

      await FirebaseFirestore.instance
          .collection('Users')
          .doc(widget.user.uid)
          .update({'img': imageUrl});

      setState(() {
        currentImage = imageUrl;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Image upload failed: ${result.body}')),
      );
    }
  }
}