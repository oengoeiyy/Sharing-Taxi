import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sharing_taxi/models/journey.dart';
import 'package:sharing_taxi/dump/fake_home_screen.dart';
import 'package:sharing_taxi/services/location_service.dart';
import 'package:sharing_taxi/services/networking.dart';

class SubmitLocationScreen extends StatefulWidget {
  final double? ori_lat;
  final double? ori_lng;
  final double? des_lat;
  final double? des_lng;
  final String? type;
  const SubmitLocationScreen(
      {Key? key,
      @required this.ori_lat,
      @required this.ori_lng,
      @required this.des_lat,
      @required this.des_lng,
      @required this.type})
      : super(key: key);

  @override
  _SubmitLocationScreenState createState() => _SubmitLocationScreenState();
}

class _SubmitLocationScreenState extends State<SubmitLocationScreen> {
  TextEditingController _searchController = TextEditingController();
  String address = '';
  final Completer<GoogleMapController> _controller = Completer();
  final Future<FirebaseApp> firebase = Firebase.initializeApp();
  final auth = FirebaseAuth.instance;

  CollectionReference journeysCollection =
      FirebaseFirestore.instance.collection("journeys");

  CollectionReference passengersCollection =
      FirebaseFirestore.instance.collection("passengers");

  Future<Position> _getUserCurrentLocation() async {
    await Geolocator.requestPermission()
        .then((value) {})
        .onError((error, stackTrace) {
      print(error.toString());
    });

    return await Geolocator.getCurrentPosition();
  }

  final Set<Marker> _markers = {};
  //final List<Marker> _markers =  <Marker>[];
  final Set<Polyline> _polyline = {};

  Journey travel = Journey();
  final ori_lat = SubmitLocationScreen().ori_lat;
  final ori_lng = SubmitLocationScreen().ori_lng;
  final des_lat = SubmitLocationScreen().des_lat;
  final des_lng = SubmitLocationScreen().ori_lng;
  final type = SubmitLocationScreen().type;

  void setMarker(LatLng point) {
    setState(() {
      _markers.add(Marker(markerId: MarkerId('marker'), position: point));
    });
  }

  final List<LatLng> polyPoints = [];
  final Set<Polyline> polyLines = {};

  void getJsonData() async {
    // Create an instance of Class NetworkHelper which uses http package
    // for requesting data to the server and receiving response as JSON format

    NetworkHelper network = NetworkHelper(
        startLat: widget.ori_lat as double,
        startLng: widget.ori_lng as double,
        endLat: widget.des_lat as double,
        endLng: widget.des_lng as double);

    try {
      // getData() returns a json Decoded data
      var data = await network.getData();
      print('gggggggggggg');
      // We can reach to our desired JSON data manually as following
      LineString ls =
          LineString(data['features'][0]['geometry']['coordinates']);

      for (int i = 0; i < ls.lineString.length; i++) {
        polyPoints.add(LatLng(ls.lineString[i][1], ls.lineString[i][0]));
      }

      setPolyLines();
    } catch (e) {
      print(e);
    }
  }

  setPolyLines() {
    Polyline polyline = Polyline(
        polylineId: PolylineId("polyline"),
        color: Colors.red,
        width: 6,
        points: polyPoints,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        jointType: JointType.round);
    polyLines.add(polyline);
    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //_markers.addAll(list);
    //getJsonData();

    List<LatLng> latlng = [
      LatLng(widget.ori_lat as double, widget.ori_lng as double),
      LatLng(widget.des_lat as double, widget.des_lng as double)
    ];

    //double lat = (widget.ori_lat! + widget.des_lat!.toDouble()) / 2;
    //double lng = (widget.ori_lng! + widget.des_lng!.toDouble()) / 2;

    for (int i = 0; i < latlng.length; i++) {
      _markers.add(Marker(
        markerId: MarkerId(i.toString()),
        position: latlng[i],
        icon: BitmapDescriptor.defaultMarker,
      ));
      setState(() {});
    }

    // _polyline.add(Polyline(
    //     polylineId: PolylineId('1'), points: latlng, color: Colors.red));
  }

  Widget build(BuildContext context) {
    return FutureBuilder(
        future: firebase,
        builder: ((context, snapshot) {
          if (snapshot.hasError) {
            return Scaffold(
              appBar: AppBar(),
              body: Center(
                child: Text("${snapshot.error}"),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.done) {
            return Scaffold(
              //backgroundColor: Colors.red[200],
              appBar: AppBar(
                centerTitle: true,
                backgroundColor: const Color.fromARGB(255, 241, 243, 244),
                elevation: 2,
                title: const Text('Path Summary'),
              ),
              body: SafeArea(
                child: Column(
                  //alignment: Alignment.bottomCenter,
                  children: [
                    Container(
                      height: 400,
                      child: GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: LatLng(widget.des_lat as double,
                              widget.des_lng as double),
                          zoom: 14,
                        ),
                        mapType: MapType.normal,
                        myLocationButtonEnabled: true,
                        myLocationEnabled: true,
                        markers: Set<Marker>.of(_markers),
                        polylines: polyLines, //_polyline,
                        onMapCreated: (GoogleMapController controller) {
                          _controller.complete(controller);
                        },
                      ),
                    ),
                    Container(
                      color: Colors.white,
                      //height: 200,
                      width: double.infinity,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(10, 20, 10, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(
                              "Pick up Location : \n" +
                                  widget.ori_lat.toString() +
                                  "\n" +
                                  widget.ori_lng.toString(),
                              style: TextStyle(fontSize: 15),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Text(
                              "Desination Location : \n" +
                                  widget.des_lat.toString() +
                                  "\n" +
                                  widget.des_lng.toString(),
                              style: TextStyle(fontSize: 15),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: () async {
                                  if (widget.type == "des") {
                                    try {
                                      final auth = FirebaseAuth.instance;
                                      await journeysCollection.add({
                                        "des_lat": widget.des_lat,
                                        "des_lng": widget.des_lng,
                                        "type": widget.type,
                                        "status": 'waiting',
                                      }).then((value) async {
                                        await value
                                            .collection("passenger_s")
                                            .doc(auth.currentUser!.uid)
                                            .set({
                                          "ori_lat": widget.ori_lat,
                                          "ori_lng": widget.ori_lng,
                                        });

                                        await passengersCollection
                                            .doc(auth.currentUser!.uid)
                                            .collection('journey_s')
                                            .doc('${value.id}')
                                            .set({});
                                      }).then((value) {
                                        Fluttertoast.showToast(
                                            msg: "Please Wait!",
                                            gravity: ToastGravity.BOTTOM,
                                            timeInSecForIosWeb: 10);
                                        Navigator.pushReplacement(context,
                                            MaterialPageRoute(
                                                builder: (context) {
                                          return FakeHomeScreen();
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
                                  } else if (widget.type == "ori") {
                                    try {
                                      final auth = FirebaseAuth.instance;
                                      await journeysCollection.add({
                                        "ori_lat": widget.ori_lat,
                                        "ori_lng": widget.ori_lng,
                                        "type": widget.type,
                                        "status": 'waiting',
                                      }).then((value) async {
                                        await value
                                            .collection("passenger_s")
                                            .doc(auth.currentUser!.uid)
                                            .set({
                                          "des_lat": widget.des_lat,
                                          "des_lng": widget.des_lng,
                                        });
                                        await passengersCollection
                                            .doc(auth.currentUser!.uid)
                                            .collection('journey_s')
                                            .doc('${value.id}')
                                            .set({});
                                      }).then((value) {
                                        Fluttertoast.showToast(
                                            msg: "Please Wait!",
                                            gravity: ToastGravity.BOTTOM,
                                            timeInSecForIosWeb: 10);
                                        Navigator.pushReplacement(context,
                                            MaterialPageRoute(
                                                builder: (context) {
                                          return FakeHomeScreen();
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
                                style: ButtonStyle(
                                    //elevation:MaterialStateProperty.all(10),
                                    backgroundColor:
                                        MaterialStateProperty.all(Colors.red),
                                    overlayColor:
                                        MaterialStateProperty.all(Colors.amber),
                                    shape: MaterialStateProperty.all<
                                            RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20.0),
                                      //side: BorderSide(color: Colors.red)
                                    ))),
                                child: Text("Save",
                                    style: GoogleFonts.cairo(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.white)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            );
          }

          return Text("hi");
        }));
  }
}

class LineString {
  LineString(this.lineString);
  List<dynamic> lineString;
}
