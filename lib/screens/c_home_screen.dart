import 'dart:convert';
import 'dart:math';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:sharing_taxi/main.dart';
import 'package:sharing_taxi/screens/d2_from_saved_journey_screen.dart';
import 'package:sharing_taxi/screens/e_journey_list_screen.dart';
import 'package:sharing_taxi/screens/f_add_saved_location_screen.dart';
import 'package:sharing_taxi/screens/d1_create_journey_screen.dart';
import 'package:sharing_taxi/screens/e_journey_screen.dart';
import 'package:sharing_taxi/screens/a_my_bottom_appbar.dart';
import 'package:sharing_taxi/screens/a_my_drawer.dart';
import 'package:sharing_taxi/screens/a_map_screen.dart';
import 'package:sharing_taxi/services/networking.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  //final auth = FirebaseAuth.instance;

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

  List<dynamic> placeList = [];
  TextEditingController address = TextEditingController();
  TextEditingController placeName = TextEditingController();
  TextEditingController detail = TextEditingController();
  myAutocomplete(place) async {
    MyAutocomplete autocomplete = MyAutocomplete(
        place: place, currentLat: currentLat, currentLng: currentLng);

    setState(() {
      placeList.clear();
    });

    try {
      // getData() returns a json Decoded data
      var data = await autocomplete.getData();

      setState(() {
        for (int i = 0; i < data['features'].length; i++) {
          placeList.add(data['features'][i]);
        }
      });
    } catch (e) {
      // ignore: avoid_print
      print(e);
    }
  }

  myLocationFromLatLng(lat, lng) async {
    MyLocationFromLatLng autocomplete =
        MyLocationFromLatLng(lat: lat, lng: lng);

    try {
      // getData() returns a json Decoded data
      var data = await autocomplete.getData();

      address.text = data['features'][0]['properties']['label'];
      placeName.text = data['features'][0]['properties']['name'];
    } catch (e) {
      // ignore: avoid_print
      print(e);
    }
  }

  loadCurrentData() {
    _getUserCurrentLocation().then((value) async {
      currentLat = value.latitude;
      currentLng = value.longitude;
      setState(() {});
    });
  }

  bool isFree = true;
  String currentJourney = '';

  getUser() async {
    var user = await FirebaseFirestore.instance
        .collection('passengers')
        .doc(auth.currentUser!.uid)
        .get();

    currentJourney = user['currentJourney'];
    isFree = user['isFree'];
    //setState(() {});

    return user;
  }

  TextEditingController textController = TextEditingController();
  List<dynamic> labelList = [];
  String tmp = '';
  final formKeys = GlobalKey<FormState>();
  final FocusNode textfieldNode = FocusNode();
  String searchtext = '';
  bool searchState = false;

  @override
  void initState() {
    // ignore: todo
    // TODO: implement initState
    super.initState();
    getUser();
    loadCurrentData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('passengers')
              .doc(auth.currentUser!.uid)
              .snapshots(),
          builder: (context, AsyncSnapshot snapdoc) {
            if (snapdoc.hasData) {
              if (snapdoc.data!['isFree']) {
                return SizedBox(
                  width: MediaQuery.of(context).size.height * 0.1,
                  height: MediaQuery.of(context).size.height * 0.1,
                  child: FloatingActionButton(
                      onPressed: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return const CreateJourneyScreen();
                        }));
                      },
                      backgroundColor: Colors.deepOrange,
                      child: Icon(
                        Icons.add,
                        size: MediaQuery.of(context).size.height * 0.05,
                        color: Colors.white,
                      )),
                );
              } else {
                return SizedBox(
                  width: MediaQuery.of(context).size.height * 0.1,
                  height: MediaQuery.of(context).size.height * 0.1,
                  child: FloatingActionButton(
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return JourneyScreen(docID: currentJourney);
                      }));
                    },
                    backgroundColor: Colors.deepOrange,
                    child: Icon(
                      Icons.directions,
                      size: MediaQuery.of(context).size.height * 0.05,
                      color: Colors.white,
                    ),
                  ),
                );
              }
            }

            return const Center(child: CircularProgressIndicator());
          }),
      bottomNavigationBar: const BottomAppBar(
        child: MyBottomAppbar(
          page: 'home',
        ),
      ),
      key: scaffoldKey,
      backgroundColor: Colors.white, //const Color.fromARGB(255, 241, 244, 248),
      drawer: const MyDrawer(),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
          textfieldNode.unfocus();
          placeList.clear();
        },
        child: SingleChildScrollView(
          child: SafeArea(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                  color: Colors.white //Color.fromARGB(255, 250, 250, 250)
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
                        //journeyList(),
                        searchState
                            ? Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    10, 258, 10, 0),
                                child: SizedBox(
                                  //color: Color.fromARGB(255, 222, 222, 222),
                                  height: 180,
                                  width: double.infinity,
                                  child: StreamBuilder(
                                      stream: FirebaseFirestore.instance
                                          .collection('journeys')
                                          .where("status",
                                              isEqualTo: "waiting_passenger")
                                          .orderBy('placeName')
                                          .startAt([
                                        searchtext,
                                      ]).snapshots(),
                                      builder: (context,
                                          AsyncSnapshot<QuerySnapshot>
                                              snapshot) {
                                        if (!snapshot.hasData) {
                                          return const Center(
                                              child: CircularProgressIndicator(
                                            color: Colors.grey,
                                          ));
                                        } else if (snapshot
                                            .data!.docs.isEmpty) {
                                          return Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      20, 0, 20, 0),
                                              child: Container(
                                                  color: Colors.white,
                                                  height: 180,
                                                  child: const SizedBox(
                                                      height: 80,
                                                      child: Align(
                                                        alignment:
                                                            Alignment.center,
                                                        child: Text(
                                                          "We didn't find any journey.\nPlease try another name.",
                                                          style: TextStyle(
                                                              fontSize: 15),
                                                        ),
                                                      ))));
                                        }

                                        return Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                17, 0, 17, 0),
                                            child: Container(
                                              color: Colors.white,
                                              height: 180,
                                              child: ListView.builder(
                                                  scrollDirection:
                                                      Axis.vertical,
                                                  itemCount: snapshot
                                                      .data!.docs.length,
                                                  itemBuilder:
                                                      ((context, index) {
                                                    return StreamBuilder(
                                                        stream: FirebaseFirestore
                                                            .instance
                                                            .collection(
                                                                'journeys')
                                                            .doc(snapshot.data!
                                                                .docs[index].id)
                                                            .collection(
                                                                'passenger_s')
                                                            .snapshots(),
                                                        builder: (context,
                                                            AsyncSnapshot<
                                                                    QuerySnapshot>
                                                                snapcol) {
                                                          if (!snapcol
                                                              .hasData) {
                                                            return const Center(
                                                                child:
                                                                    CircularProgressIndicator(
                                                              color:
                                                                  Colors.grey,
                                                            ));
                                                          }

                                                          return SizedBox(
                                                            height: 85,
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .only(
                                                                      bottom:
                                                                          5),
                                                              child:
                                                                  ElevatedButton(
                                                                      onPressed:
                                                                          () {
                                                                        Navigator.push(
                                                                            context,
                                                                            MaterialPageRoute(builder:
                                                                                (context) {
                                                                          return JourneyScreen(
                                                                            docID:
                                                                                snapshot.data!.docs[index]['id'].toString(),
                                                                          );
                                                                        }));
                                                                      },
                                                                      style:
                                                                          ButtonStyle(
                                                                        elevation:
                                                                            MaterialStateProperty.all(1),
                                                                        shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(
                                                                            borderRadius:
                                                                                BorderRadius.circular(12.0),
                                                                            side: const BorderSide(color: Color.fromARGB(255, 229, 229, 229)))),
                                                                        backgroundColor: MaterialStateProperty.all(const Color.fromARGB(
                                                                            255,
                                                                            255,
                                                                            255,
                                                                            255)),
                                                                      ),
                                                                      child:
                                                                          Padding(
                                                                        padding:
                                                                            const EdgeInsets.symmetric(vertical: 8.0),
                                                                        child:
                                                                            Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.spaceBetween,
                                                                          children: [
                                                                            Container(
                                                                              color: Colors.white,
                                                                              width: MediaQuery.of(context).size.width * 0.52,
                                                                              child: Column(
                                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                                                                children: [
                                                                                  SizedBox(
                                                                                    height: 30,
                                                                                    child: Row(
                                                                                      children: [
                                                                                        const SizedBox(
                                                                                          width: 25,
                                                                                          child: Icon(
                                                                                            Icons.location_pin,
                                                                                            size: 24,
                                                                                            color: Colors.deepOrangeAccent,
                                                                                          ),
                                                                                        ),
                                                                                        Expanded(
                                                                                            child: Text(
                                                                                          " ${snapshot.data!.docs[index]['placeName']}",
                                                                                          maxLines: 1,
                                                                                          overflow: TextOverflow.ellipsis,
                                                                                          style: const TextStyle(fontSize: 16),
                                                                                        ))
                                                                                      ],
                                                                                    ),
                                                                                  ),
                                                                                  Row(
                                                                                    children: [
                                                                                      const SizedBox(
                                                                                        width: 25,
                                                                                      ),
                                                                                      Text(
                                                                                        "  ${DateFormat.yMMMd().add_jm().format((snapshot.data!.docs[index]['timestamp']).toDate())}",
                                                                                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                            Expanded(
                                                                              child: TextField(
                                                                                readOnly: true,
                                                                                controller: TextEditingController(text: "${snapcol.data!.docs.length}/${snapshot.data!.docs[index]['person']}"),
                                                                                style: const TextStyle(fontSize: 17),
                                                                                decoration: const InputDecoration(
                                                                                  isDense: true,
                                                                                  enabled: false,
                                                                                  border: InputBorder.none,
                                                                                  icon: Icon(
                                                                                    Icons.people,
                                                                                    size: 24,
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      )),
                                                            ),
                                                          );
                                                        });
                                                  })),
                                            ));
                                      }),
                                ),
                              )
                            : journeyList(),
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              18, 200, 18, 0),
                          child: SizedBox(
                            height: 250,
                            child: Stack(
                              children: [
                                Container(
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
                                        offset: const Offset(
                                            0, 3), // changes position of shadow
                                      ),
                                    ],
                                  ),
                                  alignment: const AlignmentDirectional(0, 0),
                                  child: Row(
                                    //mainAxisAlignment: MainAxisAlignment.end,
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsetsDirectional
                                              .fromSTEB(4, 0, 4, 0),
                                          child: SizedBox(
                                            child: TextFormField(
                                              focusNode: textfieldNode,
                                              controller: textController,
                                              onChanged: (value) async {
                                                await myAutocomplete(value);
                                              },
                                              onTap: () async {
                                                if (textController.text != '') {
                                                  await myAutocomplete(
                                                      textController.text);
                                                }
                                              },
                                              obscureText: false,
                                              decoration: InputDecoration(
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                  borderSide: const BorderSide(
                                                    color: Colors.white,
                                                    width: 0.5,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderSide: const BorderSide(
                                                    color: Colors.white,
                                                    width: 2,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
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
                                                fontSize: 17,
                                                fontWeight: FontWeight.normal,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      (textController.text.isEmpty ||
                                              textController.text == '')
                                          ? const SizedBox(
                                              width: 0,
                                              height: 0,
                                            )
                                          : Padding(
                                              padding:
                                                  const EdgeInsetsDirectional
                                                      .fromSTEB(0, 4, 8, 0),
                                              child: SizedBox(
                                                width: 30,
                                                height: 40,
                                                child: IconButton(
                                                  icon: const Icon(
                                                    Icons.close,
                                                    size: 20,
                                                  ),
                                                  onPressed: () async {
                                                    setState(() {
                                                      textController.text = '';
                                                      searchState = false;
                                                      placeList.clear();
                                                      setState(() {});
                                                    });
                                                  },
                                                ),
                                              ),
                                            ),
                                      Padding(
                                        padding: const EdgeInsetsDirectional
                                            .fromSTEB(0, 4, 8, 0),
                                        child: ElevatedButton(
                                          onPressed: () async {
                                            placeList.clear();
                                            if (textController
                                                .text.isNotEmpty) {
                                              setState(() {
                                                searchState = true;
                                                searchtext =
                                                    textController.text;
                                              });
                                            } else {
                                              setState(() {
                                                searchState = false;
                                                searchtext = '';
                                              });
                                            }
                                          },
                                          style: ElevatedButton.styleFrom(
                                            primary: Colors.deepOrange.shade400,
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
                                    ],
                                  ),
                                ),
                                placeList.isNotEmpty
                                    ? Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            20, 70, 20, 0),
                                        child: SizedBox(
                                          width: double.infinity,
                                          height: 220,
                                          child: ListView.builder(
                                              itemCount: placeList.length,
                                              itemBuilder: ((context, index) {
                                                return Column(
                                                  children: [
                                                    Container(
                                                      decoration: BoxDecoration(
                                                        border: const Border(),
                                                        color: Colors.white,
                                                        //borderRadius: BorderRadius.circular(5),
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: Colors.grey
                                                                .withOpacity(
                                                                    0.5),
                                                            spreadRadius: 1,
                                                            blurRadius: 7,
                                                            offset: const Offset(
                                                                0,
                                                                3), // changes position of shadow
                                                          ),
                                                        ],
                                                      ),
                                                      child: ListTile(
                                                        onTap: () async {
                                                          FocusScope.of(context)
                                                              .unfocus();

                                                          setState(() {
                                                            textController
                                                                .text = placeList[
                                                                        index][
                                                                    'properties']
                                                                ['name'];
                                                            placeList.clear();
                                                          });
                                                        },
                                                        leading: const Icon(
                                                            Icons
                                                                .location_city),
                                                        title: Text(placeList[
                                                                    index]
                                                                ['properties']
                                                            ['name']),
                                                        subtitle: Text(placeList[
                                                                    index]
                                                                ['properties']
                                                            ['label']),
                                                      ),
                                                    ),
                                                    const Divider(
                                                      height: 0.5,
                                                      thickness: 1,
                                                    ),
                                                  ],
                                                );
                                              })),
                                        ),
                                      )
                                    : const SizedBox(
                                        width: 0,
                                        height: 0,
                                      ),
                              ],
                            ),
                          ),
                        ),
                        topMenu(),
                      ],
                    ),
                    InkWell(
                      child: Padding(
                        padding: EdgeInsets.only(
                            left: MediaQuery.of(context).size.width * 0.65),
                        child: const Text('See all journey >>'),
                      ),
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return const JourneyListScreen();
                        }));
                      },
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Stack(
                      children: [
                        savedLocationMenu(),
                        addLocationMenu(),
                      ],
                    ),
                    const SizedBox(
                      height: 100,
                    )
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
                style: TextStyle(color: Colors.white),
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
              'assets/taxi-orange.jpg',
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

  addLocationMenu() {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(20, 10, 20, 0),
      child: Container(
        color: Colors.white,
        //height: 200,
        child: Column(
          children: [
            MaterialButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return const AddSavedLocationScreen();
                }));
              },
              color: Colors.grey.shade800,
              textColor: Colors.white,
              padding: const EdgeInsets.all(20),
              shape: const CircleBorder(),
              child: const Icon(
                Icons.add_location_outlined,
                size: 30,
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
    //final auth = FirebaseAuth.instance;
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(10, 0, 0, 0),
      child: Container(
        color: Colors.white,
        height: 130,
        width: double.infinity,
        child: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('passengers')
                .doc(auth.currentUser!.uid)
                .collection('saved_locations')
                .orderBy('timestamp', descending: true)
                //.where("email", isEqualTo: "${auth.currentUser!.email}")
                .snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              return Padding(
                  padding: const EdgeInsets.fromLTRB(110, 10, 30, 0),
                  child: SizedBox(
                    height: 200,
                    child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: ((context, index) {
                          return SingleChildScrollView(
                            child: Container(
                              // padding: const EdgeInsets.only(right: 10),
                              margin : const EdgeInsets.symmetric(horizontal : 5),
                              child: SizedBox(
                                width: 85,
                                child: Column(
                                  children: [
                                    MaterialButton(
                                      onPressed: () {
                                        if (isFree == false) {
                                          Fluttertoast.showToast(
                                              msg:
                                                  "You are currently in the journey.",
                                              timeInSecForIosWeb: 7,
                                              gravity: ToastGravity.BOTTOM);
                                        } else {
                                          Navigator.push(context,
                                              MaterialPageRoute(
                                                  builder: (context) {
                                            return FromSavedJourneyScreen(
                                                endLat:
                                                    snapshot.data!.docs[index]
                                                        ['latitude'] as double,
                                                endLng:
                                                    snapshot.data!.docs[index]
                                                        ['longitude'] as double,
                                                endAddress: snapshot.data!
                                                    .docs[index]['address'],
                                                placeName: snapshot.data!
                                                    .docs[index]['placeName'],
                                                detail: snapshot.data!
                                                    .docs[index]['detail']);
                                          }));
                                        }
                                      },
                                      color: Colors.orange.shade200,
                                      textColor: Colors.grey.shade900,
                                      padding: const EdgeInsets.all(25),
                                      shape: const CircleBorder(),
                                      child: const Icon(
                                        Icons.favorite,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Text(
                                      snapshot.data!.docs[index]['placeName']
                                          .toString(),
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(fontSize: 15),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        })),
                  ));
            }),
      ),
    );
  }

  journeyList() {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(10, 258, 10, 0),
      child: SizedBox(
        height: 180,
        width: double.infinity,
        child: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('journeys')
                .where("status", isEqualTo: "waiting_passenger")
                .snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.data!.docs.isEmpty) {
                return Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                    child: Container(
                        color: Colors.white,
                        height: 180,
                        child: const SizedBox(
                            height: 80,
                            child: Align(
                              alignment: Alignment.center,
                              child: Text(
                                "We don't have any journey rigth now :(",
                                style: TextStyle(fontSize: 15),
                              ),
                            ))));
              }

              return Padding(
                  padding: const EdgeInsets.fromLTRB(17, 0, 17, 0),
                  child: Container(
                    color: Colors.white,
                    height: 180,
                    child: ListView.builder(
                        scrollDirection: Axis.vertical,
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: ((context, index) {
                          return StreamBuilder(
                              stream: FirebaseFirestore.instance
                                  .collection('journeys')
                                  .doc(snapshot.data!.docs[index].id)
                                  .collection('passenger_s')
                                  .snapshots(),
                              builder: (context,
                                  AsyncSnapshot<QuerySnapshot> snapcol) {
                                if (!snapcol.hasData) {
                                  return const Center(
                                      child: CircularProgressIndicator(
                                    color: Colors.pinkAccent,
                                  ));
                                }

                                return SizedBox(
                                  height: 85,
                                  child: Padding(
                                    padding: const EdgeInsets.only(bottom: 5),
                                    child: ElevatedButton(
                                        onPressed: () {
                                          Navigator.push(context,
                                              MaterialPageRoute(
                                                  builder: (context) {
                                            return JourneyScreen(
                                              docID: snapshot
                                                  .data!.docs[index]['id']
                                                  .toString(),
                                            );
                                          }));
                                        },
                                        style: ButtonStyle(
                                          elevation:
                                              MaterialStateProperty.all(1),
                                          shape: MaterialStateProperty.all<
                                                  RoundedRectangleBorder>(
                                              RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          12.0),
                                                  side: const BorderSide(
                                                      color: Color.fromARGB(255,
                                                          229, 229, 229)))),
                                          backgroundColor:
                                              MaterialStateProperty.all(
                                                  const Color.fromARGB(
                                                      255, 255, 255, 255)),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 8.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Container(
                                                color: Colors.white,
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.52,
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment
                                                          .stretch,
                                                  children: [
                                                    SizedBox(
                                                      height: 30,
                                                      child: Row(
                                                        children: [
                                                          const SizedBox(
                                                            width: 25,
                                                            child: Icon(
                                                              Icons
                                                                  .location_pin,
                                                              size: 24,
                                                              color: Colors
                                                                  .deepOrangeAccent,
                                                            ),
                                                          ),
                                                          Expanded(
                                                              child: Text(
                                                            " ${snapshot.data!.docs[index]['placeName']}",
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style:
                                                                const TextStyle(
                                                                    fontSize:
                                                                        16),
                                                          ))
                                                        ],
                                                      ),
                                                    ),
                                                    Row(
                                                      children: [
                                                        const SizedBox(
                                                          width: 25,
                                                        ),
                                                        Text(
                                                          "  ${DateFormat.yMMMd().add_jm().format((snapshot.data!.docs[index]['timestamp']).toDate())}",
                                                          style: const TextStyle(
                                                              fontSize: 13,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Expanded(
                                                child: TextField(
                                                  readOnly: true,
                                                  controller: TextEditingController(
                                                      text:
                                                          "${snapcol.data!.docs.length}/${snapshot.data!.docs[index]['person']}"),
                                                  style: const TextStyle(
                                                      fontSize: 17),
                                                  decoration:
                                                      const InputDecoration(
                                                    isDense: true,
                                                    enabled: false,
                                                    border: InputBorder.none,
                                                    icon: Icon(
                                                      Icons.people,
                                                      size: 24,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        )),
                                  ),
                                );
                              });
                        })),
                  ));
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
}
