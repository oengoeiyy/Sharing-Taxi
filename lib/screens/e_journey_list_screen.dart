import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:sharing_taxi/main.dart';
import 'package:sharing_taxi/screens/a_my_bottom_appbar.dart';
import 'package:sharing_taxi/screens/a_my_drawer.dart';
import 'package:sharing_taxi/screens/d1_create_journey_screen.dart';
import 'package:sharing_taxi/screens/d2_from_saved_journey_screen.dart';
import 'package:sharing_taxi/screens/e_journey_screen.dart';
import 'package:sharing_taxi/screens/f_add_saved_location_screen.dart';
import 'package:sharing_taxi/screens/f_edit_saved_location_screen.dart';
import 'package:sharing_taxi/services/networking.dart';

class JourneyListScreen extends StatefulWidget {
  const JourneyListScreen({Key? key}) : super(key: key);

  @override
  State<JourneyListScreen> createState() => _JourneyListScreenState();
}

class _JourneyListScreenState extends State<JourneyListScreen> {
  // final auth = FirebaseAuth.instance;
  CollectionReference passengerCollection =
      FirebaseFirestore.instance.collection("passengers");

  bool isDelete = false;

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

  double findDistance(double lat, double lng) {
    double distance =
        Geolocator.distanceBetween(currentLat, currentLng, lat, lng);
    return double.parse((distance / 1000).toStringAsFixed(2));
  }

  List<dynamic> placeList = [];
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

  loadData() {
    _getUserCurrentLocation().then((value) async {
      currentLat = value.latitude;
      currentLng = value.longitude;
      setState(() {});
    });
  }

  String currentJourney = '';

  getUser() async {
    var user = await FirebaseFirestore.instance
        .collection('passengers')
        .doc(auth.currentUser!.uid)
        .get();

    currentJourney = user['currentJourney'];

    return user;
  }

  TextEditingController textController = TextEditingController();
  final FocusNode textfieldNode = FocusNode();
  String searchtext = '';
  bool searchState = false;

  @override
  void initState() {
    // ignore: todo
    // TODO: implement initState
    super.initState();
    //getUser();
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        textfieldNode.unfocus();
        placeList.clear();
      },
      child: Scaffold(
          appBar: AppBar(
            //automaticallyImplyLeading: false,
            backgroundColor: Colors.white,
            elevation: 1,
            title: const Text(
              "Journey List",
              style: TextStyle(fontWeight: FontWeight.w400, fontSize: 20),
            ),
          ),
          drawer: const MyDrawer(),
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
                        ),
                      ),
                    );
                  } else {
                    return SizedBox(
                      width: MediaQuery.of(context).size.height * 0.1,
                      height: MediaQuery.of(context).size.height * 0.1,
                      child: FloatingActionButton(
                        onPressed: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return JourneyScreen(
                                docID: snapdoc.data!['currentJourney']);
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
            //color: Colors.pink,
            child: MyBottomAppbar(
              page: 'journey',
            ),
          ),
          body: Stack(
            children: [
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                    child: Container(
                      width: double.infinity,
                      height: 50,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey)),
                      alignment: const AlignmentDirectional(0, 0),
                      child: Row(
                        //mainAxisAlignment: MainAxisAlignment.end,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  4, 0, 4, 0),
                              child: SizedBox(
                                child: TextFormField(
                                  focusNode: textfieldNode,
                                  controller: textController,
                                  onChanged: (value) async {
                                    await myAutocomplete(value);
                                  },
                                  onTap: () {
                                    if (textController.text != '') {
                                      myAutocomplete(textController.text);
                                    }
                                  },
                                  obscureText: false,
                                  decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.symmetric(
                                        vertical: 10),
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
                                    fontSize: 17,
                                    //fontWeight: FontWeight.normal,
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
                                  padding: const EdgeInsetsDirectional.fromSTEB(
                                      0, 4, 8, 0),
                                  child: SizedBox(
                                    width: 30,
                                    height: 40,
                                    child: IconButton(
                                      icon: const Icon(
                                        Icons.cancel_outlined,
                                        size: 20,
                                        color: Colors.grey,
                                      ),
                                      onPressed: () async {
                                        setState(() {
                                          textController.text = '';
                                          searchState = false;
                                          setState(() {});
                                        });
                                      },
                                    ),
                                  ),
                                ),
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                0, 6, 8, 6),
                            child: ElevatedButton(
                              onPressed: () async {
                                if (textController.text.isNotEmpty) {
                                  setState(() {
                                    searchState = true;
                                    searchtext = textController.text;
                                  });
                                } else {
                                  setState(() {
                                    searchState = false;
                                    searchtext = '';
                                  });
                                }
                              },
                              style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                          Colors.orange),
                                  shape: MaterialStateProperty.all<
                                          RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(18.0),
                                          side: const BorderSide(
                                              color: Colors.orange)))),
                              child: const Text(
                                "Search",
                                style: TextStyle(
                                  fontFamily: 'Lexend Deca',
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  searchState
                      ? Expanded(
                          child: Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                0, 10, 0, 0),
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
                                    AsyncSnapshot<QuerySnapshot> snapshot) {
                                  if (!snapshot.hasData) {
                                    return const Center(
                                        child: CircularProgressIndicator());
                                  } else if (snapshot.data!.docs.isEmpty) {
                                    return const Align(
                                      alignment: Alignment.center,
                                      child: Text(
                                        "We didn't find any journey.\nPlease try another name.",
                                        style: TextStyle(fontSize: 15),
                                      ),
                                    );
                                  }

                                  return Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          20, 0, 20, 0),
                                      child: ListView.builder(
                                          scrollDirection: Axis.vertical,
                                          itemCount: snapshot.data!.docs.length,
                                          itemBuilder: ((context, index) {
                                            return StreamBuilder(
                                                stream: FirebaseFirestore
                                                    .instance
                                                    .collection('journeys')
                                                    .doc(snapshot
                                                        .data!.docs[index].id)
                                                    .collection('passenger_s')
                                                    .orderBy('distance')
                                                    .snapshots(),
                                                builder: (context,
                                                    AsyncSnapshot<QuerySnapshot>
                                                        snapcol) {
                                                  if (!snapcol.hasData) {
                                                    return const Center(
                                                        child:
                                                            CircularProgressIndicator(
                                                      color: Colors.pinkAccent,
                                                    ));
                                                  }

                                                  return SizedBox(
                                                    height: 120,
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              bottom: 5),
                                                      child: ElevatedButton(
                                                          onPressed: () {
                                                            Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                    builder:
                                                                        (context) {
                                                              return JourneyScreen(
                                                                docID: snapshot
                                                                    .data!
                                                                    .docs[index]
                                                                        ['id']
                                                                    .toString(),
                                                              );
                                                            }));
                                                          },
                                                          style: ButtonStyle(
                                                            elevation:
                                                                MaterialStateProperty
                                                                    .all(1),
                                                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            20.0),
                                                                side: const BorderSide(
                                                                    width: 0.5,
                                                                    color: Color
                                                                        .fromARGB(
                                                                            255,
                                                                            213,
                                                                            213,
                                                                            213)))),
                                                            backgroundColor:
                                                                MaterialStateProperty
                                                                    .all(const Color
                                                                            .fromARGB(
                                                                        255,
                                                                        255,
                                                                        255,
                                                                        255)),
                                                          ),
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .symmetric(
                                                                    vertical:
                                                                        8.0),
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceEvenly,
                                                              children: [
                                                                const SizedBox(
                                                                  width: 5,
                                                                ),
                                                                SizedBox(
                                                                  width: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width *
                                                                      0.52,
                                                                  child: Column(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .center,
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .stretch,
                                                                    children: [
                                                                      const SizedBox(
                                                                        width:
                                                                            5,
                                                                      ),
                                                                      SizedBox(
                                                                        height:
                                                                            25,
                                                                        child:
                                                                            Row(
                                                                          children: [
                                                                            const SizedBox(
                                                                              width: 30,
                                                                              child: Icon(
                                                                                Icons.location_pin,
                                                                                size: 24,
                                                                                color: Colors.deepOrange,
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
                                                                      // const SizedBox(
                                                                      //     height:
                                                                      //         5),
                                                                      Text(
                                                                        "${snapshot.data!.docs[index]['endAddress']}  -  ${DateFormat.yMMMd().add_jm().format((snapshot.data!.docs[index]['timestamp']).toDate())}",
                                                                        style: const TextStyle(
                                                                            fontSize:
                                                                                12,
                                                                            fontWeight:
                                                                                FontWeight.w400),
                                                                      ),
                                                                      const SizedBox(
                                                                          height:
                                                                              5),
                                                                      // Text(
                                                                      //   "You're ${findDistance(snapcol.data!.docs.last['startLat'] as double, snapcol.data!.docs.last['startLng'] as double)}km far from first passenger",
                                                                      //   style: const TextStyle(
                                                                      //       fontSize:
                                                                      //           12,
                                                                      //       fontWeight:
                                                                      //           FontWeight.w400),
                                                                      // ),
                                                                    ],
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                  width: 5,
                                                                ),
                                                                Expanded(
                                                                  child: Column(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .center,
                                                                    children: [
                                                                      TextField(
                                                                        readOnly:
                                                                            true,
                                                                        controller:
                                                                            TextEditingController(text: "${snapcol.data!.docs.length}/${snapshot.data!.docs[index]['person']}"),
                                                                        style: const TextStyle(
                                                                            fontSize:
                                                                                15),
                                                                        decoration:
                                                                            InputDecoration(
                                                                          isDense:
                                                                              true,
                                                                          enabled:
                                                                              false,
                                                                          border:
                                                                              InputBorder.none,
                                                                          icon:
                                                                              Icon(
                                                                            Icons.people,
                                                                            size:
                                                                                20,
                                                                            color:
                                                                                Colors.orange.shade300,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      TextField(
                                                                        readOnly:
                                                                            true,
                                                                        controller:
                                                                            TextEditingController(text: "${findDistance(snapcol.data!.docs.last['startLat'] as double, snapcol.data!.docs.last['startLng'] as double)}km"),
                                                                        style: const TextStyle(
                                                                            fontSize:
                                                                                15),
                                                                        decoration:
                                                                            InputDecoration(
                                                                          isDense:
                                                                              true,
                                                                          enabled:
                                                                              false,
                                                                          border:
                                                                              InputBorder.none,
                                                                          icon:
                                                                              Icon(
                                                                            Icons.my_location,
                                                                            size:
                                                                                20,
                                                                            color:
                                                                                Colors.orange.shade300,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  // child: Align(
                                                                  //   alignment:
                                                                  //       Alignment.bottomRight,
                                                                  //   child: Text(
                                                                  //     "${findDistance(snapshot.data!.docs[index]['endLat'], snapshot.data!.docs[index]['endLng'])}km from you.",
                                                                  //     style: const TextStyle(
                                                                  //         fontSize: 13,
                                                                  //         fontWeight:
                                                                  //             FontWeight.w400),
                                                                  //   ),
                                                                  // ),
                                                                ),
                                                              ],
                                                            ),
                                                          )),
                                                    ),
                                                  );
                                                });
                                          })));
                                }),
                          ),
                        )
                      : Expanded(
                          child: Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                0, 10, 0, 0),
                            child: StreamBuilder(
                                stream: FirebaseFirestore.instance
                                    .collection('journeys')
                                    .where("status",
                                        isEqualTo: "waiting_passenger")
                                    .snapshots(),
                                builder: (context,
                                    AsyncSnapshot<QuerySnapshot> snapshot) {
                                  if (!snapshot.hasData) {
                                    return const Center(
                                        child: CircularProgressIndicator());
                                  } else if (snapshot.data!.docs.isEmpty) {
                                    return const Align(
                                      alignment: Alignment.center,
                                      child: Text(
                                        "We don't have any journey rigth now :(",
                                        style: TextStyle(fontSize: 15),
                                      ),
                                    );
                                  }

                                  return Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          20, 0, 20, 0),
                                      child: ListView.builder(
                                          scrollDirection: Axis.vertical,
                                          itemCount: snapshot.data!.docs.length,
                                          itemBuilder: ((context, index) {
                                            return StreamBuilder(
                                                stream: FirebaseFirestore
                                                    .instance
                                                    .collection('journeys')
                                                    .doc(snapshot
                                                        .data!.docs[index].id)
                                                    .collection('passenger_s')
                                                    .orderBy('distance')
                                                    .snapshots(),
                                                builder: (context,
                                                    AsyncSnapshot<QuerySnapshot>
                                                        snapcol) {
                                                  if (!snapcol.hasData) {
                                                    return const Center(
                                                        child:
                                                            CircularProgressIndicator(
                                                      color: Colors.pinkAccent,
                                                    ));
                                                  }

                                                  return SizedBox(
                                                    height: 120,
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              bottom: 5),
                                                      child: ElevatedButton(
                                                          onPressed: () {
                                                            Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                    builder:
                                                                        (context) {
                                                              return JourneyScreen(
                                                                docID: snapshot
                                                                    .data!
                                                                    .docs[index]
                                                                        ['id']
                                                                    .toString(),
                                                              );
                                                            }));
                                                          },
                                                          style: ButtonStyle(
                                                            elevation:
                                                                MaterialStateProperty
                                                                    .all(1),
                                                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            20.0),
                                                                side: const BorderSide(
                                                                    width: 0.5,
                                                                    color: Color
                                                                        .fromARGB(
                                                                            255,
                                                                            213,
                                                                            213,
                                                                            213)))),
                                                            backgroundColor:
                                                                MaterialStateProperty
                                                                    .all(const Color
                                                                            .fromARGB(
                                                                        255,
                                                                        255,
                                                                        255,
                                                                        255)),
                                                          ),
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .symmetric(
                                                                    vertical:
                                                                        8.0),
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceEvenly,
                                                              children: [
                                                                const SizedBox(
                                                                  width: 5,
                                                                ),
                                                                SizedBox(
                                                                  width: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width *
                                                                      0.52,
                                                                  child: Column(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .center,
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .stretch,
                                                                    children: [
                                                                      const SizedBox(
                                                                        width:
                                                                            5,
                                                                      ),
                                                                      SizedBox(
                                                                        height:
                                                                            25,
                                                                        child:
                                                                            Row(
                                                                          children: [
                                                                            const SizedBox(
                                                                              width: 30,
                                                                              child: Icon(
                                                                                Icons.location_pin,
                                                                                size: 24,
                                                                                color: Colors.deepOrange,
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
                                                                      // const SizedBox(
                                                                      //     height:
                                                                      //         5),
                                                                      Text(
                                                                        "${snapshot.data!.docs[index]['endAddress']}  -  ${DateFormat.yMMMd().add_jm().format((snapshot.data!.docs[index]['timestamp']).toDate())}",
                                                                        style: const TextStyle(
                                                                            fontSize:
                                                                                12,
                                                                            fontWeight:
                                                                                FontWeight.w400),
                                                                      ),
                                                                      const SizedBox(
                                                                          height:
                                                                              5),
                                                                      // Text(
                                                                      //   "You're ${findDistance(snapcol.data!.docs.last['startLat'] as double, snapcol.data!.docs.last['startLng'] as double)}km far from first passenger",
                                                                      //   style: const TextStyle(
                                                                      //       fontSize:
                                                                      //           12,
                                                                      //       fontWeight:
                                                                      //           FontWeight.w400),
                                                                      // ),
                                                                    ],
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                  width: 5,
                                                                ),
                                                                Expanded(
                                                                  child: Column(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .center,
                                                                    children: [
                                                                      TextField(
                                                                        readOnly:
                                                                            true,
                                                                        controller:
                                                                            TextEditingController(text: "${snapcol.data!.docs.length}/${snapshot.data!.docs[index]['person']}"),
                                                                        style: const TextStyle(
                                                                            fontSize:
                                                                                15),
                                                                        decoration:
                                                                            InputDecoration(
                                                                          isDense:
                                                                              true,
                                                                          enabled:
                                                                              false,
                                                                          border:
                                                                              InputBorder.none,
                                                                          icon:
                                                                              Icon(
                                                                            Icons.people,
                                                                            size:
                                                                                20,
                                                                            color:
                                                                                Colors.orange.shade300,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      TextField(
                                                                        readOnly:
                                                                            true,
                                                                        controller:
                                                                            TextEditingController(text: "${findDistance(snapcol.data!.docs.last['startLat'] as double, snapcol.data!.docs.last['startLng'] as double)}km"),
                                                                        style: const TextStyle(
                                                                            fontSize:
                                                                                15),
                                                                        decoration:
                                                                            InputDecoration(
                                                                          isDense:
                                                                              true,
                                                                          enabled:
                                                                              false,
                                                                          border:
                                                                              InputBorder.none,
                                                                          icon:
                                                                              Icon(
                                                                            Icons.my_location,
                                                                            size:
                                                                                20,
                                                                            color:
                                                                                Colors.orange.shade300,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  // child: Align(
                                                                  //   alignment:
                                                                  //       Alignment.bottomRight,
                                                                  //   child: Text(
                                                                  //     "${findDistance(snapshot.data!.docs[index]['endLat'], snapshot.data!.docs[index]['endLng'])}km from you.",
                                                                  //     style: const TextStyle(
                                                                  //         fontSize: 13,
                                                                  //         fontWeight:
                                                                  //             FontWeight.w400),
                                                                  //   ),
                                                                  // ),
                                                                ),
                                                              ],
                                                            ),
                                                          )),
                                                    ),
                                                  );
                                                });
                                          })));
                                }),
                          ),
                        ),
                ],
              ),
              placeList.isNotEmpty
                  ? Padding(
                      padding: const EdgeInsets.fromLTRB(40, 70, 40, 0),
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
                                          color: Colors.grey.withOpacity(0.5),
                                          spreadRadius: 1,
                                          blurRadius: 7,
                                          offset: const Offset(0,
                                              3), // changes position of shadow
                                        ),
                                      ],
                                    ),
                                    child: ListTile(
                                      onTap: () async {
                                        FocusScope.of(context).unfocus();

                                        setState(() {
                                          textController.text = placeList[index]
                                              ['properties']['name'];
                                          placeList.clear();
                                        });
                                      },
                                      leading: const Icon(Icons.location_city),
                                      title: Text(placeList[index]['properties']
                                          ['name']),
                                      subtitle: Text(placeList[index]
                                          ['properties']['label']),
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
          )),
    );
  }
}
