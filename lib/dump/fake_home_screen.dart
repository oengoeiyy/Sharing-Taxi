// import '../flutter_flow/flutter_flow_icon_button.dart';
// import '../flutter_flow/flutter_flow_theme.dart';
// import '../flutter_flow/flutter_flow_util.dart';
import 'dart:collection';
import 'dart:convert';
//import 'dart:html';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sharing_taxi/screens/f_add_saved_location_screen.dart';
import 'package:sharing_taxi/screens/d1_create_journey_screen.dart';
import 'package:sharing_taxi/dump/des_location_screen.dart';
import 'package:sharing_taxi/dump/fast_drive_screen.dart';
import 'package:sharing_taxi/dump/from_end_screen.dart';
import 'package:sharing_taxi/screens/a_my_bottom_appbar.dart';
//import 'package:google_fonts/google_fonts.dart';
import 'package:sharing_taxi/screens/a_my_drawer.dart';
import 'package:sharing_taxi/screens/b_login_screen.dart';
import 'package:sharing_taxi/screens/a_map_screen.dart';
import 'package:sharing_taxi/dump/from_start_screen.dart';
import 'package:sharing_taxi/dump/origin_location_screen.dart';
import 'package:sharing_taxi/dump/saved_location_screen.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;

class FakeHomeScreen extends StatefulWidget {
  const FakeHomeScreen({Key? key}) : super(key: key);

  @override
  _FakeHomeScreenState createState() => _FakeHomeScreenState();
}

class _FakeHomeScreenState extends State<FakeHomeScreen> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // bottomNavigationBar: const BottomAppBar(
      //   //color: Colors.pink,
      //   child: MyBottomAppbar(),
      // ),
      key: scaffoldKey,
      backgroundColor: const Color.fromARGB(255, 241, 244, 248),
      drawer: const MyDrawer(),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          child: SafeArea(
            child: Container(
              width: double.infinity,
              decoration:
                  const BoxDecoration(color: Color.fromARGB(255, 250, 250, 250)
                      //color: Color(0xFFF1F4F8),
                      ),
              child: Align(
                alignment: const AlignmentDirectional(0, 0.5),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        topImage(),
                        topElement(),
                        searchbar(),
                        topMenu(),
                      ],
                    ),

                    //tripList(),
                    SizedBox(
                      height: 30,
                    ),
                    oriBox(),
                    SizedBox(
                      height: 30,
                    ),
                    desBox(),
                    SizedBox(
                      height: 15,
                    ),
                    test(),
                    Stack(
                      children: [
                        savedLocationMenu(),
                        addLocationMenu(),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  topMenu() {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 25, 16, 0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () async {
              scaffoldKey.currentState!.openDrawer();
            },
            icon: const Icon(
              Icons.menu_rounded,
              color: Colors.white,
              size: 34,
            ),
          ),
          ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                  primary: const Color.fromARGB(33, 255, 255, 255)),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return const MapScreen();
                }));
              },
              icon: const Icon(
                Icons.map_outlined,
                color: Colors.white,
                size: 30,
              ),
              label: const Text(
                "Map",
                style: const TextStyle(color: Colors.white),
              )),
        ],
      ),
    );
  }

  topImage() {
    return ClipRect(
        child: ImageFiltered(
      imageFilter: ImageFilter.blur(
        sigmaX: 2,
        sigmaY: 2,
      ),
      child: Container(
        width: double.infinity,
        height: 230,
        decoration: BoxDecoration(
          color: const Color(0xFF262D34),
          image: DecorationImage(
            fit: BoxFit.cover,
            image: Image.asset(
              'assets/taxi-bggg.jpg',
            ).image,
          ),
        ),
      ),
    ));
  }

  topElement() {
    return Container(
      width: double.infinity,
      height: 230,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1E2429), Color(0x001E2429)],
          stops: [0, 1],
          begin: AlignmentDirectional(0, 1),
          end: AlignmentDirectional(0, -1),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        //mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Padding(
              padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
              child: SizedBox(
                width: 150,
                height: 90,
              )
              // Image.asset(
              //   'assets/anya.jpg',
              //   width: 230,
              //   height: 90,
              //   fit: BoxFit.fitWidth,
              // ),
              ),
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 24),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(24, 0, 24, 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        'Welcome!',
                        style: TextStyle(
                          fontFamily: 'Lexend Deca',
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(24, 0, 24, 0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        'Find your fellow traveler',
                        style: TextStyle(
                          fontFamily: 'Lexend Deca',
                          color: Color(0xB3FFFFFF),
                          fontSize: 22,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  searchbar() {
    TextEditingController? textController;
    var uuid = const Uuid();
    String sessionToken = '122344';
    List<dynamic> placeList = [];

    void getSuggestion(String input) async {
      String api_key = 'AIzaSyD6SmOYJNbMJFyD2cgkArJMHJtS9zfaTPE';
      String baseURL =
          'https://www.youtube.com/redirect?event=video_description&redir_token=QUFFLUhqa0NIeWJqUU9PcDhhUTlENVBVT3hJbVlCQjVCd3xBQ3Jtc0ttNHRTN2VtNy1NUFZzRTJYZGhwNW5WWHdhcFZ6RDdXem5URkVtelNnNDNpWkZIQzFjRklMTGJhZ1U4MkFRZVFUbTVMWE9GZWxhc0N0ZzFrQ0ZiMWhTWjJ0dGlpOVlaN1lPbE11eTMxRGw2Z0d5R1pkdw&q=https%3A%2F%2Fmaps.googleapis.com%2Fmaps%2Fapi%2Fplace%2Fautocomplete%2Fjson%27%3B&v=SJ0QxkRckqo';
      String request =
          '$baseURL?input=$input&key=$api_key&sessiontoken=$sessionToken';

      var response = await http.get(Uri.parse(request));
      var data = response.body.toString();
      print(response);

      if (response.statusCode == 200) {
        setState(() {
          placeList = jsonDecode(response.body.toString())['predictions'];
        });
      } else {
        throw Exception('Failed to load data');
      }
    }

    void onChange() {
      if (sessionToken == null) {
        setState(() {
          sessionToken = uuid.v4();
        });
      }
      getSuggestion(textController!.text);
    }

    @override
    void initState() {
      super.initState();
      textController = TextEditingController();
      textController?.addListener(() {
        onChange();
      });
    }

    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(18, 200, 18, 0),
      child: Container(
        width: double.infinity,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 1,
              blurRadius: 7,
              offset: const Offset(0, 3), // changes position of shadow
            ),
          ],
        ),
        alignment: const AlignmentDirectional(0, 0),
        child: Column(
          children: [
            Row(
              //mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(4, 0, 4, 0),
                    ///////////////////////
                    child: SizedBox(
                      child: TextFormField(
                        controller: textController,
                        obscureText: false,
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.white,
                              width: 0.5,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.white,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          prefixIcon: const Icon(
                            Icons.search_sharp,
                            color: Color(0xFF57636C),
                          ),
                        ),
                        style: const TextStyle(
                          fontFamily: 'Lexend Deca',
                          color: Color(0xFF57636C),
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(0, 4, 8, 0),
                  child: SizedBox(
                    width: 100,
                    height: 40,
                    child: ElevatedButton(
                      onPressed: () {
                        print('Button pressed ...');
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Colors.amber,
                      ),
                      child: const Text(
                        "Search",
                        style: TextStyle(
                          fontFamily: 'Lexend Deca',
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                ),
                //////////////
              ],
            ),
            Expanded(
                child: ListView.builder(
                    itemCount: placeList.length,
                    itemBuilder: ((context, index) {
                      return ListTile(
                        title: Text(placeList[index]['description']),
                      );
                    })))
          ],
        ),
      ),
    );
  }

  addLocationMenu() {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(20, 10, 20, 0),
      child: Container(
        //height: 200,
        child: Column(
          children: [
            MaterialButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return AddSavedLocationScreen();
                }));
              },
              color: Colors.red,
              textColor: Colors.black,
              padding: const EdgeInsets.all(25),
              shape: const CircleBorder(),
              child: const Icon(
                Icons.add_rounded,
                size: 26,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            const Text(
              "add location",
              style: TextStyle(fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }

  savedLocationMenu() {
    final auth = FirebaseAuth.instance;
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(10, 0, 0, 0),
      child: Container(
        //color: Color.fromARGB(255, 222, 222, 222),
        height: 140,
        width: double.infinity,
        child: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('passengers')
                .doc(auth.currentUser!.uid)
                .collection('saved_locations')
                //.where("email", isEqualTo: "${auth.currentUser!.email}")
                .snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              return Padding(
                padding: const EdgeInsets.fromLTRB(110, 10, 30, 0),
                child: ListView(
                  physics: const NeverScrollableScrollPhysics(),
                  //scrollDirection: Axis.horizontal,
                  children: snapshot.data!.docs.map((document) {
                    return Container(
                      height: 200,
                      child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: ((context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: Column(
                                children: [
                                  MaterialButton(
                                    onPressed: () {
                                      print(snapshot.data!.docs[index]['lat']
                                          .toString());
                                      print(snapshot.data!.docs[index]['lng']
                                          .toString());
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              SavedLocationdumpScreen(
                                            lat: snapshot.data!.docs[index]
                                                ['lat'],
                                            lng: snapshot.data!.docs[index]
                                                ['lng'],
                                          ),
                                        ),
                                      );
                                    },
                                    color: Colors.amber,
                                    textColor: Colors.black,
                                    padding: const EdgeInsets.all(25),
                                    shape: const CircleBorder(),
                                    child: const Icon(
                                      Icons.place,
                                      size: 26,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                    snapshot.data!.docs[index]['name']
                                        .toString(),
                                    style: const TextStyle(fontSize: 15),
                                  ),
                                ],
                              ),
                            );
                          })),
                    );
                  }).toList(),
                ),
              );
            }),
      ),
    );
  }

  tripList() {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(10, 30, 10, 0),
      child: Container(
        //color: Color.fromARGB(255, 222, 222, 222),
        height: 200,
        width: double.infinity,
        child: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('journeys')
                //.doc(auth.currentUser!.uid)
                //.collection('saved_locations')
                //.where("email", isEqualTo: "${auth.currentUser!.email}")
                .snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              return Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                child: ListView(
                  //scrollDirection: Axis.vertical,
                  children: snapshot.data!.docs.map((document) {
                    return Container(
                      color: Colors.white,
                      height: 200,
                      child: ListView.builder(
                          scrollDirection: Axis.vertical,
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: ((context, index) {
                            return Container(
                              height: 100,
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: ElevatedButton(
                                    onPressed: () {
                                      // Navigator.push(context,
                                      //     MaterialPageRoute(builder: (context) {
                                      //   return const LoginScreen();
                                      // }));
                                    },
                                    style: ButtonStyle(
                                      elevation: MaterialStateProperty.all(2),
                                      backgroundColor:
                                          MaterialStateProperty.all(
                                              Color.fromARGB(
                                                  255, 183, 183, 183)),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          snapshot.data!.docs[index]['status']
                                              .toString(),
                                          style: const TextStyle(fontSize: 15),
                                        ),
                                        Text(
                                          snapshot.data!.docs[index]['type']
                                              .toString(),
                                          style: const TextStyle(fontSize: 15),
                                        ),
                                        Text(
                                          snapshot
                                              .data!
                                              .docs[index][
                                                  '${snapshot.data!.docs[index]['type']}' +
                                                      '_lat']
                                              .toString(),
                                          style: const TextStyle(fontSize: 15),
                                        ),
                                        Text(
                                          snapshot
                                              .data!
                                              .docs[index][
                                                  '${snapshot.data!.docs[index]['type']}' +
                                                      '_lng']
                                              .toString(),
                                          style: const TextStyle(fontSize: 15),
                                        ),
                                      ],
                                    )),
                              ),
                            );
                          })),
                    );
                  }).toList(),
                ),
              );
            }),
      ),
    );
  }

  oriBox() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      width: double.infinity,
      height: 140,
      //color: Colors.purple,
      child: SizedBox(
        height: 150,
        width: 150,
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return FromStartScreen();
              // return const OriginLocationScreen(
              //   type: "ori",
              // );
            }));
          },
          style: ButtonStyle(
              elevation: MaterialStateProperty.all(2),
              backgroundColor:
                  MaterialStateProperty.all(Color.fromARGB(255, 255, 255, 255)),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
                //side: BorderSide(color: Colors.red)
              ))),
          child: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              //color: Color.fromARGB(255, 58, 164, 42),
              image: DecorationImage(
                fit: BoxFit.contain,
                image: Image.asset(
                  'assets/taxiicon.png',
                ).image,
              ),
            ),
          ),
        ),
      ),
    );
  }

  desBox() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      width: double.infinity,
      height: 140,
      //color: Colors.purple,
      child: SizedBox(
        height: 150,
        width: 150,
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return const FromEndScreen();
            }));
          },
          style: ButtonStyle(
              elevation: MaterialStateProperty.all(2),
              backgroundColor:
                  MaterialStateProperty.all(Color.fromARGB(255, 255, 255, 255)),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
                //side: BorderSide(color: Colors.red)
              ))),
          child: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              //color: Color.fromARGB(255, 58, 164, 42),
              image: DecorationImage(
                fit: BoxFit.contain,
                image: Image.asset(
                  'assets/taxiicon.png',
                ).image,
              ),
            ),
          ),
        ),
      ),
    );
  }

  test() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      width: double.infinity,
      height: 140,
      //color: Colors.purple,
      child: SizedBox(
        height: 150,
        width: 150,
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return CreateJourneyScreen();
              // return const OriginLocationScreen(
              //   type: "ori",
              // );
            }));
          },
          style: ButtonStyle(
              elevation: MaterialStateProperty.all(2),
              backgroundColor:
                  MaterialStateProperty.all(Color.fromARGB(255, 255, 255, 255)),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
                //side: BorderSide(color: Colors.red)
              ))),
          child: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              //color: Color.fromARGB(255, 58, 164, 42),
              image: DecorationImage(
                fit: BoxFit.contain,
                image: Image.asset(
                  'assets/taxiicon.png',
                ).image,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
