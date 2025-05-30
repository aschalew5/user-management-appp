import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:user_profile_app/Pages/ProfilePage.dart';
import 'package:user_profile_app/auth.dart';
import 'package:user_profile_app/Model/user.dart';
import '../widgets/app_bar.dart';
import 'AddUSer.dart';
import '../theme_notifier.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final User? user = Auth().currentUser;
  String currentUserRole = 'user';

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
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  Widget _signOutButton() {
    return IconButton(
      icon: const Icon(Icons.logout),
      tooltip: 'Logout',
      onPressed: () async => await signOut(),
    );
  }

  Stream<List<Users>> readUsers() => FirebaseFirestore.instance
      .collection("Users")
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => Users.fromJson(doc.data())).toList());

  delete(String id) {
    FirebaseFirestore.instance.collection("Users").doc(id).delete();
  }

  List<Users> _foundedUsers = [];
  List<Users> _users = [];

  relod() => _foundedUsers = _users.toList();

  bool get isAdmin => currentUserRole == 'admin';

  void onSearch(String search) {
    setState(() {
      _foundedUsers = _users.where((u) {
        return u.firstName.toLowerCase().contains(search.toLowerCase()) ||
               u.lastName.toLowerCase().contains(search.toLowerCase()) ||
               u.email.toLowerCase().contains(search.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        title: "Users",
        extraActions: [_signOutButton()],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (value) => onSearch(value),
              decoration: InputDecoration(
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceVariant,
                contentPadding: EdgeInsets.zero,
                prefixIcon: Icon(Icons.search, color: Theme.of(context).iconTheme.color),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50),
                  borderSide: BorderSide.none,
                ),
                hintStyle: Theme.of(context).textTheme.bodyMedium,
                hintText: "Search users",
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Users>>(
              stream: readUsers(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text("Failed to load users.", style: Theme.of(context).textTheme.bodyMedium));
                }
                if (snapshot.hasData) {
                  _users = snapshot.data!;
                  List<Users> visibleUsers = isAdmin ? _users : _users.where((u) => u.uid == user?.uid).toList();
                  final list = _foundedUsers.isNotEmpty ? _foundedUsers : visibleUsers;

                  return list.isNotEmpty
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
                                    MaterialPageRoute(builder: (context) => Profile(user: list[index])),
                                  );
                                },
                                child: userComponent(user: list[index]),
                              ),
                            );
                          },
                        )
                      : Center(child: Text("No users found", style: Theme.of(context).textTheme.bodyMedium));
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: isAdmin
          ? FloatingActionButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AddUser())),
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget userComponent({required Users user}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            height: 60,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: Image.network(
                user.img,
                errorBuilder: (context, error, stackTrace) => Icon(Icons.person, color: Theme.of(context).iconTheme.color),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              "${user.firstName} ${user.lastName}",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 5),
            Text(
              "Email : ${user.email}",
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).hintColor),
            ),
          ]),
        ],
      ),
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
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(32.0))),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(children: <Widget>[
                TextFormField(
                  controller: firstNameController,
                  decoration: const InputDecoration(hintText: 'Enter First Name', enabledBorder: OutlineInputBorder()),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: lastNameController,
                  decoration: const InputDecoration(hintText: 'Enter Last Name', enabledBorder: OutlineInputBorder()),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(shape: const StadiumBorder(), backgroundColor: Colors.greenAccent),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      FirebaseFirestore.instance.collection("Users").doc(user.uid).update({
                        "firstName": firstNameController.text,
                        "lastName": lastNameController.text,
                      }).then((value) => Navigator.of(context).pop());
                    }
                  },
                  child: const Text('Modify'),
                ),
              ]),
            ),
          ),
          actions: [
            Center(
              child: TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.grey.shade900,
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
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
}
