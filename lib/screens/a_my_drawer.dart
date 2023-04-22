import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:sharing_taxi/main.dart';
import 'package:sharing_taxi/screens/a_my_home_bottomappbar.dart';
import 'package:sharing_taxi/dump/fake_home_screen.dart';
import 'package:sharing_taxi/screens/b_login_screen.dart';
import 'package:sharing_taxi/screens/a_map_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sharing_taxi/dump/bottomappbardemo.dart';
import 'package:sharing_taxi/screens/a_profile_screen.dart';
import 'package:sharing_taxi/screens/c_home_screen.dart';
import 'package:sharing_taxi/screens/f_saved_location_screen.dart';
import 'package:sharing_taxi/screens/g_history_screen.dart';
import 'package:sharing_taxi/services/image_picker.dart';

class MyDrawer extends StatefulWidget {
  const MyDrawer({Key? key}) : super(key: key);

  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('passengers')
          .where("email", isEqualTo: "${auth.currentUser?.email}")
          .snapshots(),
      builder: (_, snapshot) {
        if (snapshot.hasError) return Text('Error = ${snapshot.error}');

        if (snapshot.hasData) {
          final docs = snapshot.data!.docs;

          final data = docs[0].data();

          return Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
              child: SafeArea(
                  child: Drawer(
                width: MediaQuery.of(context).size.width * 0.55,
                child: ListView(
                  // Important: Remove any padding from the ListView.
                  padding: EdgeInsets.zero,
                  children: [
                    SizedBox(
                      height: 200,
                      child: DrawerHeader(
                          margin: EdgeInsets.zero,
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                                opacity: 1,
                                image: AssetImage("assets/taxi-bgg.jpg"),
                                fit: BoxFit.cover),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              (data['imageURL'] == '')
                                  ? const CircleAvatar(
                                      radius: 55, // Image radius
                                      backgroundImage: AssetImage(
                                          'assets/default_profile.jpg'))
                                  : CircleAvatar(
                                      radius: 55, // Image radius
                                      backgroundImage: NetworkImage(
                                          data['imageURL'].toString()),
                                    ),
                              const SizedBox(height: 15),
                              Text(data['name'],
                                  style: const TextStyle(
                                      color:
                                          Color.fromARGB(255, 255, 255, 255))),
                              Text(data['email'],
                                  style: const TextStyle(
                                      color:
                                          Color.fromARGB(255, 255, 255, 255))),
                            ],
                          )),
                    ),
                    const Divider(),
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: ListTile(
                        dense: true,
                        title: Text(
                          'Home',
                          style:
                              TextStyle(fontSize: 18, color: Colors.grey[800]),
                        ),
                        leading: Icon(
                          Icons.home_outlined,
                          color: Colors.grey[800],
                        ),
                        onTap: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return const HomeScreen();
                          }));
                        },
                      ),
                    ),
                    const Divider(),
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: ListTile(
                        dense: true,
                        title: Text(
                          'Profile',
                          style:
                              TextStyle(fontSize: 18, color: Colors.grey[800]),
                        ),
                        leading: Icon(
                          Icons.account_box_outlined,
                          color: Colors.grey[800],
                        ),
                        onTap: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return const ProfileScreen();
                          }));
                        },
                      ),
                    ),
                    const Divider(),
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: ListTile(
                        dense: true,
                        title: Text(
                          'History',
                          style:
                              TextStyle(fontSize: 18, color: Colors.grey[800]),
                        ),
                        leading: Icon(
                          Icons.history,
                          color: Colors.grey[800],
                        ),
                        onTap: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return const HistoryScreen();
                          }));
                        },
                      ),
                    ),
                    const Divider(),
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: ListTile(
                        dense: true,
                        title: Text(
                          'Saved Location',
                          style:
                              TextStyle(fontSize: 18, color: Colors.grey[800]),
                        ),
                        leading: Icon(
                          Icons.favorite_border_outlined,
                          color: Colors.grey[800],
                        ),
                        onTap: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return const SavedLocationScreen();
                          }));
                        },
                      ),
                    ),
                    const Divider(),
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: ListTile(
                        dense: true,
                        title: Text(
                          'Logout',
                          style:
                              TextStyle(fontSize: 18, color: Colors.grey[800]),
                        ),
                        leading: Icon(
                          Icons.exit_to_app_rounded,
                          color: Colors.grey[800],
                        ),
                        onTap: () {
                          Navigator.of(context)
                              .popUntil((route) => route.isFirst);
                          Navigator.pushReplacement(context,
                              MaterialPageRoute(builder: (context) {
                            return const LoginScreen();
                          }));

                          _signOut();
                        },
                      ),
                    ),
                    const Divider(),
                  ],
                ),
              )));
        }

        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
  }
}
