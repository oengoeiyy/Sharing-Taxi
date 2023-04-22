import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sharing_taxi/main.dart';
import 'package:sharing_taxi/models/passenger.dart';
import 'package:sharing_taxi/screens/a_my_bottom_appbar.dart';
import 'package:sharing_taxi/screens/a_my_drawer.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  //final auth = FirebaseAuth.instance;
  CollectionReference passengerCollection =
      FirebaseFirestore.instance.collection("passengers");
  Passenger passenger = Passenger();
  bool isEnabled = false;
  final formKey = GlobalKey<FormState>();
  final TextEditingController name = TextEditingController();
  final TextEditingController tel = TextEditingController();
  var url;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        bottomNavigationBar: BottomAppBar(
          //color: Colors.pink,
          child: MyBottomAppbar(page: 'profile'),
        ),
        drawer: const MyDrawer(),
        key: scaffoldKey,
        body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('passengers')
              .where("email", isEqualTo: "${auth.currentUser!.email}")
              .snapshots(),
          builder: (_, snapshot) {
            if (snapshot.hasError) return Text('Error = ${snapshot.error}');

            if (snapshot.hasData) {
              final docs = snapshot.data!.docs;

              final data = docs[0].data();

              passenger.name = data['name'];
              passenger.tel = data['tel'];

              return GestureDetector(
                onTap: () => FocusScope.of(context).unfocus(),
                child: SafeArea(
                  child: SingleChildScrollView(
                    child: Stack(
                      children: [
                        Container(
                            height: MediaQuery.of(context).size.height * 0.22,
                            decoration: const BoxDecoration(
                              image: DecorationImage(
                                  opacity: 1,
                                  image: AssetImage("assets/taxi-bggg.jpg"),
                                  fit: BoxFit.cover),
                            )),
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              16, 25, 16, 0),
                          child: IconButton(
                            onPressed: () async {
                              scaffoldKey.currentState!.openDrawer();
                            },
                            icon: const Icon(
                              Icons.menu_rounded,
                              color: Color.fromARGB(218, 255, 255, 255),
                              size: 34,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 0),
                          child: Center(
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width * 0.65,
                              child: Form(
                                key: formKey,
                                child: Column(
                                  //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.1,
                                    ),
                                    Container(
                                      width:
                                          MediaQuery.of(context).size.height *
                                              0.2,
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.2,
                                      //color: Colors.pink,
                                      child: Stack(
                                        children: [
                                          (data['imageURL'] == '')
                                              ? CircleAvatar(
                                                  radius: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      0.1, // Image radius
                                                  backgroundImage: const AssetImage(
                                                      'assets/default_profile.jpg'))
                                              : CircleAvatar(
                                                  radius: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      0.1, // Image radius
                                                  backgroundImage: NetworkImage(
                                                      data['imageURL']
                                                          .toString()),
                                                ),
                                          isEnabled
                                              ? Align(
                                                  alignment:
                                                      Alignment.bottomRight,
                                                  child: ElevatedButton(
                                                      style: ButtonStyle(
                                                        elevation:
                                                            MaterialStateProperty
                                                                .all(1),
                                                        shape: MaterialStateProperty.all<
                                                                CircleBorder>(
                                                            const CircleBorder(
                                                                side: BorderSide(
                                                                    width: 0.5,
                                                                    color: Color
                                                                        .fromARGB(
                                                                            255,
                                                                            213,
                                                                            213,
                                                                            213)))),
                                                        backgroundColor:
                                                            MaterialStateProperty
                                                                .all(Colors
                                                                    .white),
                                                      ),
                                                      onPressed: () {
                                                        _showPicker(context);
                                                      },
                                                      child: const Icon(
                                                        Icons.camera_alt,
                                                        color: Colors.grey,
                                                      )),
                                                )
                                              : const SizedBox(),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    isEnabled
                                        ? TextFormField(
                                            controller: name,
                                            onSaved: (String? name) {
                                              passenger.name = name;
                                            },
                                            decoration: InputDecoration(
                                              enabled: isEnabled,
                                              isDense: !isEnabled,
                                              contentPadding:
                                                  const EdgeInsets.all(5),
                                              hintText: data['name'],
                                              icon: const Icon(
                                                Icons.person,
                                                size: 30,
                                              ),
                                            ))
                                        : TextFormField(
                                            controller: TextEditingController(
                                                text: data['name']),
                                            onSaved: (String? name) {
                                              passenger.name = name;
                                            },
                                            decoration: InputDecoration(
                                              enabled: isEnabled,
                                              isDense: !isEnabled,
                                              contentPadding:
                                                  const EdgeInsets.all(5),
                                              label: const Text('Name'),
                                              hintText: data['name'],
                                              icon: const Icon(
                                                Icons.person,
                                                size: 30,
                                              ),
                                            )),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    TextFormField(
                                        controller: TextEditingController(
                                            text: data['email']),
                                        decoration: InputDecoration(
                                          enabled: false,
                                          isDense: true,
                                          border: isEnabled
                                              ? InputBorder.none
                                              : null,
                                          contentPadding:
                                              const EdgeInsets.all(5),
                                          label: const Text('Email'),
                                          icon: const Icon(
                                            Icons.email,
                                            size: 30,
                                          ),
                                        )),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    isEnabled
                                        ? TextFormField(
                                            keyboardType: TextInputType.phone,
                                            controller: tel,
                                            onSaved: (String? tel) {
                                              passenger.tel = tel;
                                            },
                                            validator: MultiValidator([
                                              PatternValidator(
                                                  r'(^(?:[+0]9)?[0-9]{10}$)',
                                                  errorText:
                                                      "Invalid telephone number."),
                                              PatternValidator(
                                                  r'(^(?:[+0]9)?0[689]{1}[0-9]{8}$)',
                                                  errorText:
                                                      "This number not available."),
                                            ]),
                                            decoration: InputDecoration(
                                              enabled: isEnabled,
                                              isDense: !isEnabled,
                                              contentPadding:
                                                  const EdgeInsets.all(5),
                                              hintText: data['tel'],
                                              icon: const Icon(
                                                Icons.phone_android,
                                                size: 30,
                                              ),
                                            ))
                                        : TextFormField(
                                            keyboardType: TextInputType.phone,
                                            controller: TextEditingController(
                                                text: data['tel']),
                                            onSaved: (String? tel) {
                                              passenger.tel = tel;
                                            },
                                            validator: PatternValidator(
                                                r'(^(?:[+0]9)?[0-9]{10}$)',
                                                errorText:
                                                    "invalid telephone number"),
                                            decoration: InputDecoration(
                                              enabled: isEnabled,
                                              isDense: !isEnabled,
                                              contentPadding:
                                                  const EdgeInsets.all(5),
                                              label: const Text(
                                                  'Telephone number'),
                                              hintText: data['tel'],
                                              icon: const Icon(
                                                Icons.phone_android,
                                                size: 30,
                                              ),
                                            )),
                                    const SizedBox(
                                      height: 50,
                                    ),
                                    isEnabled
                                        ? Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              InkWell(
                                                child: Text("Submit",
                                                    style: GoogleFonts.cairo(
                                                      //decoration: TextDecoration.underline,
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    )),
                                                onTap: () async {
                                                  if (formKey.currentState!
                                                      .validate()) {
                                                    formKey.currentState
                                                        ?.save();
                                                    if (passenger
                                                        .name!.isEmpty) {
                                                      passenger.name =
                                                          data['name'];
                                                    }
                                                    if (passenger
                                                        .tel!.isEmpty) {
                                                      passenger.tel =
                                                          data['tel'];
                                                    }
                                                    try {
                                                      //final auth = FirebaseAuth.instance;
                                                      await passengerCollection
                                                          .doc(auth
                                                              .currentUser!.uid)
                                                          .update({
                                                        "name": passenger.name,
                                                        "tel": passenger.tel,
                                                      }).then((value) {
                                                        Fluttertoast.showToast(
                                                            msg: "Edit Success",
                                                            gravity:
                                                                ToastGravity
                                                                    .BOTTOM,
                                                            timeInSecForIosWeb:
                                                                10);
                                                        Navigator.pushReplacement(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder:
                                                                    (context) {
                                                          return const ProfileScreen();
                                                        }));
                                                      });
                                                    } on FirebaseAuthException catch (e) {
                                                      String? message;

                                                      message = e.message;

                                                      Fluttertoast.showToast(
                                                          //msg: e.message.toString(),
                                                          msg: message
                                                              .toString(),
                                                          gravity: ToastGravity
                                                              .CENTER);
                                                    }
                                                  }
                                                },
                                              ),
                                              const SizedBox(
                                                width: 50,
                                              ),
                                              InkWell(
                                                child: Text("Cancel",
                                                    style: GoogleFonts.cairo(
                                                      //decoration: TextDecoration.underline,
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    )),
                                                onTap: () {
                                                  formKey.currentState?.reset();
                                                  setState(() {
                                                    name.text = '';
                                                    tel.text = '';
                                                    isEnabled = isEnabled
                                                        ? false
                                                        : true;
                                                  });
                                                },
                                              ),
                                            ],
                                          )
                                        : InkWell(
                                            child: Text("Edit profile",
                                                style: GoogleFonts.cairo(
                                                  //decoration: TextDecoration.underline,
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w500,
                                                )),
                                            onTap: () {
                                              setState(() {
                                                isEnabled =
                                                    isEnabled ? false : true;
                                              });
                                            },
                                          ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            return const Center(child: CircularProgressIndicator());
          },
        ));
  }

  firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instance;

  File? _photo;
  final ImagePicker _picker = ImagePicker();

  Future imgFromGallery() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _photo = File(pickedFile.path);
        uploadFile();
      } else {
        print('No image selected.');
      }
    });
  }

  Future imgFromCamera() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);

    setState(() {
      if (pickedFile != null) {
        _photo = File(pickedFile.path);
        uploadFile();
      } else {
        print('No image selected.');
      }
    });
  }

  String urlPic = '';

  Future uploadFile() async {
    if (_photo == null) return;
    //final fileName = basename(_photo!.path);
    final destination = 'user_files/${auth.currentUser!.uid}';

    try {
      final ref = firebase_storage.FirebaseStorage.instance
          .ref(destination)
          .child('${auth.currentUser!.uid}/');
      await ref.putFile(_photo!).then((p0) async {
        urlPic = await p0.ref.getDownloadURL();
        await FirebaseFirestore.instance
            .collection('passengers')
            .doc(auth.currentUser!.uid)
            .update({"imageURL": urlPic});
        setState(() {});
        print(urlPic);
      });
    } catch (e) {
      print('error occured');
    }
  }

  void _showPicker(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Wrap(
              children: <Widget>[
                ListTile(
                    leading: const Icon(Icons.photo_library),
                    title: const Text('Gallery'),
                    onTap: () {
                      imgFromGallery();
                      Navigator.of(context).pop();
                    }),
                ListTile(
                  leading: new Icon(Icons.photo_camera),
                  title: new Text('Camera'),
                  onTap: () {
                    imgFromCamera();
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          );
        });
  }
}
