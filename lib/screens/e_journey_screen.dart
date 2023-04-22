import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:sharing_taxi/main.dart';
import 'package:sharing_taxi/models/journey.dart';
import 'package:sharing_taxi/screens/c_home_screen.dart';
import 'package:sharing_taxi/screens/a_my_bottom_appbar.dart';
import 'package:sharing_taxi/screens/g_history_screen.dart';
import 'package:sharing_taxi/services/networking.dart';

class LineString {
  LineString(this.lineString);
  List<dynamic> lineString;
}

class JourneyScreen extends StatefulWidget {
  String? docID;
  JourneyScreen({
    Key? key,
    @required this.docID,
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _JourneyScreenState createState() => _JourneyScreenState();
}

class _JourneyScreenState extends State<JourneyScreen> {
  //final auth = FirebaseAuth.instance;
  final docID = JourneyScreen().docID;
  String address = '';
  final Completer<GoogleMapController> _controller = Completer();
  final Set<Marker> _markers = {};
  Journey journey = Journey();

  bool startState = true;
  bool isDelete = false;

  List<dynamic> colorList = [Colors.orange, Colors.yellow, Colors.greenAccent];
  List<dynamic> pinColor = [
    BitmapDescriptor.hueOrange,
    BitmapDescriptor.hueYellow,
    BitmapDescriptor.hueGreen
  ];

  final formKey = GlobalKey<FormState>();
  TextEditingController startAddress = TextEditingController();
  TextEditingController detail = TextEditingController();
  TextEditingController distancetext = TextEditingController();
  TextEditingController costText = TextEditingController();

  final CameraPosition _kGooglePlex = const CameraPosition(
    target: LatLng(0, 0),
    zoom: 12,
  );

  CollectionReference journeysCollection =
      FirebaseFirestore.instance.collection("journeys");
  CollectionReference passengersCollection =
      FirebaseFirestore.instance.collection("passengers");
  CollectionReference journeysByIDCollection = FirebaseFirestore.instance
      .collection('journeys')
      .doc(JourneyScreen().docID)
      .collection('passenger_s');

  double endLat = 0;
  double endLng = 0;
  double firstLat = 0;
  double firstLng = 0;
  double sumLat = 0;
  double sumLng = 0;
  int count = 0;
  double currentLat = 0;
  double currentLng = 0;
  bool isX = false;

  Future<Position> _getUserCurrentLocation() async {
    await Geolocator.requestPermission()
        .then((value) {})
        .onError((error, stackTrace) {
      // ignore: avoid_print
      print(error.toString());
    });

    return await Geolocator.getCurrentPosition();
  }

  loadCurrentLocation() {
    _getUserCurrentLocation().then((value) async {
      currentLat = value.latitude;
      currentLng = value.longitude;
      setState(() {});
    });
  }

  bool isFree = false;
  int person = 0;
  String? creator = '';
  String? status = '';
  String? driver = '';

  getJourney() async {
    var journey = await FirebaseFirestore.instance
        .collection('journeys')
        .doc(widget.docID)
        .get();

    person = journey['person'];
    creator = journey['creator'];

    driver = journey['driver'] ?? " ";

    //return journey;
  }

  getJourneyStatus() async {
    var journeystatus = await FirebaseFirestore.instance
        .collection('journeys')
        .doc(widget.docID)
        .get();

    status = journeystatus['status'];

    return journeystatus;
  }

  getDriver() async {
    var drivers = await FirebaseFirestore.instance
        .collection('drivers')
        .doc(driver)
        .get();

    return drivers;
  }

  String currentJourney = '';

  getUser() async {
    var user = await FirebaseFirestore.instance
        .collection('passengers')
        .doc(auth.currentUser!.uid)
        .get();

    currentJourney = user['currentJourney'];
    isFree = user['isFree'];

    return user;
  }

  List<double> latList = [];
  List<double> lngList = [];
  List<double> distanceList = [];

  getDestination() async {
    var des = await FirebaseFirestore.instance
        .collection('journeys')
        .doc(widget.docID)
        .get();

    setState(() {
      endLat = des['endLat'];
      endLng = des['endLng'];
      latList.add(des['endLat']);
      lngList.add(des['endLng']);
    });

    _markers.add(Marker(
      markerId: const MarkerId('des'),
      position: LatLng(des['endLat'] as double, des['endLng'] as double),
      // icon: BitmapDescriptor.defaultMarkerWithHue(
      //   BitmapDescriptor.hueAzure,
      // )
    ));

    return des;
  }

  getFirebaseData() async {
    await FirebaseFirestore.instance
        .collection('journeys')
        .doc(widget.docID)
        .collection('passenger_s')
        .orderBy('distance', descending: false) /////////////HERE
        .get()
        .then((value) {
      value.docs.forEach((element) {
        setState(() {
          sumLat += element['startLat'];
          sumLng += element['startLng'];
          latList.add(element['startLat']);
          lngList.add(element['startLng']);
          distanceList.add(element['distance']);
          count++;
        });

        //setMarkers(element.id, element['startLat'], element['startLng']);
        setState(() {});
      });
      //getPosition(lat, lng, count);
    });
  }

  List<dynamic> savedList = [];
  getSavedList() async {
    await FirebaseFirestore.instance
        .collection('passengers')
        .doc(auth.currentUser!.uid)
        .collection('saved_locations')
        .orderBy('timestamp', descending: true)
        .get()
        .then((value) {
      value.docs.forEach((element) {
        setState(() {
          savedList.add(element);
        });

        setState(() {});
      });
    });
  }

  List<dynamic> placeList = [];
  myAutocomplete(place) async {
    MyAutocomplete autocomplete = MyAutocomplete(
        place: place, currentLat: currentLat, currentLng: currentLng);
    placeList.clear();

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

  double distanceFromJSON = 0;

  void getJsonData(startLat, startLng, endLat, endLng) async {
    NetworkHelper network = NetworkHelper(
        startLat: startLat as double,
        startLng: startLng as double,
        endLat: endLat as double,
        endLng: endLng as double);

    try {
      // getData() returns a json Decoded data
      var data = await network.getData();
      // We can reach to our desired JSON data manually as following

      var distancetmp =
          data['features'][0]['properties']['summary']['distance'];
      setState(() {
        distanceFromJSON =
            double.parse((distancetmp / 1000).toStringAsFixed(2));
        journey.distance = distanceFromJSON;
        distancetext.text = "${journey.distance} km";
        double costtmp = calculateCost(journey.distance);
        costText.text =
            "${calculateCost(journey.distance)}฿  ->  ${newCostCalculate(journey.distance)}฿";
        journey.cost = costtmp;
      });
    } catch (e) {
      // ignore: avoid_print
      print(e);
    }
  }

  double over = 0;

  getJsonDataLast(startLat, startLng, endLat, endLng) async {
    NetworkHelper network = NetworkHelper(
        startLat: startLat as double,
        startLng: startLng as double,
        endLat: endLat as double,
        endLng: endLng as double);

    try {
      // getData() returns a json Decoded data
      var data = await network.getData();

      var distancetmp =
          data['features'][0]['properties']['summary']['distance'];
      var distanceFromJSON =
          double.parse((distancetmp / 1000).toStringAsFixed(2));

      setState(() {
        over = distanceFromJSON;
      });
    } catch (e) {
      // ignore: avoid_print
      print(e);
    }
  }

  double calculateCost(distance) {
    return (distance * 8).ceil().toDouble();
  }

  List<double> costList = [];

  costCalculate() async {
    double furthest = distanceList.last * 8;
    double sumDistance = 0;
    for (int i = 0; i < distanceList.length; i++) {
      sumDistance += distanceList[i];
    }

    for (int i = 0; i < distanceList.length; i++) {
      double calCost = await (distanceList[i] / sumDistance) * furthest;

      setState(() {
        costList.add(calCost.ceilToDouble());
      });
    }
  }

  newCostCalculate(newDistance) {
    double furthest = 0;

    if (newDistance > distanceList.last) {
      furthest = newDistance * 8;
    } else {
      furthest = distanceList.last * 8;
    }

    double sumDistance = 0;
    for (int i = 0; i < distanceList.length; i++) {
      sumDistance += distanceList[i];
    }

    sumDistance += newDistance;

    return ((newDistance / sumDistance) * furthest).ceilToDouble();
  }

  getCostText(distance) {
    return (distance * 8).ceil().toDouble();
  }

  getPosition(lat, lng, count) async {
    final GoogleMapController controller = await _controller.future;
    final klat = (lat + endLat) / (count + 1);
    final klng = (lng + endLng) / (count + 1);

    CameraPosition kGooglePlex = CameraPosition(
      target: LatLng(klat, klng),
      zoom: 10,
    );
    controller.animateCamera(CameraUpdate.newCameraPosition(kGooglePlex));
    setState(() {});
  }

  int i = 0;

  setMarkers(index, lat, lng) {
    _markers.add(Marker(
        markerId: MarkerId(index.toString()),
        position: LatLng(lat as double, lng as double),
        icon: BitmapDescriptor.defaultMarkerWithHue(pinColor[index])
        //infoWindow: InfoWindow(title: address)
        ));

    // setState(() {
    //   i++;
    // });
  }

  final List<LatLng> polyPoints = [];
  final Set<Polyline> polyLines = {};
  final List<dynamic> roadtmp = [];

  setPolylineList() async {
    int latCount = latList.length;
    int lngCount = lngList.length;

    if (latCount != lngCount) {
      print('Lat & Lng dont equal');
    } else {
      for (int i = 0; i < latCount - 1; i++) {
        await getPolyline(
            latList[i], lngList[i], latList[i + 1], lngList[i + 1]);
      }
    }
  }

  getPolyline(startLat, startLng, endLat, endLng) async {
    // Create an instance of Class NetworkHelper which uses http package
    // for requesting data to the server and receiving response as JSON format

    NetworkHelper network = NetworkHelper(
        startLat: startLat, startLng: startLng, endLat: endLat, endLng: endLng);

    try {
      // getData() returns a json Decoded data
      var data = await network.getData();
      // We can reach to our desired JSON data manually as following
      LineString ls =
          LineString(data['features'][0]['geometry']['coordinates']);

      for (int i = 0; i < ls.lineString.length; i++) {
        polyPoints.add(LatLng(ls.lineString[i][1], ls.lineString[i][0]));
      }

      //setPolyLines();
    } catch (e) {
      // ignore: avoid_print
      print(e);
    }
  }

  setPolyLines() {
    Polyline polyline = Polyline(
        polylineId: const PolylineId("polyline"),
        color: Colors.red,
        width: 6,
        points: polyPoints,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        jointType: JointType.round);
    polyLines.add(polyline);
    //setState(() {});
  }

  double findDistancewithCurrent(double startLat, double startLng) {
    double distance = Geolocator.distanceBetween(
        startLat as double, startLng as double, currentLat, currentLng);
    return double.parse((distance / 1000).toStringAsFixed(2));
  }

  double findDistancewithDes(double startLat, double startLng) {
    double distance = Geolocator.distanceBetween(
        startLat as double, startLng as double, endLat, endLng);
    return double.parse((distance / 1000).toStringAsFixed(2));
  }

  double findDistance(
      double startLat, double startLng, double endLat, double endLng) {
    double distance =
        Geolocator.distanceBetween(startLat, startLng, endLat, endLng);
    return double.parse((distance / 1000).toStringAsFixed(2));
  }

  myLocationFromLatLng(lat, lng) async {
    MyLocationFromLatLng autocomplete =
        MyLocationFromLatLng(lat: lat, lng: lng);

    try {
      // getData() returns a json Decoded data
      var data = await autocomplete.getData();

      startAddress.text = data['features'][0]['properties']['label'];
      // startPlaceName.text = data['features'][0]['properties']['name'];
    } catch (e) {
      // ignore: avoid_print
      print(e);
    }
  }

  realinit() async {
    getJourney();
    getUser();
    await getDestination();
    await getFirebaseData();
    costCalculate();
    getPosition(sumLat, sumLng, count);
    await setPolylineList();
    setPolyLines();
    loadCurrentLocation();
  }

  @override
  void initState() {
    // ignore: todo
    // TODO: implement initState
    super.initState();
    realinit();
    setState(() {});
  }

  bool chk = true;
  bool isAddress = false;
  var ct;

  @override
  Widget build(BuildContext context) {
    double mapKeyboardheight = isAddress
        ? (MediaQuery.of(context).size.height -
                MediaQuery.of(context).padding.top) *
            0.15
        : (MediaQuery.of(context).size.height -
                MediaQuery.of(context).padding.top) *
            0.53;

    double mapheight = chk
        ? (MediaQuery.of(context).size.height -
                MediaQuery.of(context).padding.top) *
            0.35
        : mapKeyboardheight;

    double mapwidth =
        chk ? MediaQuery.of(context).size.width * 0.9 : double.infinity;
    double aboveMap = chk ? 30 : 0;
    return Scaffold(
      bottomNavigationBar: chk
          ? const BottomAppBar(
              child: MyBottomAppbar(
                page: 'journeys',
              ),
            )
          : BottomAppBar(
              notchMargin: 1,
              shape: const CircularNotchedRectangle(),
              color: Colors.orangeAccent,
              child: IconTheme(
                data: IconThemeData(
                    color: Theme.of(context).colorScheme.onPrimary),
                child: Row(
                  children: const [
                    SizedBox(
                      height: 27,
                    )
                  ],
                ),
              ),
            ),
      floatingActionButtonLocation: chk
          ? FloatingActionButtonLocation.endFloat
          : FloatingActionButtonLocation.endDocked,
      floatingActionButton: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('journeys')
              .doc(widget.docID)
              .snapshots(),
          builder: (context, AsyncSnapshot snapdoc) {
            if (snapdoc.hasData) {
              if (snapdoc.data!['status'] == 'waiting_passenger' &&
                  isFree == true) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10, right: 2),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.height * 0.1,
                    height: MediaQuery.of(context).size.height * 0.1,
                    child: FloatingActionButton(
                        onPressed: () async {
                          if (chk) {
                            setState(() {
                              chk = chk ? false : true;
                            });
                          } else if (!chk) {
                            await getJsonDataLast(
                                journey.startLat as double,
                                journey.startLng as double,
                                latList.last,
                                lngList.last);

                            if (journey.startLat == null ||
                                journey.startLng == null) {
                              Fluttertoast.showToast(
                                  msg: "Please choose location.",
                                  textColor: Colors.white,
                                  backgroundColor: Colors.red.shade600,
                                  gravity: ToastGravity.CENTER,
                                  timeInSecForIosWeb: 10);
                            } else if (findDistance(
                                    journey.startLat as double,
                                    journey.startLng as double,
                                    latList.last,
                                    lngList.last) >
                                30) {
                              Fluttertoast.showToast(
                                  msg: "You too far from other passenger.",
                                  textColor: Colors.white,
                                  backgroundColor: Colors.red.shade600,
                                  gravity: ToastGravity.CENTER,
                                  timeInSecForIosWeb: 10);
                            } else if (over > distanceList.last) {
                              Fluttertoast.showToast(
                                  msg: "This journey won't pass your location.",
                                  textColor: Colors.white,
                                  backgroundColor: Colors.red.shade600,
                                  gravity: ToastGravity.CENTER,
                                  timeInSecForIosWeb: 10);
                            } else if (formKey.currentState!.validate()) {
                              formKey.currentState?.save();
                              try {
                                await FirebaseFirestore.instance
                                    .collection('journeys')
                                    .doc(widget.docID)
                                    .collection('passenger_s')
                                    .doc(auth.currentUser!.uid)
                                    .set({
                                  "startLat": journey.startLat,
                                  "startLng": journey.startLng,
                                  "startAddress": journey.startAddress,
                                  "detail": journey.detail,
                                  "distance": journey.distance,
                                  "status": 'waiting',
                                  "timestamp": Timestamp.now(),
                                }).then((value) async {
                                  await passengersCollection
                                      .doc(auth.currentUser!.uid)
                                      .collection('journey_s')
                                      .doc(widget.docID)
                                      .set({"timestamp": Timestamp.now()});

                                  await passengersCollection
                                      .doc(auth.currentUser!.uid)
                                      .update({
                                    'isFree': false,
                                    'currentJourney': widget.docID
                                  });
                                }).then((value) async {
                                  setState(() {});
                                  if (ct + 1 == person) {
                                    costList.clear();
                                    distanceList.clear();

                                    List<String> idList = [];
                                    await FirebaseFirestore.instance
                                        .collection('journeys')
                                        .doc(widget.docID)
                                        .collection('passenger_s')
                                        .orderBy('distance', descending: false)
                                        .get()
                                        .then((value) {
                                      value.docs.forEach((element) {
                                        setState(() {
                                          idList.add(element.id);
                                          distanceList.add(element['distance']);
                                        });
                                      });
                                    });

                                    await costCalculate();

                                    var sumCost = 0.0;

                                    for (int i = 0; i < idList.length; i++) {
                                      sumCost += costList[i] as double;
                                      await journeysCollection
                                          .doc(widget.docID)
                                          .collection('passenger_s')
                                          .doc(idList[i])
                                          .update({
                                        'cost': costList[i],
                                      });
                                    }

                                    await journeysCollection
                                        .doc(widget.docID)
                                        .update({
                                      'status': 'waiting_driver',
                                      'cost': sumCost,
                                    });
                                  }
                                }).then((value) {
                                  Fluttertoast.showToast(
                                      msg: "Join successfully!",
                                      gravity: ToastGravity.BOTTOM,
                                      timeInSecForIosWeb: 10);

                                  setState(() {});

                                  Navigator.pushReplacement(context,
                                      MaterialPageRoute(builder: (context) {
                                    return const HistoryScreen();
                                  }));
                                });
                              } on FirebaseAuthException catch (e) {
                                String? message;

                                message = e.message;

                                Fluttertoast.showToast(
                                    //msg: e.message.toString(),
                                    msg: message.toString(),
                                    gravity: ToastGravity.CENTER);
                              }
                            }
                          }
                        },
                        backgroundColor: Colors.deepOrange,
                        child: chk
                            ? Icon(
                                Icons.add,
                                size: MediaQuery.of(context).size.height * 0.05,
                                color: Colors.white,
                              )
                            : Icon(
                                Icons.check,
                                size: MediaQuery.of(context).size.height * 0.05,
                                color: Colors.white,
                              )),
                  ),
                );
              } else {
                return const SizedBox(
                  height: 0,
                  width: 0,
                );
              }
            }

            return Center(
                child: CircularProgressIndicator(
              color: Colors.green[200],
            ));
          }),
      backgroundColor: Colors.white,
      appBar: AppBar(
        actions: [
          chk
              ? dropdownMenu()
              : Padding(
                  padding: const EdgeInsets.fromLTRB(0, 1, 15, 0),
                  child: IconButton(
                    icon: const Icon(
                      Icons.close,
                      size: 30,
                      color: Colors.deepOrange,
                    ),
                    onPressed: () {
                      setState(() {
                        _markers.removeWhere(
                            (marker) => marker.markerId.value == "location");

                        journey.startLat = null;
                        journey.startLng = null;

                        startAddress.text = '';
                        distancetext.text = '';
                        detail.text = '';
                        costText.text = '';
                        chk = chk ? false : true;
                        isAddress = false;
                        isX = false;
                      });
                      getPosition(sumLat, sumLng, count);
                    },
                  ))
        ],
        automaticallyImplyLeading: (chk && !isDelete),
        elevation: 0,
        centerTitle: true,
        backgroundColor:
            Colors.white, //const Color.fromARGB(255, 241, 243, 244),
        //elevation: 0,
        title: chk
            ? const Text('Journey Summary')
            : const Text('Pick your location'),
      ),
      body: GestureDetector(
        onTap: () {
          Fluttertoast.showToast(
              msg: "$endLat $endLng",
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 10);
          FocusScope.of(context).unfocus();
          getPosition(sumLat, sumLng, count);
          setState(() {
            isDelete = false;
          });
        },
        child: SingleChildScrollView(
          child: Center(
            child: Stack(
              children: [
                Column(
                  children: [
                    Container(
                      padding: EdgeInsets.fromLTRB(0, aboveMap, 0, 0),
                      color: Colors.white,
                      height: mapheight,
                      width: mapwidth,
                      child: GoogleMap(
                        initialCameraPosition: _kGooglePlex,
                        mapType: MapType.normal,
                        myLocationButtonEnabled: true,
                        myLocationEnabled: true,
                        markers: Set<Marker>.of(_markers),
                        polylines: polyLines,
                        onTap: (latLng) async {
                          if (!chk) {
                            _markers.add(Marker(
                                markerId: const MarkerId('location'),
                                position:
                                    LatLng(latLng.latitude, latLng.longitude),
                                icon: BitmapDescriptor.defaultMarkerWithHue(
                                  BitmapDescriptor.hueRed,
                                )));
                            final GoogleMapController controller =
                                await _controller.future;
                            CameraPosition kGooglePlex = CameraPosition(
                              target: LatLng(latLng.latitude, latLng.longitude),
                              zoom: 14,
                            );
                            controller.animateCamera(
                                CameraUpdate.newCameraPosition(kGooglePlex));
                            await myLocationFromLatLng(
                                latLng.latitude, latLng.longitude);

                            journey.startLat = latLng.latitude;
                            journey.startLng = latLng.longitude;
                            journey.startAddress = startAddress.text;
                            getJsonData(journey.startLat, journey.startLng,
                                endLat, endLng);

                            isX = true;
                            setState(() {});
                          }
                        },
                        onMapCreated: (GoogleMapController controller) {
                          _controller.complete(controller);
                        },
                      ),
                    ),
                    StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection('journeys')
                            .doc(widget.docID)
                            .snapshots(),
                        builder: (context, AsyncSnapshot snapdoc) {
                          if (snapdoc.hasData) {
                            //status = snapdoc.data!['status'];
                            if (snapdoc.data!['status'] == 'waiting_driver') {
                              return Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(20, 20, 20, 0),
                                  child: SizedBox(
                                    height: 70,
                                    width:
                                        MediaQuery.of(context).size.width * 0.8,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: const [
                                        Text('Waiting for Driver',
                                            style: TextStyle(
                                                fontSize: 17,
                                                fontWeight: FontWeight.bold)),
                                        SizedBox(
                                          width: 25,
                                        ),
                                        CircularProgressIndicator(
                                          color: Colors.deepOrangeAccent,
                                          strokeWidth: 4,
                                        ),
                                      ],
                                    ),
                                  ));
                            } else if (snapdoc.data!['status'] == 'traveling' ||
                                snapdoc.data!['status'] == 'success') {
                              return Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(20, 20, 20, 0),
                                child: FutureBuilder(
                                    future: getDriver(),
                                    builder: (context, AsyncSnapshot snapdoc) {
                                      if (snapdoc.hasData) {
                                        return SizedBox(
                                          height: 80,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.9,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              (snapdoc.data!['imageURL'] != '')
                                                  ? CircleAvatar(
                                                      radius: 45,
                                                      backgroundImage:
                                                          NetworkImage(
                                                              snapdoc.data![
                                                                  'imageURL']))
                                                  : const CircleAvatar(
                                                      radius: 45,
                                                      backgroundImage: AssetImage(
                                                          'assets/default_profile.jpg')),
                                              Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  const Text('Driver :'),
                                                  Row(
                                                    children: [
                                                      const Icon(
                                                        Icons.person,
                                                        size: 20,
                                                        color: Colors.orange,
                                                      ),
                                                      Text(
                                                          '${snapdoc.data!['fname']} ${snapdoc.data!['lname']}'),
                                                    ],
                                                  ),
                                                  Row(
                                                    children: [
                                                      const Icon(
                                                        Icons.phone_android,
                                                        size: 20,
                                                        color: Colors.orange,
                                                      ),
                                                      Text(
                                                          '${snapdoc.data!['tel']}'),
                                                    ],
                                                  )
                                                ],
                                              ),
                                            ],
                                          ),
                                        );
                                      }

                                      return Center(
                                          child: CircularProgressIndicator(
                                        color: Colors.green[200],
                                      ));
                                    }),
                              );
                            }
                          }

                          return const SizedBox(
                            height: 0,
                            width: 0,
                          );
                        }),
                    chk
                        ?
                        //Future Here !
                        GestureDetector(
                            onTap: () => FocusScope.of(context).unfocus(),
                            child: Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  0, 20, 0, 0),
                              child: StreamBuilder(
                                  stream: FirebaseFirestore.instance
                                      .collection('journeys')
                                      .doc(widget.docID)
                                      .collection('passenger_s')
                                      .orderBy('distance', descending: false)
                                      .snapshots(),
                                  builder: (context,
                                      AsyncSnapshot<QuerySnapshot> snapshot) {
                                    if (!snapshot.hasData) {
                                      return const Center(
                                          child: CircularProgressIndicator());
                                    }
                                    ct = snapshot.data!.docs.length;

                                    return SizedBox(
                                      height: (status == 'traveling' ||
                                              status == 'success' ||
                                              status == 'waiting_driver')
                                          ? (MediaQuery.of(context)
                                                      .size
                                                      .height -
                                                  MediaQuery.of(context)
                                                      .padding
                                                      .top) *
                                              0.28
                                          : (MediaQuery.of(context)
                                                      .size
                                                      .height -
                                                  MediaQuery.of(context)
                                                      .padding
                                                      .top) *
                                              0.4,
                                      width: MediaQuery.of(context).size.width *
                                          0.9,
                                      child: ListView(
                                        children:
                                            snapshot.data!.docs.map((document) {
                                          return Container(
                                            color: Colors.white,
                                            height: (status == 'traveling' ||
                                                    status == 'success' ||
                                                    status == 'waiting_driver')
                                                ? (MediaQuery.of(context)
                                                            .size
                                                            .height -
                                                        MediaQuery.of(context)
                                                            .padding
                                                            .top) *
                                                    0.28
                                                : (MediaQuery.of(context)
                                                            .size
                                                            .height -
                                                        MediaQuery.of(context)
                                                            .padding
                                                            .top) *
                                                    0.7,
                                            child: ListView.builder(
                                                scrollDirection: Axis.vertical,
                                                itemCount:
                                                    snapshot.data!.docs.length,
                                                itemBuilder: ((context, index) {
                                                  setMarkers(
                                                      index,
                                                      snapshot.data!.docs[index]
                                                          ['startLat'],
                                                      snapshot.data!.docs[index]
                                                          ['startLng']);

                                                  return SizedBox(
                                                    height: (status ==
                                                                'traveling' ||
                                                            status ==
                                                                'success' ||
                                                            status ==
                                                                'waiting_driver')
                                                        ? 75
                                                        : 110,
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              bottom: 5),
                                                      child: ElevatedButton(
                                                          onPressed: () async {
                                                            final GoogleMapController
                                                                controller =
                                                                await _controller
                                                                    .future;
                                                            CameraPosition
                                                                kGooglePlex =
                                                                CameraPosition(
                                                              target: LatLng(
                                                                  snapshot.data!
                                                                              .docs[
                                                                          index]
                                                                      [
                                                                      'startLat'],
                                                                  snapshot.data!
                                                                              .docs[
                                                                          index]
                                                                      [
                                                                      'startLng']),
                                                              zoom: 12,
                                                            );
                                                            controller.animateCamera(
                                                                CameraUpdate
                                                                    .newCameraPosition(
                                                                        kGooglePlex));
                                                          },
                                                          style: ButtonStyle(
                                                            elevation:
                                                                MaterialStateProperty
                                                                    .all(0),
                                                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            0.0),
                                                                side: const BorderSide(
                                                                    color: Color
                                                                        .fromARGB(
                                                                            255,
                                                                            229,
                                                                            229,
                                                                            229)))),
                                                            backgroundColor:
                                                                MaterialStateProperty
                                                                    .all(Colors
                                                                        .white),
                                                          ),
                                                          child: Row(
                                                            //mainAxisAlignment: MainAxisAlignment.,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Text(
                                                                  (index + 1)
                                                                      .toString(),
                                                                  style: TextStyle(
                                                                      fontSize: (status == 'traveling' ||
                                                                              status ==
                                                                                  'success' ||
                                                                              status ==
                                                                                  'waiting_driver')
                                                                          ? 40
                                                                          : 50,
                                                                      color: colorList[
                                                                          index])),
                                                              const SizedBox(
                                                                width: 20,
                                                              ),
                                                              Column(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Row(
                                                                    children: [
                                                                      Icon(
                                                                        Icons
                                                                            .my_location,
                                                                        size: (status == 'traveling' ||
                                                                                status == 'success' ||
                                                                                status == 'waiting_driver')
                                                                            ? 14
                                                                            : 20,
                                                                        color: Colors
                                                                            .grey
                                                                            .shade600,
                                                                      ),
                                                                      Text(
                                                                        " ${findDistancewithCurrent(snapshot.data!.docs[index]['startLat'], snapshot.data!.docs[index]['startLng'])} km from your position.",
                                                                        style: TextStyle(
                                                                            fontSize: (status == 'traveling' || status == 'success' || status == 'waiting_driver')
                                                                                ? 13
                                                                                : 15),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  Row(
                                                                    children: [
                                                                      Icon(
                                                                        Icons
                                                                            .location_pin,
                                                                        size: (status == 'traveling' ||
                                                                                status == 'success' ||
                                                                                status == 'waiting_driver')
                                                                            ? 14
                                                                            : 20,
                                                                        color: Colors
                                                                            .grey
                                                                            .shade600,
                                                                      ),
                                                                      Text(
                                                                        " ${snapshot.data!.docs[index]['distance']} km from destination.",
                                                                        style: TextStyle(
                                                                            fontSize: (status == 'traveling' || status == 'success' || status == 'waiting_driver')
                                                                                ? 13
                                                                                : 15),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  (costList.length ==
                                                                              snapshot
                                                                                  .data!.docs.length &&
                                                                          costList.length >
                                                                              1)
                                                                      ? Row(
                                                                          children: [
                                                                            Icon(
                                                                              Icons.price_check,
                                                                              size: (status == 'traveling' || status == 'success' || status == 'waiting_driver') ? 14 : 20,
                                                                              color: Colors.grey.shade600,
                                                                            ),
                                                                            Text(
                                                                              " ${getCostText(snapshot.data!.docs[index]['distance'])} ฿",
                                                                              style: TextStyle(decoration: TextDecoration.lineThrough, fontSize: (status == 'traveling' || status == 'success' || status == 'success' || status == 'waiting_driver') ? 13 : 15),
                                                                            ),
                                                                            Text(
                                                                              "  ->  ${costList[index]}",
                                                                              style: TextStyle(fontSize: (status == 'traveling' || status == 'success' || status == 'waiting_driver') ? 13 : 15),
                                                                            )
                                                                          ],
                                                                        )
                                                                      : Row(
                                                                          children: [
                                                                            Icon(
                                                                              Icons.price_check,
                                                                              color: Colors.grey.shade600,
                                                                            ),
                                                                            Text(
                                                                              " ${getCostText(snapshot.data!.docs[index]['distance'])}฿",
                                                                              style: TextStyle(fontSize: (status == 'traveling' || status == 'success' || status == 'waiting_driver') ? 13 : 15),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                ],
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
                          )
                        : //addja
                        Stack(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  FocusScope.of(context).unfocus();

                                  setState(() {
                                    placeList.clear();
                                    savedList.clear();
                                    isAddress = false;
                                  });
                                },
                                child: Material(
                                  //elevation: 4,
                                  borderRadius: const BorderRadius.only(
                                      bottomLeft: Radius.circular(20),
                                      bottomRight: Radius.circular(20)),
                                  child: Container(
                                    width: double.infinity,
                                    height:
                                        (MediaQuery.of(context).size.height -
                                                MediaQuery.of(context)
                                                    .padding
                                                    .top) *
                                            0.35,
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(20),
                                          topRight: Radius.circular(20)),
                                    ),
                                    child: Form(
                                      key: formKey,
                                      child: Center(
                                        child: Container(
                                          padding: const EdgeInsets.fromLTRB(
                                              0, 5, 0, 0),
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.9,
                                          height: (MediaQuery.of(context)
                                                      .size
                                                      .height -
                                                  MediaQuery.of(context)
                                                      .padding
                                                      .top) *
                                              0.35,
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              //Text('Information',style: TextStyle(fontSize: 20),),

                                              Stack(
                                                children: [
                                                  TextFormField(
                                                      //autofocus: true,
                                                      maxLines: 1,
                                                      onChanged: (value) async {
                                                        await myAutocomplete(
                                                            value);
                                                      },
                                                      onTap: () {
                                                        if (startAddress.text !=
                                                            '') {
                                                          myAutocomplete(
                                                              startAddress
                                                                  .text);
                                                        }
                                                        setState(() {
                                                          isAddress = true;
                                                          savedList.clear();
                                                        });
                                                      },
                                                      controller: startAddress,
                                                      validator: RequiredValidator(
                                                          errorText:
                                                              "Please choose location"),
                                                      decoration:
                                                          InputDecoration(
                                                        label: const Text(
                                                            'Address'),
                                                        icon: const Icon(
                                                          Icons.place_outlined,
                                                          size: 28,
                                                          color: Colors.orange,
                                                        ),
                                                        contentPadding:
                                                            const EdgeInsets
                                                                    .fromLTRB(
                                                                10, 10, 40, 10),
                                                        fillColor: const Color
                                                                .fromARGB(
                                                            180, 255, 255, 255),
                                                        border:
                                                            OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                          borderSide:
                                                              const BorderSide(
                                                            width: 1,
                                                            style: BorderStyle
                                                                .none,
                                                          ),
                                                        ),
                                                        filled: true,
                                                      )),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.end,
                                                    children: [
                                                      Align(
                                                        alignment: Alignment
                                                            .centerRight,
                                                        child: isX
                                                            ? IconButton(
                                                                padding:
                                                                    EdgeInsets
                                                                        .zero,
                                                                onPressed: () {
                                                                  getPosition(
                                                                      sumLat,
                                                                      sumLng,
                                                                      count);
                                                                  setState(() {
                                                                    placeList
                                                                        .clear();
                                                                    savedList
                                                                        .clear();
                                                                    startAddress
                                                                        .text = '';
                                                                    detail.text =
                                                                        '';

                                                                    costText.text =
                                                                        '';

                                                                    distancetext
                                                                        .text = '';

                                                                    isX = false;
                                                                    isAddress =
                                                                        false;
                                                                    _markers.removeWhere((marker) =>
                                                                        marker
                                                                            .markerId
                                                                            .value ==
                                                                        "location");
                                                                  });
                                                                },
                                                                icon: Icon(
                                                                    Icons.close,
                                                                    color: Colors
                                                                            .grey[
                                                                        600],
                                                                    size: 28))
                                                            : SizedBox(
                                                                width: 25,
                                                                child:
                                                                    IconButton(
                                                                        padding:
                                                                            EdgeInsets
                                                                                .zero,
                                                                        onPressed:
                                                                            () async {
                                                                          if (startAddress
                                                                              .text
                                                                              .isNotEmpty) {
                                                                            placeList.clear();

                                                                            await myAutocomplete(startAddress.text);
                                                                          } else {
                                                                            placeList.clear();
                                                                          }
                                                                        },
                                                                        icon: Icon(
                                                                            Icons
                                                                                .search,
                                                                            color: placeList.isNotEmpty
                                                                                ? Colors.orange
                                                                                : Colors.grey[600],
                                                                            size: 28)),
                                                              ),
                                                      ),
                                                      isX
                                                          ? const SizedBox(
                                                              width: 0,
                                                              height: 0)
                                                          : IconButton(
                                                              onPressed:
                                                                  () async {
                                                                placeList
                                                                    .clear();
                                                                savedList
                                                                    .clear();
                                                                getSavedList();
                                                                FocusScope.of(
                                                                        context)
                                                                    .unfocus();
                                                                isAddress =
                                                                    false;
                                                              },
                                                              icon: Icon(
                                                                  Icons
                                                                      .favorite,
                                                                  color: savedList
                                                                          .isNotEmpty
                                                                      ? Colors
                                                                          .orange
                                                                      : Colors.grey[
                                                                          600],
                                                                  size: 28)),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              TextFormField(
                                                  maxLines: 1,
                                                  onSaved: (String? detail) {
                                                    journey.detail = detail;
                                                  },
                                                  controller: detail,
                                                  decoration: InputDecoration(
                                                    contentPadding:
                                                        const EdgeInsets.all(
                                                            10),
                                                    fillColor:
                                                        const Color.fromARGB(
                                                            180, 255, 255, 255),
                                                    label: const Text(
                                                        'Pick-up location detail'),
                                                    icon: const Icon(
                                                      Icons.chat_bubble_outline,
                                                      size: 28,
                                                      color: Colors.orange,
                                                    ),
                                                    border: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                      borderSide:
                                                          const BorderSide(
                                                        width: 1,
                                                        style: BorderStyle.none,
                                                      ),
                                                    ),
                                                    filled: true,
                                                  )),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              TextField(
                                                  enableInteractiveSelection:
                                                      false,
                                                  maxLines: 1,
                                                  readOnly: true,
                                                  controller: distancetext,
                                                  decoration: InputDecoration(
                                                    contentPadding:
                                                        const EdgeInsets.all(5),
                                                    fillColor:
                                                        const Color.fromARGB(
                                                            180, 255, 255, 255),
                                                    label:
                                                        const Text('distance'),
                                                    icon: const Icon(
                                                      Icons.add_road,
                                                      size: 28,
                                                      color: Colors.orange,
                                                    ),
                                                    border: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                      borderSide:
                                                          const BorderSide(
                                                        width: 1,
                                                        style: BorderStyle.none,
                                                      ),
                                                    ),
                                                    filled: true,
                                                  )),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              TextField(
                                                  enableInteractiveSelection:
                                                      false,
                                                  maxLines: 1,
                                                  readOnly: true,
                                                  controller: costText,
                                                  decoration: InputDecoration(
                                                    contentPadding:
                                                        const EdgeInsets.all(5),
                                                    fillColor:
                                                        const Color.fromARGB(
                                                            180, 255, 255, 255),
                                                    label: const Text('cost'),
                                                    icon: const Icon(
                                                      Icons.paid_outlined,
                                                      size: 28,
                                                      color: Colors.orange,
                                                    ),
                                                    border: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                      borderSide:
                                                          const BorderSide(
                                                        width: 1,
                                                        style: BorderStyle.none,
                                                      ),
                                                    ),
                                                    filled: true,
                                                  )),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              placeList.isNotEmpty
                                  ? Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          60, 50, 50, 0),
                                      child: SizedBox(
                                        //color: Colors.lightBlue,
                                        width: double.infinity,
                                        height: 200,
                                        child: ListView.builder(
                                            itemCount: placeList.length,
                                            itemBuilder: ((context, index) {
                                              return Column(
                                                children: [
                                                  Container(
                                                    decoration: BoxDecoration(
                                                      border: const Border(),
                                                      color: Colors.white,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.grey
                                                              .withOpacity(0.5),
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

                                                        startAddress
                                                            .text = placeList[
                                                                    index]
                                                                ['properties']
                                                            ['label'];

                                                        _markers.add(Marker(
                                                          markerId:
                                                              const MarkerId(
                                                                  'location'),
                                                          position: LatLng(
                                                              placeList[index][
                                                                              'geometry']
                                                                          [
                                                                          'coordinates']
                                                                      [1]
                                                                  .toDouble(),
                                                              placeList[index][
                                                                          'geometry']
                                                                      [
                                                                      'coordinates'][0]
                                                                  .toDouble()),
                                                          //infoWindow: InfoWindow(title: address)
                                                        ));
                                                        final GoogleMapController
                                                            controller =
                                                            await _controller
                                                                .future;
                                                        CameraPosition
                                                            kGooglePlex =
                                                            CameraPosition(
                                                          target: LatLng(
                                                              placeList[index][
                                                                              'geometry']
                                                                          [
                                                                          'coordinates']
                                                                      [1]
                                                                  .toDouble(),
                                                              placeList[index][
                                                                          'geometry']
                                                                      [
                                                                      'coordinates'][0]
                                                                  .toDouble()),
                                                          zoom: 16,
                                                        );
                                                        controller.animateCamera(
                                                            CameraUpdate
                                                                .newCameraPosition(
                                                                    kGooglePlex));

                                                        setState(() {
                                                          isAddress = false;
                                                          journey.detail = '';
                                                          detail.text = journey
                                                              .detail
                                                              .toString();
                                                          journey
                                                              .startLat = placeList[
                                                                          index]
                                                                      [
                                                                      'geometry']
                                                                  [
                                                                  'coordinates'][1]
                                                              .toDouble();
                                                          journey
                                                              .startLng = placeList[
                                                                          index]
                                                                      [
                                                                      'geometry']
                                                                  [
                                                                  'coordinates'][0]
                                                              .toDouble();
                                                          journey.startAddress =
                                                              startAddress.text;

                                                          getJsonData(
                                                              journey.startLat,
                                                              journey.startLng,
                                                              endLat,
                                                              endLng);

                                                          // var distanced =
                                                          //     findDistancewithDes(
                                                          //         journey.startLat
                                                          //             as double,
                                                          //         journey.startLng
                                                          //             as double);
                                                          // distancetext.text =
                                                          //     distanced
                                                          //         .toString();
                                                          // journey.distance =
                                                          //     distanced;
                                                          // var costed =
                                                          //     newCostCalculate(
                                                          //         distanced);
                                                          // costText.text =
                                                          //     "${distanced * 8}  ->  ${costed.toString()}";

                                                          placeList.clear();
                                                          isX = true;
                                                        });
                                                        setState(() {
                                                          placeList.clear();
                                                        });
                                                      },
                                                      leading: const Icon(
                                                          Icons.location_city),
                                                      title: Text(
                                                          placeList[index]
                                                                  ['properties']
                                                              ['name']),
                                                      subtitle: Text(
                                                          placeList[index]
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
                              savedList.isNotEmpty
                                  ? Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          70, 50, 20, 0),
                                      child: SizedBox(
                                        //color: Colors.lightBlue,
                                        width: double.infinity,
                                        height: 200,
                                        child: ListView.builder(
                                            itemCount: savedList.length,
                                            itemBuilder: ((context, index) {
                                              return Column(
                                                children: [
                                                  Container(
                                                    decoration: BoxDecoration(
                                                      border: const Border(),
                                                      color: Colors.white,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.grey
                                                              .withOpacity(0.5),
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

                                                        startAddress.text =
                                                            savedList[index]
                                                                ['address'];

                                                        _markers.add(Marker(
                                                          markerId:
                                                              const MarkerId(
                                                                  'location'),
                                                          position: LatLng(
                                                              savedList[index][
                                                                      'latitude']
                                                                  .toDouble(),
                                                              savedList[index][
                                                                      'longitude']
                                                                  .toDouble()),
                                                          //infoWindow: InfoWindow(title: address)
                                                        ));
                                                        final GoogleMapController
                                                            controller =
                                                            await _controller
                                                                .future;
                                                        CameraPosition
                                                            kGooglePlex =
                                                            CameraPosition(
                                                          target: LatLng(
                                                              savedList[index][
                                                                      'latitude']
                                                                  .toDouble(),
                                                              savedList[index][
                                                                      'longitude']
                                                                  .toDouble()),
                                                          zoom: 16,
                                                        );
                                                        controller.animateCamera(
                                                            CameraUpdate
                                                                .newCameraPosition(
                                                                    kGooglePlex));

                                                        setState(() {
                                                          journey.startLat =
                                                              savedList[index][
                                                                      'latitude']
                                                                  .toDouble()
                                                                  .toDouble();
                                                          journey.startLng =
                                                              savedList[index][
                                                                      'longitude']
                                                                  .toDouble();
                                                          journey.startAddress =
                                                              startAddress.text;
                                                          journey.detail =
                                                              savedList[index]
                                                                  ['detail'];
                                                          detail.text = journey
                                                              .detail
                                                              .toString();

                                                          // var distanced =
                                                          //     findDistancewithDes(
                                                          //         journey.startLat
                                                          //             as double,
                                                          //         journey.startLng
                                                          //             as double);
                                                          // distancetext.text =
                                                          //     distanced
                                                          //         .toString();
                                                          // journey.distance =
                                                          //     distanced;
                                                          // var costed =
                                                          //     newCostCalculate(
                                                          //         distanced);
                                                          // costText.text =
                                                          //     "${distanced * 8}  ->  ${costed.toString()}";

                                                          getJsonData(
                                                              journey.startLat,
                                                              journey.startLng,
                                                              endLat,
                                                              endLng);
                                                          savedList.clear();
                                                          isX = true;
                                                        });
                                                        setState(() {
                                                          savedList.clear();
                                                        });
                                                      },
                                                      leading: const Icon(
                                                          Icons.location_city),
                                                      title: Text(
                                                          savedList[index]
                                                              ['placeName']),
                                                      subtitle: Text(
                                                          savedList[index]
                                                              ['address']),
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
                  ],
                ),
                isDelete
                    ? Container(
                        width: MediaQuery.of(context).size.width * 0.9,
                        height: (MediaQuery.of(context).size.height -
                            MediaQuery.of(context).padding.top),
                        color: const Color.fromARGB(100, 255, 255, 255),
                      )
                    : const SizedBox(width: 0, height: 0),
                isDelete
                    ? deletePopup()
                    : const SizedBox(
                        width: 0,
                        height: 0,
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  dropdownMenu() {
    if (status == 'traveling' || status == 'success') {
      return const SizedBox(height: 0, width: 0);
    } else if (auth.currentUser!.uid == creator) {
      return dropdownCreator();
    } else if (currentJourney == widget.docID) {
      return dropdownJoiner();
    }
    return const SizedBox(height: 0, width: 0);
  }

  dropdownCreator() {
    return PopupMenuButton(
        // add icon, by default "3 dot" icon
        // icon: Icon(Icons.book)
        itemBuilder: (context) {
      return [
        PopupMenuItem<int>(
          value: 0,
          child: Row(
            children: const [
              Icon(
                Icons.cancel,
                color: Colors.red,
              ),
              Text("  Cancel",
                  style: TextStyle(
                      color: Colors.red, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ];
    }, onSelected: (value) {
      if (value == 0) {
        setState(() {
          isDelete = true;
        });
      }
    });
  }

  dropdownJoiner() {
    return PopupMenuButton(
        // add icon, by default "3 dot" icon
        // icon: Icon(Icons.book)
        itemBuilder: (context) {
      return [
        PopupMenuItem<int>(
          value: 0,
          child: Row(
            children: const [
              Icon(
                Icons.exit_to_app,
                color: Colors.red,
              ),
              Text("  Unjoin",
                  style: TextStyle(
                      color: Colors.red, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ];
    }, onSelected: (value) {
      if (value == 0) {
        setState(() {
          isDelete = true;
        });
      }
    });
  }

  deletePopup() {
    if (auth.currentUser!.uid == creator) {
      return deleteCreator();
    } else if (currentJourney == widget.docID) {
      return deleteJoiner();
    }
    return const SizedBox(height: 0, width: 0);
  }

  deleteCreator() {
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).size.height * 0.32, horizontal: 8.5),
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.85,
        child: Card(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
              side: const BorderSide(color: Colors.grey, width: 0.5)),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  height: 10,
                ),
                const ListTile(
                  leading: Icon(
                    Icons.delete,
                    color: Colors.red,
                  ),
                  title: Text('Do you sure to cancel this journey.'),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      child: const Text(
                        'Delete',
                        style: TextStyle(color: Colors.red),
                      ),
                      onPressed: () async {
                        List<dynamic> passList = [];
                        try {
                          await FirebaseFirestore.instance
                              .collection('journeys')
                              .doc(widget.docID)
                              .collection('passenger_s')
                              .get()
                              .then((value) async {
                            value.docs.forEach((element) async {
                              await passengersCollection
                                  .doc(element.id)
                                  .collection('journey_s')
                                  .doc(widget.docID)
                                  .delete();

                              await passengersCollection.doc(element.id).update(
                                  {'isFree': true, "currentJourney": ''});

                              passList.add(element.id);
                            });

                            for (int j = 0; j < passList.length; j++) {
                              await journeysCollection
                                  .doc(widget.docID)
                                  .collection('passenger_s')
                                  .doc(passList[j])
                                  .delete();

                              Fluttertoast.showToast(msg: "$passList[j]");
                            }
                          }).then((value) async {
                            Navigator.of(context)
                                .popUntil((route) => route.isFirst);
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return const HomeScreen();
                            }));

                            await journeysCollection.doc(widget.docID).delete();

                            Fluttertoast.showToast(
                                msg: "Delete Success",
                                gravity: ToastGravity.BOTTOM,
                                timeInSecForIosWeb: 10);
                          });
                        } on FirebaseAuthException catch (e) {
                          String? message;

                          message = e.message;

                          Fluttertoast.showToast(
                              //msg: e.message.toString(),
                              msg: message.toString(),
                              gravity: ToastGravity.CENTER);
                        }
                      },
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      child: Text('Cancel',
                          style: TextStyle(color: Colors.grey[700])),
                      onPressed: () {
                        setState(() {
                          isDelete = false;
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  deleteJoiner() {
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).size.height * 0.32, horizontal: 8.5),
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.85,
        child: Card(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
              side: const BorderSide(color: Colors.grey, width: 0.5)),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  height: 10,
                ),
                const ListTile(
                  leading: Icon(
                    Icons.delete,
                    color: Colors.red,
                  ),
                  title: Text('Do you sure to unjoin this journey.'),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      child: const Text(
                        'Unjoin',
                        style: TextStyle(color: Colors.red),
                      ),
                      onPressed: () async {
                        try {
                          await passengersCollection
                              .doc(auth.currentUser!.uid)
                              .update({'isFree': true, "currentJourney": ''});

                          await passengersCollection
                              .doc(auth.currentUser!.uid)
                              .collection('journey_s')
                              .doc(widget.docID)
                              .delete();

                          await journeysCollection
                              .doc(widget.docID)
                              .collection('passenger_s')
                              .doc(auth.currentUser!.uid)
                              .delete();

                          await journeysCollection.doc(widget.docID).update({
                            'status': 'waiting_passenger',
                          }).then((value) {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return const HomeScreen();
                            }));

                            Fluttertoast.showToast(
                                msg: "Unjoin Success",
                                gravity: ToastGravity.BOTTOM,
                                timeInSecForIosWeb: 10);
                          });
                        } on FirebaseAuthException catch (e) {
                          String? message;

                          message = e.message;

                          Fluttertoast.showToast(
                              //msg: e.message.toString(),
                              msg: message.toString(),
                              gravity: ToastGravity.CENTER);
                        }
                      },
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      child: Text('Cancel',
                          style: TextStyle(color: Colors.grey[700])),
                      onPressed: () {
                        setState(() {
                          isDelete = false;
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
