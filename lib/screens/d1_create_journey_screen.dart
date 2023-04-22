import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:geolocator/geolocator.dart';
//import 'package:geocoding/geocoding.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sharing_taxi/main.dart';
import 'package:sharing_taxi/models/journey.dart';
import 'package:sharing_taxi/screens/d1_submit_journey_screen.dart';
import 'package:sharing_taxi/services/networking.dart';

class CreateJourneyScreen extends StatefulWidget {
  const CreateJourneyScreen({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _CreateJourneyScreenState createState() => _CreateJourneyScreenState();
}

class _CreateJourneyScreenState extends State<CreateJourneyScreen> {
  String address = '';
  final Completer<GoogleMapController> _controller = Completer();
  final Set<Marker> _markers = {};
  final Set<Polyline> _polyline = {};
  // ignore: missing_required_param
  Journey journey = Journey();
  bool startState = true;
  TextEditingController startAddress = TextEditingController();
  TextEditingController endAddress = TextEditingController();
  final formKey = GlobalKey<FormState>();
  final CameraPosition _kGooglePlex = const CameraPosition(
    target: LatLng(14.980897212188575, 102.07651271534304),
    zoom: 14,
  );
  bool startSearch = false;
  bool endSearch = false;
  bool startX = false;
  bool endX = false;
  bool startFav = true;
  bool endFav = true;
  double currentLat = 0;
  double currentLng = 0;

  final FocusNode startTextfieldNode = FocusNode();
  final FocusNode endTextfieldNode = FocusNode();

  Future<Position> _getUserCurrentLocation() async {
    await Geolocator.requestPermission()
        .then((value) {})
        .onError((error, stackTrace) {
      // ignore: avoid_print
      print(error.toString());
    });

    return await Geolocator.getCurrentPosition();
  }

  myLocationFromLatLng(lat, lng) async {
    MyLocationFromLatLng autocomplete =
        MyLocationFromLatLng(lat: lat, lng: lng);

    try {
      // getData() returns a json Decoded data
      var data = await autocomplete.getData();

      address = data['features'][0]['properties']['label'];
      //placeName.text = data['features'][0]['properties']['name'];
      return address;
    } catch (e) {
      return e.toString();
    }
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
        zoom: 17,
      );
      controller.animateCamera(CameraUpdate.newCameraPosition(kGooglePlex));

      //journey.startLat = value.latitude;
      //journey.startLng = value.longitude;
      // journey.startAddress =
      //     await myLocationFromLatLng(value.latitude, value.longitude);
      // startAddress.text = journey.startAddress.toString();
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
    journey.placeName = '';
    journey.detail = '';
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
        title: const Text('Create Journey'),
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
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 15),
        child: SizedBox(
            width: MediaQuery.of(context).size.height * 0.1,
            height: MediaQuery.of(context).size.height * 0.1,
            child: FloatingActionButton(
              onPressed: () {
                if (journey.startLat == null) {
                  Fluttertoast.showToast(
                      msg: "Please choose your\npick-up location.",
                      textColor: Colors.white,
                      backgroundColor: Colors.red.shade600,
                      fontSize: 17,
                      gravity: ToastGravity.CENTER,
                      timeInSecForIosWeb: 7);
                } else if (journey.endLat == null) {
                  Fluttertoast.showToast(
                      msg: "Please choose your\ndestination location.",
                      textColor: Colors.white,
                      backgroundColor: Colors.red.shade600,
                      fontSize: 17,
                      gravity: ToastGravity.CENTER,
                      timeInSecForIosWeb: 7);
                } else if (formKey.currentState!.validate()) {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return SubmitJourneyScreen(
                      startLat: journey.startLat,
                      startLng: journey.startLng,
                      endLat: journey.endLat,
                      endLng: journey.endLng,
                      startAddress: journey.startAddress,
                      endAddress: journey.endAddress,
                      placeName: journey.placeName,
                      detail: journey.detail,
                    );
                  }));
                }
              },
              backgroundColor: Colors.deepOrange,
              child: const Icon(Icons.arrow_forward,
                  size: 40, color: Colors.white),
            )),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 125.0),
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
                    if (startState == true) {
                      _markers.add(Marker(
                        markerId: const MarkerId('start'),
                        position: LatLng(latLng.latitude, latLng.longitude),
                        //infoWindow: InfoWindow(title: address)
                      ));
                      final GoogleMapController controller =
                          await _controller.future;
                      CameraPosition kGooglePlex = CameraPosition(
                        target: LatLng(latLng.latitude, latLng.longitude),
                        zoom: 17,
                      );
                      controller.animateCamera(
                          CameraUpdate.newCameraPosition(kGooglePlex));

                      journey.startLat = latLng.latitude;
                      journey.startLng = latLng.longitude;
                      journey.startAddress = await myLocationFromLatLng(
                          latLng.latitude, latLng.longitude);
                      startAddress.text = journey.startAddress.toString();
                      startX = true;
                      setState(() {});
                    } else if (startState == false) {
                      _markers.add(Marker(
                        markerId: const MarkerId('end'),
                        position: LatLng(latLng.latitude, latLng.longitude),
                        //infoWindow: InfoWindow(title: address)
                      ));
                      final GoogleMapController controller =
                          await _controller.future;
                      CameraPosition kGooglePlex = CameraPosition(
                        target: LatLng(latLng.latitude, latLng.longitude),
                        zoom: 17,
                      );
                      controller.animateCamera(
                          CameraUpdate.newCameraPosition(kGooglePlex));

                      journey.endLat = latLng.latitude;
                      journey.endLng = latLng.longitude;
                      journey.endAddress = await myLocationFromLatLng(
                          latLng.latitude, latLng.longitude);
                      endAddress.text = journey.endAddress.toString();
                      endX = true;
                      setState(() {});
                    }
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
                // if (placeList.isNotEmpty) {
                //   if (startState) {
                //     startAddress.text = '';
                //   } else if (!startState) {
                //     endAddress.text = '';
                //   }
                // }

                setState(() {
                  startSearch = false;
                  endSearch = false;
                  placeList.clear();
                  savedList.clear();
                });
              },
              child: Material(
                elevation: 4,
                borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20)),
                child: Container(
                  width: double.infinity,
                  height: 130,
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
                child: Container(
                  padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          Row(
                            children: [
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.1,
                                child: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        startState = true;
                                        FocusScope.of(context).unfocus();
                                        startSearch = false;
                                        endSearch = false;
                                        placeList.clear();
                                        savedList.clear();
                                      });
                                    },
                                    icon: Icon(
                                      Icons.place,
                                      size: 30,
                                      color: startState
                                          ? Colors.orange
                                          : Colors.grey,
                                    )),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: TextFormField(
                                    //autofocus: true,
                                    maxLines: 1,
                                    onTap: () {
                                      placeList.clear();
                                      startState = true;
                                      startSearch = true;
                                      endSearch = false;
                                      startState ? null : placeList.clear();
                                      savedList.clear();
                                      setState(() {});
                                      if (startAddress.text != '') {
                                        myAutocomplete(startAddress.text);
                                      }
                                    },
                                    onChanged: (value) async {
                                      await myAutocomplete(value);
                                    },
                                    controller: startAddress,
                                    focusNode: startTextfieldNode,
                                    validator: RequiredValidator(
                                        errorText: "Please choose location"),
                                    decoration: InputDecoration(
                                      label: const Text('From'),
                                      contentPadding: const EdgeInsets.fromLTRB(
                                          10, 10, 50, 10),
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
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Align(
                                alignment: Alignment.centerRight,
                                child: startX
                                    ? IconButton(
                                        padding: EdgeInsets.zero,
                                        onPressed: () {
                                          setState(() {
                                            placeList.clear();
                                            savedList.clear();
                                            startAddress.text = '';
                                            journey.startLat = null;
                                            journey.startLng = null;

                                            startX = false;
                                            _markers.removeWhere((marker) =>
                                                marker.markerId.value ==
                                                "start");
                                          });
                                        },
                                        icon: Icon(Icons.close,
                                            color: Colors.grey[600], size: 28))
                                    : SizedBox(
                                        width: 25,
                                        child: IconButton(
                                            padding: EdgeInsets.zero,
                                            onPressed: () async {
                                              FocusScope.of(context)
                                                  .requestFocus(
                                                      startTextfieldNode);
                                              startSearch = true;
                                              savedList.clear();
                                              if (startAddress
                                                  .text.isNotEmpty) {
                                                placeList.clear();

                                                await myAutocomplete(
                                                    startAddress.text);
                                              } else {
                                                placeList.clear();
                                              }
                                            },
                                            icon: Icon(Icons.search,
                                                color: startSearch
                                                    ? Colors.orange
                                                    : Colors.grey[600],
                                                size: 28)),
                                      ),
                              ),
                              startX
                                  ? const SizedBox(width: 0, height: 0)
                                  : IconButton(
                                      onPressed: () async {
                                        placeList.clear();
                                        savedList.clear();
                                        getSavedList();
                                        setState(() {
                                          startSearch = false;
                                          startTextfieldNode.unfocus();
                                          endTextfieldNode.unfocus();
                                          startState = true;
                                          endSearch = false;
                                        });
                                      },
                                      icon: Icon(Icons.favorite,
                                          color: (savedList.isNotEmpty &&
                                                  startState)
                                              ? Colors.orange
                                              : Colors.grey[600],
                                          size: 28)),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Stack(
                        children: [
                          Row(
                            children: [
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.1,
                                child: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        startState = false;
                                      });
                                      FocusScope.of(context).unfocus();
                                      startSearch = false;
                                      endSearch = false;
                                      placeList.clear();
                                      savedList.clear();
                                    },
                                    icon: Icon(
                                      Icons.place,
                                      size: 30,
                                      color: !startState
                                          ? Colors.orange
                                          : Colors.grey,
                                    )),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: TextFormField(
                                    maxLines: 1,
                                    onTap: () {
                                      placeList.clear();

                                      startState = false;
                                      endSearch = true;
                                      startSearch = false;
                                      !startState ? null : placeList.clear();
                                      savedList.clear();
                                      setState(() {});
                                      if (endAddress.text != '') {
                                        myAutocomplete(endAddress.text);
                                      }
                                    },
                                    onChanged: (value) async {
                                      await myAutocomplete(value);
                                    },
                                    controller: endAddress,
                                    focusNode: endTextfieldNode,
                                    validator: RequiredValidator(
                                        errorText: "Please choose location"),
                                    decoration: InputDecoration(
                                      contentPadding: const EdgeInsets.fromLTRB(
                                          10, 10, 50, 10),
                                      fillColor: const Color.fromARGB(
                                          180, 255, 255, 255),
                                      label: const Text('To'),
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Align(
                                alignment: Alignment.centerRight,
                                child: endX
                                    ? IconButton(
                                        padding: EdgeInsets.zero,
                                        onPressed: () {
                                          setState(() {
                                            placeList.clear();
                                            savedList.clear();
                                            endAddress.text = '';
                                            journey.endLat = null;
                                            journey.endLng = null;
                                            endSearch = false;
                                            endFav = false;

                                            endX = false;
                                            _markers.removeWhere((marker) =>
                                                marker.markerId.value == "end");
                                          });
                                        },
                                        icon: Icon(Icons.close,
                                            color: Colors.grey[600], size: 28))
                                    : SizedBox(
                                        width: 25,
                                        child: IconButton(
                                            padding: EdgeInsets.zero,
                                            onPressed: () async {
                                              setState(() {
                                                endSearch = true;
                                                FocusScope.of(context)
                                                    .requestFocus(
                                                        endTextfieldNode);
                                                startSearch = false;
                                                startState = false;
                                                savedList.clear();
                                              });
                                              if (startAddress
                                                  .text.isNotEmpty) {
                                                placeList.clear();

                                                await myAutocomplete(
                                                    startAddress.text);
                                              } else {
                                                placeList.clear();
                                              }
                                            },
                                            icon: Icon(Icons.search,
                                                color: endSearch
                                                    ? Colors.orange
                                                    : Colors.grey[600],
                                                size: 28)),
                                      ),
                              ),
                              endX
                                  ? const SizedBox(width: 0, height: 0)
                                  : IconButton(
                                      onPressed: () async {
                                        setState(() {
                                          startSearch = false;
                                          startState = false;
                                          endSearch = false;
                                          endTextfieldNode.unfocus();
                                          startTextfieldNode.unfocus();
                                        });
                                        placeList.clear();
                                        savedList.clear();
                                        getSavedList();
                                      },
                                      icon: Icon(Icons.favorite,
                                          color: (savedList.isNotEmpty &&
                                                  !startState)
                                              ? Colors.orange
                                              : Colors.grey[600],
                                          size: 28)),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            placeList.isNotEmpty
                ? Padding(
                    padding: startState
                        ? const EdgeInsets.fromLTRB(70, 50, 20, 0)
                        : const EdgeInsets.fromLTRB(70, 110, 20, 0),
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
                                        offset: const Offset(
                                            0, 3), // changes position of shadow
                                      ),
                                    ],
                                  ),
                                  child: ListTile(
                                    onTap: () async {
                                      FocusScope.of(context).unfocus();

                                      _markers.add(Marker(
                                        markerId: startState
                                            ? const MarkerId('start')
                                            : const MarkerId('end'),
                                        position: LatLng(
                                            placeList[index]['geometry']
                                                    ['coordinates'][1]
                                                .toDouble(),
                                            placeList[index]['geometry']
                                                    ['coordinates'][0]
                                                .toDouble()),
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
                                        zoom: 17,
                                      );
                                      controller.animateCamera(
                                          CameraUpdate.newCameraPosition(
                                              kGooglePlex));

                                      if (startState) {
                                        setState(() {
                                          journey.startLat = placeList[index]
                                                  ['geometry']['coordinates'][1]
                                              .toDouble();
                                          journey.startLng = placeList[index]
                                                  ['geometry']['coordinates'][0]
                                              .toDouble();
                                          journey.startAddress =
                                              placeList[index]['properties']
                                                  ['label'];
                                          startAddress.text =
                                              journey.startAddress.toString();
                                          journey.detail = '';

                                          startX = true;
                                        });
                                      } else if (!startState) {
                                        setState(() {
                                          journey.endLat = placeList[index]
                                                  ['geometry']['coordinates'][1]
                                              .toDouble();
                                          journey.endLng = placeList[index]
                                                  ['geometry']['coordinates'][0]
                                              .toDouble();
                                          journey.endAddress = placeList[index]
                                              ['properties']['label'];
                                          endAddress.text =
                                              journey.endAddress.toString();
                                          journey.placeName = placeList[index]
                                              ['properties']['name'];
                                          endX = true;
                                        });
                                      }
                                      setState(() {
                                        placeList.clear();
                                      });

                                      setState(() {
                                        placeList.clear();
                                      });
                                    },
                                    leading: const Icon(Icons.location_city),
                                    title: Text(
                                        placeList[index]['properties']['name']),
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

            savedList.isNotEmpty
                ? Padding(
                    padding: startState
                        ? const EdgeInsets.fromLTRB(70, 50, 20, 0)
                        : const EdgeInsets.fromLTRB(70, 110, 20, 0),
                    child: Container(
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
                                    borderRadius: BorderRadius.circular(5),
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
                                  child: ListTile(
                                    onTap: () async {
                                      FocusScope.of(context).unfocus();

                                      _markers.add(Marker(
                                        markerId: startState
                                            ? const MarkerId('start')
                                            : const MarkerId('end'),
                                        position: LatLng(
                                            savedList[index]['latitude']
                                                .toDouble(),
                                            savedList[index]['longitude']
                                                .toDouble()),
                                      ));
                                      final GoogleMapController controller =
                                          await _controller.future;
                                      CameraPosition kGooglePlex =
                                          CameraPosition(
                                        target: LatLng(
                                            savedList[index]['latitude']
                                                .toDouble(),
                                            savedList[index]['longitude']
                                                .toDouble()),
                                        zoom: 17,
                                      );
                                      controller.animateCamera(
                                          CameraUpdate.newCameraPosition(
                                              kGooglePlex));

                                      if (startState) {
                                        setState(() {
                                          journey.startLat = savedList[index]
                                                  ['latitude']
                                              .toDouble();
                                          journey.startLng = savedList[index]
                                                  ['longitude']
                                              .toDouble();
                                          journey.startAddress =
                                              savedList[index]['address'];
                                          startAddress.text =
                                              journey.startAddress.toString();
                                          journey.detail =
                                              savedList[index]['detail'];
                                          startX = true;
                                        });
                                      } else if (!startState) {
                                        setState(() {
                                          journey.endLat = savedList[index]
                                                  ['latitude']
                                              .toDouble();
                                          journey.endLng = savedList[index]
                                                  ['longitude']
                                              .toDouble();
                                          journey.endAddress =
                                              savedList[index]['address'];
                                          endAddress.text =
                                              journey.endAddress.toString();
                                          journey.placeName =
                                              savedList[index]['placeName'];
                                          endX = true;
                                        });
                                      }
                                      setState(() {
                                        savedList.clear();
                                      });

                                      setState(() {
                                        savedList.clear();
                                      });
                                    },
                                    leading: const Icon(Icons.location_city),
                                    title: Text(savedList[index]['placeName']),
                                    subtitle: Text(savedList[index]['address']),
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
            // Padding(
            //   padding: const EdgeInsets.only(bottom: 17),
            //   child: Align(
            //     alignment: Alignment.bottomCenter,
            //     child: SizedBox(
            //       height: 50,
            //       width: MediaQuery.of(context).size.width * 0.5,
            //       child: ElevatedButton(
            //         onPressed: () {
            //           if (formKey.currentState!.validate()) {
            //             Navigator.push(context,
            //                 MaterialPageRoute(builder: (context) {
            //               return SubmitJourneyScreen(
            //                   startLat: journey.startLat,
            //                   startLng: journey.startLng,
            //                   endLat: journey.endLat,
            //                   endLng: journey.endLng,
            //                   startAddress: journey.startAddress,
            //                   endAddress: journey.endAddress);
            //             }));
            //           }
            //         },
            //         style: ButtonStyle(
            //             //elevation: MaterialStateProperty.all(2),
            //             backgroundColor:
            //                 MaterialStateProperty.all(Colors.black),
            //             shape:
            //                 MaterialStateProperty.all<RoundedRectangleBorder>(
            //                     const RoundedRectangleBorder(
            //               borderRadius: BorderRadius.all(Radius.circular(20)),
            //               //side: BorderSide(color: Colors.red)
            //             ))),
            //         child: Row(
            //           mainAxisAlignment: MainAxisAlignment.center,
            //           children: [
            //             Text("NEXT  ",
            //                 style: GoogleFonts.cairo(
            //                     fontSize: 18,
            //                     //fontWeight: FontWeight.w400,
            //                     color: Colors.white)),
            //             const Icon(
            //               Icons.arrow_forward,
            //               color: Colors.white,
            //             )
            //           ],
            //         ),
            //       ),
            //     ),
            //   ),
            // )
          ],
        ),
      ),
    );
  }
}
