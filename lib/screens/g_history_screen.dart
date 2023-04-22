import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:sharing_taxi/main.dart';
import 'package:sharing_taxi/screens/a_my_bottom_appbar.dart';
import 'package:sharing_taxi/screens/a_my_drawer.dart';
import 'package:sharing_taxi/screens/d1_create_journey_screen.dart';
import 'package:sharing_taxi/screens/e_journey_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  //final auth = FirebaseAuth.instance;
  CollectionReference passengerCollection =
      FirebaseFirestore.instance.collection("passengers");
  bool showtextp = false;
  bool showtexts = false;

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

  loadData() {
    _getUserCurrentLocation().then((value) async {
      currentLat = value.latitude;
      currentLng = value.longitude;
      setState(() {});
    });
  }

  getJourneys(docID) async {
    //List<dynamic> journeyList = [];
    return await FirebaseFirestore.instance
        .collection('journeys')
        .doc(docID)
        .snapshots();
    //.get();
  }

  //bool isFree = false;
  String currentJourney = '';

  getUser() async {
    var user = await FirebaseFirestore.instance
        .collection('passengers')
        .doc(auth.currentUser!.uid)
        .get();

    currentJourney = user['currentJourney'];

    return user;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    getUser();
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    //final auth = FirebaseAuth.instance;
    return Scaffold(
        drawer: const MyDrawer(),
        appBar: AppBar(
          //automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          elevation: 1,
          title: const Text(
            "History",
            style: TextStyle(fontWeight: FontWeight.w400, fontSize: 20),
          ),
        ),
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
                      backgroundColor: Colors.deepOrange.shade400,
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
                          return JourneyScreen(docID: currentJourney);
                        }));
                      },
                      backgroundColor: Colors.deepOrange.shade400,
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
            page: 'history',
          ),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.8 -
                  MediaQuery.of(context).padding.top,
              child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('passengers')
                      .doc(auth.currentUser!.uid)
                      .collection('journey_s')
                      .orderBy('timestamp', descending: true)
                      .snapshots(),
                  builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(
                          child: CircularProgressIndicator(
                        color: Colors.black,
                      ));
                    } else if (snapshot.data!.docs.isEmpty) {
                      return Align(
                        alignment: Alignment.center,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 150),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Text(
                                "Start travel with us :)",
                                style: TextStyle(fontSize: 15),
                              ),
                              Icon(
                                Icons.trending_down,
                                size: 45,
                              )
                            ],
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      shrinkWrap: true,
                      scrollDirection: Axis.vertical,
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: ((context, index) {
                        return StreamBuilder(
                            stream: FirebaseFirestore.instance
                                .collection('journeys')
                                .doc(snapshot.data!.docs[index].id)
                                .snapshots(),
                            builder: (context, AsyncSnapshot snapdoc) {
                              if (!snapdoc.hasData) {
                                return const Center(
                                    child: CircularProgressIndicator(
                                  color: Colors.grey,
                                ));
                              }

                              if (snapdoc.data['status'] == 'success') {
                                return Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal:
                                          MediaQuery.of(context).size.width *
                                              0.04,
                                      vertical: 3),
                                  child: SizedBox(
                                    height: 90,
                                    child: ElevatedButton(
                                        onPressed: () {
                                          Navigator.push(context,
                                              MaterialPageRoute(
                                                  builder: (context) {
                                            return JourneyScreen(
                                                docID: snapshot
                                                    .data!.docs[index].id);
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
                                                          20.0),
                                                  side: const BorderSide(
                                                      width: 0.5,
                                                      color: Color.fromARGB(255,
                                                          213, 213, 213)))),
                                          backgroundColor:
                                              MaterialStateProperty.all(
                                                  const Color.fromARGB(
                                                      255, 255, 255, 255)),
                                        ),
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(left: 10.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            children: [
                                              SizedBox(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.5,
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment
                                                          .stretch,
                                                  children: [
                                                    TextField(
                                                      readOnly: true,
                                                      controller:
                                                          TextEditingController(
                                                              text: snapdoc
                                                                      .data?[
                                                                  'placeName']),
                                                      decoration:
                                                          const InputDecoration(
                                                        enabled: false,
                                                        border:
                                                            InputBorder.none,
                                                        icon: Icon(
                                                            Icons.location_pin),
                                                      ),
                                                    ),
                                                    Text(
                                                      DateFormat.yMMMd()
                                                          .add_jm()
                                                          .format((snapdoc
                                                                      .data![
                                                                  'timestamp'])
                                                              .toDate()),
                                                      style: const TextStyle(
                                                          fontSize: 13,
                                                          fontWeight:
                                                              FontWeight.w400),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.2,
                                                  child: const Text(
                                                    'Success',
                                                    style:
                                                        TextStyle(fontSize: 16),
                                                  ))
                                            ],
                                          ),
                                        )),
                                  ),
                                );
                              }

                              /////////////////////////////////

                              return Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(18, 0, 18, 3),
                                child: Column(
                                  children: [
                                    const Padding(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 10, horizontal: 10),
                                      child: Align(
                                          alignment: Alignment.topLeft,
                                          child: Text(
                                            'In progess',
                                            style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.black),
                                          )),
                                    ),
                                    SizedBox(
                                      height: 120,
                                      child: ElevatedButton(
                                          onPressed: () {
                                            Navigator.push(context,
                                                MaterialPageRoute(
                                                    builder: (context) {
                                              return JourneyScreen(
                                                  docID: snapshot
                                                      .data!.docs[index].id);
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
                                                            20.0),
                                                    side: const BorderSide(
                                                        width: 0.5,
                                                        color: Color.fromARGB(
                                                            255,
                                                            213,
                                                            213,
                                                            213)))),
                                            backgroundColor:
                                                MaterialStateProperty.all(
                                                    const Color.fromARGB(
                                                        255, 255, 255, 255)),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                left: 10.0),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
                                              children: [
                                                SizedBox(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.54,
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .stretch,
                                                    children: [
                                                      SizedBox(
                                                        height: 25,
                                                        child: Row(
                                                          children: [
                                                            const SizedBox(
                                                              width: 30,
                                                              child: Icon(
                                                                Icons
                                                                    .location_pin,
                                                                size: 24,
                                                                color: Colors
                                                                    .deepOrange,
                                                              ),
                                                            ),
                                                            Expanded(
                                                                child: Text(
                                                              " ${snapdoc.data!['placeName']}",
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
                                                      Text(
                                                        "${snapdoc.data?['endAddress']}  -  ${DateFormat.yMMMd().add_jm().format((snapshot.data!.docs[index]['timestamp']).toDate())}",
                                                        style: const TextStyle(
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w400),
                                                      ),
                                                      const SizedBox(height: 5),
                                                    ],
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: 5,
                                                ),
                                                snapdoc.data!['status'] ==
                                                        'waiting_passenger'
                                                    ? Expanded(
                                                        child: StreamBuilder(
                                                          stream: FirebaseFirestore
                                                              .instance
                                                              .collection(
                                                                  'journeys')
                                                              .doc(snapshot
                                                                  .data!
                                                                  .docs[index]
                                                                  .id)
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
                                                                color: Colors
                                                                    .greenAccent,
                                                              ));
                                                            }

                                                            return Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                TextField(
                                                                  readOnly:
                                                                      true,
                                                                  controller:
                                                                      TextEditingController(
                                                                          text:
                                                                              "${snapcol.data!.docs.length}/${snapdoc.data!['person']}"),
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
                                                                        InputBorder
                                                                            .none,
                                                                    icon: Icon(
                                                                      Icons
                                                                          .people,
                                                                      size: 20,
                                                                      color: Colors
                                                                          .orange
                                                                          .shade300,
                                                                    ),
                                                                  ),
                                                                ),
                                                                TextField(
                                                                  readOnly:
                                                                      true,
                                                                  controller:
                                                                      TextEditingController(
                                                                          text:
                                                                              "${findDistance(snapcol.data!.docs.last['startLat'] as double, snapcol.data!.docs.last['startLng'] as double)}km"),
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
                                                                        InputBorder
                                                                            .none,
                                                                    icon: Icon(
                                                                      Icons
                                                                          .my_location,
                                                                      size: 20,
                                                                      color: Colors
                                                                          .orange
                                                                          .shade300,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            );
                                                          },
                                                        ),
                                                      )
                                                    : SizedBox(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.2,
                                                        child: (snapdoc.data![
                                                                    'status'] ==
                                                                'waiting_driver')
                                                            ? const Text(
                                                                'Waiting for driver',
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        16),
                                                              )
                                                            : (snapdoc.data![
                                                                        'status'] ==
                                                                    'traveling')
                                                                ? const Text(
                                                                    'Traveling',
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            16),
                                                                  )
                                                                : Text(
                                                                    snapdoc.data![
                                                                        'status'],
                                                                    style: const TextStyle(
                                                                        fontSize:
                                                                            16),
                                                                  ),
                                                      )
                                              ],
                                            ),
                                          )),
                                    ),
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.6,
                                      child: const Divider(
                                        thickness: 2,
                                        height: 50,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            });
                      }),
                    );
                  }),
            ),
          ],
        ));
  }
}
