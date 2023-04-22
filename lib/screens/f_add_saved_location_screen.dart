import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sharing_taxi/main.dart';
import 'package:sharing_taxi/models/saved_locations.dart';
import 'package:sharing_taxi/screens/f_saved_location_screen.dart';
import 'package:sharing_taxi/services/networking.dart';

class AddSavedLocationScreen extends StatefulWidget {
  const AddSavedLocationScreen({
    Key? key,
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _AddSavedLocationScreenState createState() => _AddSavedLocationScreenState();
}

class _AddSavedLocationScreenState extends State<AddSavedLocationScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  final Set<Marker> _markers = {};
  final Set<Polyline> _polyline = {};
  // ignore: missing_required_param
  SavedLocation savedLocation = SavedLocation();
  TextEditingController address = TextEditingController();
  TextEditingController placeName = TextEditingController();
  TextEditingController detail = TextEditingController();
  String placeAddress = '';
  FocusNode addressNode = FocusNode();
  bool isX = false;
  bool isProcessing = false;
  CollectionReference passengerCollection =
      FirebaseFirestore.instance.collection("passengers");
  final formKey = GlobalKey<FormState>();

  final CameraPosition _kGooglePlex = const CameraPosition(
    target: LatLng(14.980897212188575, 102.07651271534304),
    zoom: 14,
  );
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

  void setMarker(LatLng point) {
    setState(() {
      _markers.add(Marker(markerId: const MarkerId('marker'), position: point));
    });
  }

  loadData() {
    _getUserCurrentLocation().then((value) async {
      final GoogleMapController controller = await _controller.future;
      CameraPosition kGooglePlex = CameraPosition(
        target: LatLng(value.latitude, value.longitude),
        zoom: 16,
      );
      controller.animateCamera(CameraUpdate.newCameraPosition(kGooglePlex));
      //await _getLocationName(value.latitude, value.longitude);
      savedLocation.latitude = value.latitude;
      savedLocation.longitude = value.longitude;
      savedLocation.address = address.text;
      setState(() {
        currentLat = value.latitude;
        currentLng = value.longitude;
      });
    });
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor:
            Colors.white, //const Color.fromARGB(255, 241, 243, 244),
        elevation: 0,
        title: const Text(
          'Add saved location',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 20,
          ),
        ),
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
        padding: const EdgeInsets.only(bottom: 15),
        child: SizedBox(
          width: MediaQuery.of(context).size.height * 0.1,
          height: MediaQuery.of(context).size.height * 0.1,
          child: FloatingActionButton(
            onPressed: () async {
              if (isProcessing == true) {
                Fluttertoast.showToast(
                    msg: "Your saved location is in process",
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIosWeb: 10);
              } else if (formKey.currentState!.validate()) {
                formKey.currentState?.save();
                try {
                  setState(() {
                    isProcessing = true;
                  });
                  await passengerCollection
                      .doc(auth.currentUser!.uid)
                      .collection('saved_locations')
                      .add({
                    "address": savedLocation.address,
                    "placeName": savedLocation.placeName,
                    "latitude": savedLocation.latitude,
                    "longitude": savedLocation.longitude,
                    "detail": savedLocation.detail,
                    "timestamp": Timestamp.now(),
                  }).then((value) {
                    setState(() {
                      isProcessing = false;
                    });
                    Fluttertoast.showToast(
                        msg: "Success",
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
        onTap: (() => FocusScope.of(context).unfocus()),
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
                        markerId: const MarkerId('location'),
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
                      savedLocation.placeName = placeName.text;

                      setState(() {});
                    },
                    onMapCreated: (GoogleMapController controller) {
                      _controller.complete(controller);
                    },
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  FocusScope.of(context).unfocus();
                  placeList.clear();
                },
                child: Material(
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
              ),
              Form(
                key: formKey,
                child: Center(
                  child: Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
                        width: MediaQuery.of(context).size.width * 0.9,
                        child: Column(
                          children: [
                            TextFormField(
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
                                  label: const Text('Location detail'),
                                  icon: const Icon(
                                    Icons.chat_bubble,
                                    size: 30,
                                    color: Colors.orangeAccent,
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
                              height: 10,
                            ),
                            Stack(
                              children: [
                                TextFormField(
                                    autofocus: true,
                                    maxLines: 1,
                                    //readOnly: true,
                                    controller: address,
                                    focusNode: addressNode,
                                    onChanged: (value) async {
                                      //print(value);

                                      await myAutocomplete(value);
                                    },
                                    validator: RequiredValidator(
                                        errorText: "Please choose location"),
                                    decoration: InputDecoration(
                                      label: const Text('Address'),
                                      //icon: Icon(Icons.place,size: 30,),
                                      icon: const Icon(
                                        Icons.location_pin,
                                        size: 30,
                                        color: Colors.orangeAccent,
                                      ),
                                      contentPadding: const EdgeInsets.fromLTRB(
                                          10, 10, 45, 10),
                                      fillColor: const Color.fromARGB(
                                          180, 255, 255, 255),
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
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: isX
                                      ? IconButton(
                                          onPressed: () {
                                            setState(() {
                                              placeList.clear();
                                              address.text = '';
                                              placeName.text = '';
                                              isX = false;
                                              _markers.removeWhere((marker) =>
                                                  marker.markerId.value ==
                                                  "location");
                                            });
                                          },
                                          icon: Icon(Icons.close,
                                              color: Colors.grey[600],
                                              size: 28))
                                      : IconButton(
                                          onPressed: () async {
                                            if (placeName.text.isNotEmpty) {
                                              placeList.clear();

                                              await myAutocomplete(
                                                  placeName.text);
                                              //print(placeName.text);
                                              //print(placeList);
                                            } else {
                                              placeList.clear();
                                            }
                                          },
                                          icon: Icon(Icons.search,
                                              color: addressNode.hasFocus
                                                  ? Colors.amber
                                                  : Colors.grey,
                                              size: 28)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              placeList.isNotEmpty
                  ? Padding(
                      padding: const EdgeInsets.fromLTRB(20, 180, 20, 0),
                      child: Container(
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
                                      borderRadius: BorderRadius.circular(5),
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
                                        placeName.text = placeList[index]
                                            ['properties']['name'];
                                        address.text = placeList[index]
                                            ['properties']['label'];

                                        _markers.add(Marker(
                                          markerId: const MarkerId('location'),
                                          position: LatLng(
                                              placeList[index]['geometry']
                                                      ['coordinates'][1]
                                                  .toDouble(),
                                              placeList[index]['geometry']
                                                      ['coordinates'][0]
                                                  .toDouble()),
                                          //infoWindow: InfoWindow(title: address)
                                        ));
                                        final GoogleMapController controller =
                                            await _controller.future;
                                        CameraPosition kGooglePlex =
                                            CameraPosition(
                                          target: LatLng(
                                              placeList[index]['geometry']
                                                      ['coordinates'][1]
                                                  .toDouble(),
                                              placeList[index]['geometry']
                                                      ['coordinates'][0]
                                                  .toDouble()),
                                          zoom: 16,
                                        );
                                        controller.animateCamera(
                                            CameraUpdate.newCameraPosition(
                                                kGooglePlex));

                                        setState(() {
                                          savedLocation.latitude =
                                              placeList[index]['geometry']
                                                      ['coordinates'][1]
                                                  .toDouble();
                                          savedLocation.longitude =
                                              placeList[index]['geometry']
                                                      ['coordinates'][0]
                                                  .toDouble();
                                          savedLocation.address = address.text;
                                          savedLocation.placeName =
                                              placeName.text;
                                          isX = true;

                                          placeList.clear();
                                        });
                                        setState(() {
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
          ),
        ),
      ),
    );
  }
}
