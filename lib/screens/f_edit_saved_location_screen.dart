import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sharing_taxi/main.dart';
import 'package:sharing_taxi/models/saved_locations.dart';
import 'package:sharing_taxi/screens/f_saved_location_screen.dart';
import 'package:sharing_taxi/services/networking.dart';

class EditSavedLocationScreen extends StatefulWidget {
  final String? id;
  const EditSavedLocationScreen({Key? key, @required this.id})
      : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _EditSavedLocationScreenState createState() =>
      _EditSavedLocationScreenState();
}

class _EditSavedLocationScreenState extends State<EditSavedLocationScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  final Set<Marker> _markers = {};
  final Set<Polyline> _polyline = {};
  // ignore: missing_required_param
  SavedLocation savedLocation = SavedLocation();
  TextEditingController address = TextEditingController();
  TextEditingController placeName = TextEditingController();
  TextEditingController detail = TextEditingController();
  String placeAddress = '';
  // ignore: missing_required_param
  final id = const EditSavedLocationScreen().id;
  //final auth = FirebaseAuth.instance;
  CollectionReference passengerCollection =
      FirebaseFirestore.instance.collection("passengers");
  final formKey = GlobalKey<FormState>();

  final CameraPosition _kGooglePlex = const CameraPosition(
    target: LatLng(14.980897212188575, 102.07651271534304),
    zoom: 14,
  );

  getSavedLocation() async {
    var data = await FirebaseFirestore.instance
        .collection('passengers')
        .doc(auth.currentUser!.uid)
        .collection('saved_locations')
        .doc(widget.id)
        .get();

    savedLocation.address = data['address'];
    savedLocation.detail = data['detail'];
    savedLocation.placeName = data['placeName'];
    savedLocation.timestamp = data['timestamp'];
    savedLocation.latitude = data['latitude'];
    savedLocation.longitude = data['longitude'];
    address.text = data['address'];
    placeName.text = data['placeName'];
    detail.text = data['detail'];

    _markers.add(Marker(
      markerId: const MarkerId('savedlocation'),
      position: LatLng(
          savedLocation.latitude as double, savedLocation.longitude as double),
    ));

    final GoogleMapController controller = await _controller.future;
    CameraPosition kGooglePlex = CameraPosition(
      target: LatLng(
          savedLocation.latitude as double, savedLocation.longitude as double),
      zoom: 16,
    );
    controller.animateCamera(CameraUpdate.newCameraPosition(kGooglePlex));

    setState(() {});
  }

  // _getLocationName(double lat, double lng) async {
  //   await placemarkFromCoordinates(lat, lng).then((value) {
  //     placeAddress =
  //         "${value[2].name} ${value[2].street} ${value[0].locality} ${value[0].subAdministrativeArea} ${value[0].administrativeArea} ${value[0].country} ${value[0].postalCode}";

  //     address.text = placeAddress;

  //     //ori_lng.text = value.longitude.toString();
  //     setState(() {});
  //   }).onError((error, stackTrace) {
  //     address.text = error.toString();
  //   });

  //   //List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
  //   //print(placemarks);
  //   //return placemarks[0].toString();
  // }

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

  void setMarker(LatLng point) {
    setState(() {
      _markers.add(Marker(markerId: const MarkerId('marker'), position: point));
    });
  }

  @override
  void initState() {
    // ignore: todo
    // TODO: implement initState
    super.initState();
    getSavedLocation();
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
        title: const Text('Edit saved location'),
      ),
      bottomNavigationBar: BottomAppBar(
        notchMargin: 2,
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
      floatingActionButtonLocation: FloatingActionButtonLocation.startDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 5),
        child: SizedBox(
          width: MediaQuery.of(context).size.height * 0.1,
          height: MediaQuery.of(context).size.height * 0.1,
          child: FloatingActionButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                formKey.currentState?.save();
                try {
                  //final auth = FirebaseAuth.instance;
                  await passengerCollection
                      .doc(auth.currentUser!.uid)
                      .collection('saved_locations')
                      .doc(widget.id)
                      .update({
                    "address": savedLocation.address,
                    "placeName": savedLocation.placeName,
                    "latitude": savedLocation.latitude,
                    "longitude": savedLocation.longitude,
                    "detail": savedLocation.detail,
                    "timestamp": Timestamp.now(),
                  }).then((value) {
                    Fluttertoast.showToast(
                        msg: "Edit Success",
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 10);
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (context) {
                      return const SavedLocationScreen();
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
            child: const Icon(Icons.check, size: 40, color: Colors.white),
          ),
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 180.0),
                child: Container(
                  color: Colors.white,
                  height: MediaQuery.of(context).size.height,
                  child: GoogleMap(
                    initialCameraPosition: _kGooglePlex,
                    mapType: MapType.normal,
                    myLocationButtonEnabled: true,
                    myLocationEnabled: true,
                    markers: Set<Marker>.of(_markers),
                    polylines: _polyline,
                    onTap: (latLng) async {
                      _markers.add(Marker(
                        markerId: const MarkerId('savedlocation'),
                        position: LatLng(latLng.latitude, latLng.longitude),
                        //infoWindow: InfoWindow(title: address)
                      ));
                      final GoogleMapController controller =
                          await _controller.future;
                      CameraPosition kGooglePlex = CameraPosition(
                        target: LatLng(latLng.latitude, latLng.longitude),
                        zoom: 16,
                      );
                      controller.animateCamera(
                          CameraUpdate.newCameraPosition(kGooglePlex));
                      //await _getLocationName(latLng.latitude, latLng.longitude);
                      await myLocationFromLatLng(
                          latLng.latitude, latLng.longitude);
                      savedLocation.latitude = latLng.latitude;
                      savedLocation.longitude = latLng.longitude;
                      savedLocation.address = address.text;
                      setState(() {});
                    },
                    onMapCreated: (GoogleMapController controller) {
                      _controller.complete(controller);
                    },
                  ),
                ),
              ),
              Material(
                elevation: 4,
                borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20)),
                child: Container(
                  width: double.infinity,
                  height: 185,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20)),
                  ),
                ),
              ),
              Form(
                key: formKey,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
                    width: MediaQuery.of(context).size.width * 0.9,
                    child: Column(
                      children: [
                        TextFormField(
                            autofocus: true,
                            maxLines: 1,
                            onSaved: (String? placeName) {
                              savedLocation.placeName = placeName;
                            },
                            controller: placeName,
                            validator: RequiredValidator(
                                errorText: "Please input location name"),
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.all(10),
                              fillColor:
                                  const Color.fromARGB(180, 255, 255, 255),
                              label: const Text('Display Name*'),
                              icon: const Icon(
                                Icons.apartment,
                                size: 30,
                                color: Colors.orangeAccent,
                              ),
                              // prefixIcon: const Icon(
                              //   Icons.apartment,
                              //   size: 30,
                              // ),
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
                          height: 10,
                        ),
                        TextFormField(
                            maxLines: 1,
                            onSaved: (String? detail) {
                              savedLocation.detail = detail;
                            },
                            controller: detail,
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.all(10),
                              fillColor:
                                  const Color.fromARGB(180, 255, 255, 255),
                              label: const Text('Detail'),
                              icon: const Icon(
                                Icons.chat_bubble,
                                size: 30,
                                color: Colors.orangeAccent,
                              ),
                              // prefixIcon: const Icon(
                              //   Icons.chat_bubble,
                              //   size: 30,
                              // ),
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
                          height: 10,
                        ),
                        TextFormField(
                            //autofocus: true,
                            maxLines: 1,
                            readOnly: true,
                            // onSaved: (String? start_name) {
                            //   journey.start_name = start_name;
                            // },
                            controller: address,
                            validator: RequiredValidator(
                                errorText: "Please choose location"),
                            decoration: InputDecoration(
                              label: const Text('Address'),
                              icon: const Icon(
                                Icons.location_pin,
                                size: 30,
                                color: Colors.orangeAccent,
                              ),
                              // prefixIcon: const Icon(
                              //   Icons.place,
                              //   size: 30,
                              // ),
                              contentPadding: const EdgeInsets.all(10),
                              fillColor:
                                  const Color.fromARGB(180, 255, 255, 255),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  width: 1,
                                  style: BorderStyle.none,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    color: Colors.amber, width: 2.0),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              filled: true,
                            )),
                      ],
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
}
