import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sharing_taxi/main.dart';
import 'package:sharing_taxi/models/journey.dart';
import 'package:sharing_taxi/screens/g_history_screen.dart';
import 'package:sharing_taxi/screens/e_journey_screen.dart';
import 'package:sharing_taxi/dump/from_end_screen.dart';
import 'package:sharing_taxi/dump/fake_home_screen.dart';
import 'package:sharing_taxi/dump/from_start_screen.dart';
import 'package:sharing_taxi/services/networking.dart';

class LineString {
  LineString(this.lineString);
  List<dynamic> lineString;
}

class SubmitJourneyScreen extends StatefulWidget {
  final double? startLat;
  final double? startLng;
  final double? endLat;
  final double? endLng;
  final String? startAddress;
  final String? endAddress;
  final String? placeName;
  final String? detail;

  const SubmitJourneyScreen({
    Key? key,
    @required this.startLat,
    @required this.startLng,
    @required this.endLat,
    @required this.endLng,
    @required this.startAddress,
    @required this.endAddress,
    @required this.placeName,
    @required this.detail,
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _SubmitJourneyScreenState createState() => _SubmitJourneyScreenState();
}

class _SubmitJourneyScreenState extends State<SubmitJourneyScreen> {
  String address = '';
  final Completer<GoogleMapController> _controller = Completer();
  final Set<Marker> _markers = {};
  // ignore: missing_required_param
  Journey journey = Journey();
  bool startState = true;
  String id = '';
  final formKey = GlobalKey<FormState>();
  TextEditingController startAddress = TextEditingController();
  TextEditingController endAddress = TextEditingController();
  TextEditingController placeName = TextEditingController();
  TextEditingController detail = TextEditingController();
  TextEditingController distance = TextEditingController();
  TextEditingController cost = TextEditingController();
  TextEditingController person = TextEditingController();
  CollectionReference journeysCollection =
      FirebaseFirestore.instance.collection("journeys");

  CollectionReference passengersCollection =
      FirebaseFirestore.instance.collection("passengers");

  final CameraPosition _kGooglePlex = const CameraPosition(
    target: LatLng(0, 0),
    zoom: 10,
  );

  bool isProcessing = false;

  String positions = '';

  // double findDistance() {
  //   double distance = Geolocator.distanceBetween(
  //       widget.startLat as double,
  //       widget.startLng as double,
  //       widget.endLat as double,
  //       widget.endLng as double);
  //   return double.parse((distance / 1000).toStringAsFixed(2));
  // }

  double calculateCost(distance) {
    return (distance * 8).ceil().toDouble();
  }

  // costDistance() async {
  //   journey.distance = await findDistance();
  //   distance.text = "${journey.distance} km";
  //   //journey.cost = await calculateCost(journey.distance);
  //   double costtmp = (journey.distance! * 8).ceil().toDouble();
  //   cost.text = "${calculateCost(journey.distance)} ฿";
  // }

  final List<LatLng> polyPoints = [];
  final Set<Polyline> polyLines = {};
  double distanceFromJSON = 0;

  void getJsonData() async {
    // Create an instance of Class NetworkHelper which uses http package
    // for requesting data to the server and receiving response as JSON format

    NetworkHelper network = NetworkHelper(
        startLat: widget.startLat as double,
        startLng: widget.startLng as double,
        endLat: widget.endLat as double,
        endLng: widget.endLng as double);

    try {
      // getData() returns a json Decoded data
      var data = await network.getData();
      // We can reach to our desired JSON data manually as following
      LineString ls =
          LineString(data['features'][0]['geometry']['coordinates']);

      for (int i = 0; i < ls.lineString.length; i++) {
        polyPoints.add(LatLng(ls.lineString[i][1], ls.lineString[i][0]));
      }

      var distancetmp =
          data['features'][0]['properties']['summary']['distance'];
      setState(() {
        distanceFromJSON =
            double.parse((distancetmp / 1000).toStringAsFixed(2));
        journey.distance = distanceFromJSON;
        distance.text = "${journey.distance} km";
        double costtmp = (journey.distance! * 8).ceil().toDouble();
        cost.text = "${calculateCost(journey.distance)} ฿";
        journey.cost = costtmp;
      });

      setPolyLines();
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
    setState(() {});
  }

  setMarkers() {
    _markers.add(Marker(
      markerId: const MarkerId('start'),
      position: LatLng(widget.startLat as double, widget.startLng as double),
      //infoWindow: InfoWindow(title: address)
    ));

    _markers.add(Marker(
      markerId: const MarkerId('end'),
      position: LatLng(widget.endLat as double, widget.endLng as double),
    ));
    setState(() {});
  }

  getPosition() async {
    final GoogleMapController controller = await _controller.future;
    final lat = ((widget.startLat as double) + (widget.endLat as double)) / 2;
    final lng = ((widget.startLng as double) + (widget.endLng as double)) / 2;
    CameraPosition kGooglePlex = CameraPosition(
      target: LatLng(lat, lng),
      zoom: 10,
    );
    controller.animateCamera(CameraUpdate.newCameraPosition(kGooglePlex));
    setState(() {});
  }

  @override
  void initState() {
    // ignore: todo
    // TODO: implement initState
    super.initState();
    journey.startLat = widget.startLat;
    journey.startLng = widget.startLng;
    journey.endLat = widget.endLat;
    journey.endLng = widget.endLng;
    journey.startAddress = widget.startAddress;
    journey.endAddress = widget.endAddress;
    startAddress.text = widget.startAddress!;
    endAddress.text = widget.endAddress!;
    journey.placeName = widget.placeName;
    journey.detail = widget.detail;
    placeName.text = journey.placeName!;
    detail.text = journey.detail!;

    setState(() {});

    //costDistance();
    setMarkers();
    getJsonData();
    getPosition();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor:
            Colors.white, //const Color.fromARGB(255, 241, 243, 244),
        elevation: 0,
        title: const Text('Summary'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      bottomNavigationBar: BottomAppBar(
        notchMargin: 1,
        shape: const CircularNotchedRectangle(),
        color: Colors.orangeAccent,
        child: IconTheme(
          data: IconThemeData(color: Theme.of(context).colorScheme.onPrimary),
          child: Row(
            children: const [
              SizedBox(
                height: 30,
              )
            ],
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 10, right: 2),
        child: SizedBox(
          width: MediaQuery.of(context).size.height * 0.1,
          height: MediaQuery.of(context).size.height * 0.1,
          child: FloatingActionButton(
            onPressed: () async {
              if (isProcessing == true) {
                Fluttertoast.showToast(
                    msg: "Your journey creation is in process",
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIosWeb: 10);
              } else if (formKey.currentState!.validate()) {
                formKey.currentState?.save();

                try {
                  isProcessing = true;
                  await journeysCollection.add({
                    "endLat": journey.endLat,
                    "endLng": journey.endLng,
                    "endAddress": journey.endAddress,
                    "placeName": journey.placeName,
                    "status": journey.person == 1
                        ? 'waiting_driver'
                        : 'waiting_passenger',
                    "person": journey.person,
                    "creator": auth.currentUser!.uid,
                    "driver": ' ',
                    "timestamp": Timestamp.now(),
                    "cost": journey.person == 1 ? journey.cost : null,
                  }).then((value) async {
                    await value
                        .collection("passenger_s")
                        .doc(auth.currentUser!.uid)
                        .set({
                      "startLat": journey.startLat,
                      "startLng": journey.startLng,
                      "startAddress": journey.startAddress,
                      "detail": journey.detail,
                      "distance": journey.distance,
                      "cost": journey.person == 1 ? journey.cost : null,
                      "status": 'waiting',
                      "timestamp": Timestamp.now(),
                    });
                    await value.update({"id": value.id});

                    await passengersCollection
                        .doc(auth.currentUser!.uid)
                        .collection('journey_s')
                        .doc(value.id)
                        .set({
                      "timestamp": Timestamp.now(),
                    });

                    await passengersCollection
                        .doc(auth.currentUser!.uid)
                        .update({'isFree': false, 'currentJourney': value.id});
                    id = value.id;
                  }).then((value) {
                    isProcessing = false;
                    Fluttertoast.showToast(
                        msg: "Success",
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 10);

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
            },
            backgroundColor: Colors.deepOrange,
            child: Icon(
              Icons.check,
              size: MediaQuery.of(context).size.height * 0.05,
              color: Colors.white,
            ),
          ),
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          child: SafeArea(
            child: Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.fromLTRB(0, 25, 0, 0),
                    color: Colors.white,
                    height: MediaQuery.of(context).size.height * 0.25,
                    width: MediaQuery.of(context).size.width * 0.9,
                    child: GoogleMap(
                      initialCameraPosition: _kGooglePlex,
                      mapType: MapType.normal,
                      myLocationButtonEnabled: true,
                      myLocationEnabled: true,
                      markers: Set<Marker>.of(_markers),
                      polylines: polyLines,
                      onTap: (latLng) async {},
                      onMapCreated: (GoogleMapController controller) {
                        _controller.complete(controller);
                      },
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                    width: MediaQuery.of(context).size.width * 0.9,
                    child: Form(
                      key: formKey,
                      child: Column(
                        children: [
                          TextFormField(
                              maxLines: 1,
                              onSaved: (String? placeName) {
                                journey.placeName = placeName;
                              },
                              controller: placeName,
                              validator: RequiredValidator(
                                  errorText: 'Please input place name.'),
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.all(10),
                                fillColor:
                                    const Color.fromARGB(180, 255, 255, 255),
                                label: const Text(
                                    'place name* (make your fellow find you easier)'),
                                //icon: Icon(Icons.place,size: 30,),
                                prefixIcon: const Icon(
                                  Icons.apartment,
                                  size: 30,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                    width: 1,
                                    style: BorderStyle.none,
                                  ),
                                ),
                                filled: true,
                              )),
                          const SizedBox(height: 20),
                          TextField(
                              readOnly: true,
                              controller: startAddress,
                              decoration: InputDecoration(
                                label: const Text('from'),
                                //icon: Icon(Icons.place,size: 30,),
                                prefixIcon: const Icon(
                                  Icons.place,
                                  size: 30,
                                ),
                                contentPadding: const EdgeInsets.all(5.0),
                                fillColor:
                                    const Color.fromARGB(180, 255, 255, 255),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                    width: 1,
                                    style: BorderStyle.none,
                                  ),
                                ),
                                filled: true,
                              )),
                          const SizedBox(
                            height: 15,
                          ),
                          TextField(
                              maxLines: 1,
                              readOnly: true,
                              controller: endAddress,
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.all(5),
                                fillColor:
                                    const Color.fromARGB(180, 255, 255, 255),
                                label: const Text('to'),
                                //icon: Icon(Icons.place,size: 30,),
                                prefixIcon: const Icon(
                                  Icons.place,
                                  size: 30,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                    width: 1,
                                    style: BorderStyle.none,
                                  ),
                                ),
                                filled: true,
                              )),
                          const SizedBox(
                            height: 15,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.43,
                                child: TextField(
                                    enableInteractiveSelection: false,
                                    maxLines: 1,
                                    readOnly: true,
                                    controller: distance,
                                    decoration: InputDecoration(
                                      contentPadding: const EdgeInsets.all(5),
                                      fillColor: const Color.fromARGB(
                                          180, 255, 255, 255),
                                      label: const Text('distance'),
                                      prefixIcon: const Icon(
                                        Icons.numbers,
                                        size: 30,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: const BorderSide(
                                          width: 1,
                                          style: BorderStyle.none,
                                        ),
                                      ),
                                      filled: true,
                                    )),
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.43,
                                child: TextFormField(
                                    keyboardType: TextInputType.number,
                                    validator: MultiValidator([
                                      RequiredValidator(
                                          errorText:
                                              "passenger amount required*"),
                                      PatternValidator(r'^[1-3]{1}$',
                                          errorText: "allowed 1-3 person")
                                    ]),
                                    maxLines: 1,
                                    controller: person,
                                    onSaved: (String? person) {
                                      journey.person =
                                          int.parse(person.toString());
                                    },
                                    decoration: InputDecoration(
                                      contentPadding: const EdgeInsets.all(5),
                                      fillColor: const Color.fromARGB(
                                          180, 255, 255, 255),
                                      label: const Text('passenger amount*'),
                                      prefixIcon: const Icon(
                                        Icons.people_alt,
                                        size: 30,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: const BorderSide(
                                          width: 1,
                                          style: BorderStyle.none,
                                        ),
                                      ),
                                      filled: true,
                                    )),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          TextField(
                              enableInteractiveSelection: false,
                              maxLines: 1,
                              readOnly: true,
                              controller: cost,
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.all(5),
                                fillColor:
                                    const Color.fromARGB(180, 255, 255, 255),
                                label: const Text('cost'),
                                prefixIcon: const Icon(
                                  Icons.attach_money,
                                  size: 30,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                    width: 1,
                                    style: BorderStyle.none,
                                  ),
                                ),
                                filled: true,
                              )),
                          const SizedBox(
                            height: 15,
                          ),
                          TextFormField(
                              maxLines: 3,
                              onSaved: (String? detail) {
                                journey.detail = detail;
                              },
                              controller: detail,
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.all(10),
                                fillColor:
                                    const Color.fromARGB(180, 255, 255, 255),
                                label: const Text('pick-up location detail'),
                                //icon: Icon(Icons.place,size: 30,),
                                prefixIcon: const Icon(
                                  Icons.chat_bubble,
                                  size: 30,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
