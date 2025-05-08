import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:user_profile_app/Pages/ProfilePage.dart';
import 'package:user_profile_app/auth.dart';
import 'package:user_profile_app/Model/user.dart';
import 'AddUSer.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final User? user = Auth().currentUser;
  String currentUserRole = 'user';
  bool showAllUsers = false;

  @override
  void initState() {
    super.initState();
    fetchCurrentUserRole();
  }

  Future<void> fetchCurrentUserRole() async {
    if (user == null) return;

    final doc = await FirebaseFirestore.instance.collection('Users').doc(user!.uid).get();

    if (doc.exists) {
      final data = doc.data();
      final role = (data != null && data['role'] is String) ? data['role'] : null;

      setState(() {
        currentUserRole = role ?? 'user';
      });
    }
  }

  Future<void> signOut() async {
    await Auth().signOut();
  }

  Widget _title() => _userId();

  Widget _userId() => Text(user?.email ?? 'User Email');

  Widget _signOutButton() {
    return IconButton(
        icon: const Icon(Icons.logout, size: 32.0),
        tooltip: 'Logout',
        onPressed: signOut);
  }

  Stream<List<Users>> readUsers() => FirebaseFirestore.instance
      .collection("Users")
      .snapshots()
      .map((snapshot) => snapshot.docs.map((event) => Users.fromJson(event.data())).toList());

  delete(String id) {
    final docUser = FirebaseFirestore.instance.collection("Users").doc(id);
    docUser.delete();
  }

  List<Users> _foundedUsers = [];
  List<Users> _users = [];

  relod() => _foundedUsers = _users.toList();

  bool get isAdmin => currentUserRole == 'admin';

  void onSearch(String search) {
    setState(() {
      _foundedUsers = _users.where((u) {
        final matches = u.firstName.toLowerCase().startsWith(search.toLowerCase()) ||
                        u.lastName.toLowerCase().startsWith(search.toLowerCase()) ||
                        u.email.toLowerCase().startsWith(search.toLowerCase());

        if (isAdmin) return matches;
        return showAllUsers && matches;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        actions: <Widget>[_signOutButton()],
        title: Container(
          height: 38,
          child: TextField(
            onChanged: (value) => onSearch(value),
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color.fromARGB(255, 222, 221, 221),
              contentPadding: EdgeInsets.all(0),
              prefixIcon: Icon(Icons.search, color: Colors.grey.shade500),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(50),
                borderSide: BorderSide.none,
              ),
              hintStyle: TextStyle(fontSize: 14, color: Colors.black),
              hintText: "Search users",
            ),
          ),
        ),
      ),
      body: StreamBuilder<List<Users>>(
        stream: readUsers(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("Failed to load users. Please try again later."));
          }

          if (snapshot.hasData) {
            _users = snapshot.data!;

            List<Users> visibleUsers = _users.where((u) {
              if (isAdmin) return true;
              if (!showAllUsers) return u.uid == user?.uid;
              return false;
            }).toList();

            final list = _foundedUsers.isNotEmpty ? _foundedUsers : visibleUsers;

            return Container(
              color: Colors.white,
              child: list.isNotEmpty
                  ? ListView.builder(
                      itemCount: list.length,
                      itemBuilder: (context, index) {
                        final isOwner = user?.uid == list[index].uid;
                        final canModify = isAdmin || isOwner;
                        return Slidable(
                          key: ValueKey(list[index].uid),
                          endActionPane: canModify
                              ? ActionPane(
                                  motion: const DrawerMotion(),
                                  extentRatio: 0.25,
                                  children: [
                                    SlidableAction(
                                      onPressed: (context) => delete(list[index].uid),
                                      backgroundColor: Colors.transparent,
                                      foregroundColor: Colors.red,
                                      icon: Icons.delete,
                                      label: 'Delete',
                                    ),
                                  ],
                                )
                              : null,
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onLongPress: () {
                              if (canModify) _modifier(user: list[index]);
                            },
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Profile(user: list[index]),
                                ),
                              );
                            },
                            child: userComponent(user: list[index]),
                          ),
                        );
                      })
                  : const Center(
                      child: Text(
                        "No users found",
                        style: TextStyle(color: Colors.black),
                      )),
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            FloatingActionButton(
              heroTag: "btn2",
              onPressed: () {
                setState(() {
                  showAllUsers = true;
                });
              },
              backgroundColor: Colors.blueAccent,
              child: const Icon(Icons.supervised_user_circle_sharp),
            ),
            if (isAdmin)
              FloatingActionButton(
                heroTag: "btn1",
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AddUser()),
                  );
                },
                backgroundColor: Colors.blueAccent,
                child: const Icon(Icons.add),
              ),
          ],
        ),
      ),
    );
  }

  userComponent({required Users user}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.only(top: 10, bottom: 10),
      child: Row(children: [
        SizedBox(
            width: 60,
            height: 60,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: Image.network(user.img, errorBuilder: (context, error, stackTrace) => Icon(Icons.person)),
            )),
        const SizedBox(width: 10),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text("${user.firstName} ${user.lastName}",
              style: const TextStyle(
                  color: Colors.black, fontWeight: FontWeight.w500)),
          const SizedBox(height: 5),
          Text("Email : ${user.email}",
              style: TextStyle(color: Colors.grey[500])),
        ]),
      ]),
    );
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void _modifier({required Users user}) {
    final firstNameController = TextEditingController(text: user.firstName);
    final lastNameController = TextEditingController(text: user.lastName);

    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Modify ${user.firstName} ${user.lastName}"),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(32.0)),
          ),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  TextFormField(
                    controller: firstNameController,
                    decoration: const InputDecoration(
                      hintText: 'Enter First Name',
                      enabledBorder: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: lastNameController,
                    decoration: const InputDecoration(
                      hintText: 'Enter Last Name',
                      enabledBorder: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: const StadiumBorder(),
                      backgroundColor: Colors.greenAccent,
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        final docUser = FirebaseFirestore.instance
                            .collection("Users")
                            .doc(user.uid);

                        docUser.update({
                          "firstName": firstNameController.text,
                          "lastName": lastNameController.text,
                        }).then((value) {
                          Navigator.of(context).pop();
                        });
                      }
                    },
                    child: const Text('Modify'),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            Center(
              child: TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.grey.shade900,
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                ),
                child: const Text('Close'),
                onPressed: () {
                  Navigator.of(context).pop();
                  FocusScope.of(context).unfocus();
                  _formKey.currentState?.reset();
                },
              ),
            ),
          ],
        );
      },
    );
  }

  void _profile() {
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(32.0))),
          title: const Text('User Logged in Information'),
          content: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                const Align(
                    alignment: Alignment.topLeft,
                    child: Text("Email:",
                        style: TextStyle(fontWeight: FontWeight.w700))),
                Align(
                  alignment: Alignment.topLeft,
                  child: _title(),
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.topLeft,
                  child: Text("Role: $currentUserRole",
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                ),
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
                    backgroundColor: Colors.blue,
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                  ),
                  child: const Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    FocusScope.of(context).unfocus();
                  },
                )
              ],
            )
          ],
        );
      },
    );
  }
}