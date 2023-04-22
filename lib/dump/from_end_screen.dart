// import '../flutter_flow/flutter_flow_icon_button.dart';
// import '../flutter_flow/flutter_flow_theme.dart';
// import '../flutter_flow/flutter_flow_util.dart';
import 'dart:convert';
import 'dart:math';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sharing_taxi/screens/f_add_saved_location_screen.dart';
import 'package:sharing_taxi/screens/d1_create_journey_screen.dart';
import 'package:sharing_taxi/screens/e_journey_screen.dart';
import 'package:sharing_taxi/dump/fake_home_screen.dart';
import 'package:sharing_taxi/screens/a_my_bottom_appbar.dart';
//import 'package:google_fonts/google_fonts.dart';
import 'package:sharing_taxi/screens/a_my_drawer.dart';
import 'package:sharing_taxi/screens/b_register_screen.dart';
import 'package:sharing_taxi/dump/saved_location_screen.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;

class FromEndScreen extends StatefulWidget {
  const FromEndScreen({Key? key}) : super(key: key);

  @override
  State<FromEndScreen> createState() => _FromEndScreenState();
}

class _FromEndScreenState extends State<FromEndScreen> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  double currentLat = 0;
  double currentLng = 0;

  Future<Position> _getUserCurrentLocation() async {
    await Geolocator.requestPermission()
        .then((value) {})
        .onError((error, stackTrace) {
      // ignore: avoid_print
      print(error.toString());
    });

    return await Geolocator.getCurrentPosition();
  }

  loadData() {
    _getUserCurrentLocation().then((value) async {
      currentLat = value.latitude;
      currentLng = value.longitude;
      setState(() {});
    });
  }

  location() async {
    List<Location> locations = await locationFromAddress("Central Korat");
    print(locations);
  }

  @override
  void initState() {
    // ignore: todo
    // TODO: implement initState
    super.initState();
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // bottomNavigationBar: const BottomAppBar(
      //   //color: Colors.pink,
      //   child: MyBottomAppbar(),
      // ),
      //appBar: AppBar(backgroundColor: Colors.white),
      key: scaffoldKey,
      backgroundColor: const Color.fromARGB(255, 241, 244, 248),
      drawer: const Drawer(),
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
                        journeyList(),
                        searchbar(),
                        topMenu(),
                      ],
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    const Padding(
                      padding: EdgeInsets.fromLTRB(35, 0, 0, 10),
                      child: Text("Don't see match location? create one!"),
                    ),
                    oriBox(),
                    const SizedBox(
                      height: 20,
                    ),
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
          IconButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return const FakeHomeScreen();
              }));
            },
            icon: const Icon(
              Icons.home,
              color: Colors.white,
              size: 34,
            ),
          ),
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
        height: 200,
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
      height: 200,
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
                        'Same Destination',
                        style: TextStyle(
                          fontFamily: 'Lexend Deca',
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                // Padding(
                //   padding: const EdgeInsetsDirectional.fromSTEB(24, 0, 24, 0),
                //   child: Row(
                //     mainAxisSize: MainAxisSize.max,
                //     mainAxisAlignment: MainAxisAlignment.center,
                //     children: const [
                //       Text(
                //         'Find your fellow traveler',
                //         style: TextStyle(
                //           fontFamily: 'Lexend Deca',
                //           color: Color(0xB3FFFFFF),
                //           fontSize: 22,
                //           fontWeight: FontWeight.w300,
                //         ),
                //       ),
                //     ],
                //   ),
                // ),
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
      padding: const EdgeInsetsDirectional.fromSTEB(18, 170, 18, 0),
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
                        location();
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
                  return const AddSavedLocationScreen();
                }));
              },
              color: Colors.red,
              textColor: Colors.black,
              padding: const EdgeInsets.all(25),
              shape: const CircleBorder(),
              child: const Icon(
                Icons.add_rounded,
                size: 20,
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
                                      size: 20,
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

  test(String docID) async {
    FirebaseFirestore.instance
        .collection('journeys')
        .doc(docID)
        .collection('passenger_s')
        .get()
        .then((value) {
      value.docs.forEach((element) {
        print(element.id);
        print(element['distance']);
      });
    });
    return '5555';
  }

  journeyList() {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(10, 235, 10, 0),
      child: Container(
        //color: Color.fromARGB(255, 222, 222, 222),
        height: 180,
        width: double.infinity,
        child: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('journeys')
                //.doc(auth.currentUser!.uid)
                //.collection('saved_locations')
                .where("type", isEqualTo: "end")
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
                      height: 180,
                      child: ListView.builder(
                          scrollDirection: Axis.vertical,
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: ((context, index) {
                            return Container(
                              height: 80,
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 5),
                                child: ElevatedButton(
                                    onPressed: () {
                                      // test(snapshot.data!.docs[index]['id']
                                      //     .toString());
                                      Navigator.push(context,
                                          MaterialPageRoute(builder: (context) {
                                        return JourneyScreen(
                                          docID: snapshot
                                              .data!.docs[index]['id']
                                              .toString(),
                                        );
                                      }));
                                    },
                                    style: ButtonStyle(
                                      elevation: MaterialStateProperty.all(1),
                                      shape: MaterialStateProperty.all<
                                              RoundedRectangleBorder>(
                                          RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                              side: BorderSide(
                                                  color: Color.fromARGB(
                                                      255, 229, 229, 229)))),
                                      backgroundColor:
                                          MaterialStateProperty.all(
                                              const Color.fromARGB(
                                                  255, 255, 255, 255)),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        Text(
                                          "${snapshot.data!.docs[index]['placeName']}",
                                          style: const TextStyle(fontSize: 18),
                                        ),
                                        Text(
                                          "${snapshot.data!.docs[index]['status']}  ${snapshot.data!.docs[index]['type']}",
                                          style: const TextStyle(fontSize: 15),
                                        ),
                                        // Text(
                                        //   test(snapshot.data!.docs[index]['id']
                                        //           .toString())
                                        //       .toString(),
                                        //   style: const TextStyle(fontSize: 15),
                                        // ),
                                        Align(
                                          alignment: Alignment.bottomRight,
                                          child: Text(
                                            "${findDistance(snapshot.data!.docs[index]['endLat'], snapshot.data!.docs[index]['endLng'])}km from you.",
                                            style:
                                                const TextStyle(fontSize: 15),
                                          ),
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

  double findDistance(double lat, double lng) {
    double distance =
        Geolocator.distanceBetween(currentLat, currentLng, lat, lng);
    return double.parse((distance / 1000).toStringAsFixed(2));
  }

  double calculateDistance(lat2, lon2) {
    var lat1 = 14.889937;
    var lon1 = 102.006134;
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  oriBox() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      width: double.infinity,
      height: 100,
      //color: Colors.purple,
      child: SizedBox(
        height: 100,
        width: 150,
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return const CreateJourneyScreen();
            }));
          },
          style: ButtonStyle(
              elevation: MaterialStateProperty.all(1),
              backgroundColor: MaterialStateProperty.all(Colors.black),
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
