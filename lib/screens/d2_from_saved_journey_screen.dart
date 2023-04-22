import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sharing_taxi/main.dart';
import 'package:sharing_taxi/models/journey.dart';
import 'package:sharing_taxi/screens/d2_from_saved_submit_screen.dart';
import 'package:sharing_taxi/services/networking.dart';

class FromSavedJourneyScreen extends StatefulWidget {
  final double? endLat;
  final double? endLng;
  final String? endAddress;
  final String? detail;
  final String? placeName;

  const FromSavedJourneyScreen({
    Key? key,
    @required this.endLat,
    @required this.endLng,
    @required this.endAddress,
    @required this.detail,
    @required this.placeName,
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _FromSavedJourneyScreenState createState() => _FromSavedJourneyScreenState();
}

class _FromSavedJourneyScreenState extends State<FromSavedJourneyScreen> {
  String address = '';
  final Completer<GoogleMapController> _controller = Completer();
  final Set<Marker> _markers = {};
  final Set<Polyline> _polyline = {};
  // ignore: missing_required_param
  Journey journey = Journey();
  TextEditingController startAddress = TextEditingController();
  TextEditingController endAddress = TextEditingController();
  final formKey = GlobalKey<FormState>();
  final CameraPosition _kGooglePlex = const CameraPosition(
    target: LatLng(14.980897212188575, 102.07651271534304),
    zoom: 14,
  );
  double currentLat = 0;
  double currentLng = 0;
  bool isX = false;
  bool isFav = true;
  bool isSearch = false;
  final FocusNode textfieldNode = FocusNode();

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

  void setMarker(LatLng point) {
    setState(() {
      _markers.add(Marker(markerId: const MarkerId('marker'), position: point));
    });
  }

  loadData() {
    _getUserCurrentLocation().then((value) async {
      setState(() {
        currentLat = value.latitude;
        currentLng = value.longitude;
      });
    });
  }

  loadSavedLocation() async {
    _markers.add(Marker(
        markerId: const MarkerId('end'),
        position: LatLng(widget.endLat as double, widget.endLng as double),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueRose,
        )));

    final GoogleMapController controller = await _controller.future;
    CameraPosition kGooglePlex = CameraPosition(
      target: LatLng(widget.endLat as double, widget.endLng as double),
      zoom: 14,
    );
    controller.animateCamera(CameraUpdate.newCameraPosition(kGooglePlex));

    setState(() {});
  }

  @override
  void initState() {
    // ignore: todo
    // TODO: implement initState
    super.initState();
    journey.endLat = widget.endLat;
    journey.endLng = widget.endLng;
    //journey.detail = widget.detail;
    journey.placeName = widget.placeName;
    journey.endAddress = widget.endAddress;
    endAddress.text = journey.endAddress.toString();
    setState(() {});
    loadSavedLocation();

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
        title: const Text('Location'),
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
                } else if (formKey.currentState!.validate()) {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return FromSavedSubmitScreen(
                      startLat: journey.startLat,
                      startLng: journey.startLng,
                      endLat: journey.endLat,
                      endLng: journey.endLng,
                      startAddress: journey.startAddress,
                      endAddress: journey.endAddress,
                      detail: journey.detail,
                      placeName: journey.placeName,
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
                    _markers.add(Marker(
                      markerId: const MarkerId('start'),
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
                    startAddress.text = await myLocationFromLatLng(
                        latLng.latitude, latLng.longitude);
                    journey.startLat = latLng.latitude;
                    journey.startLng = latLng.longitude;
                    journey.startAddress = startAddress.text;
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
                // if (placeList.isNotEmpty) {
                //   startAddress.text = '';
                // }
                setState(() {
                  placeList.clear();
                  savedList.clear();
                  isSearch = false;
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
                                        // startState = true;
                                        FocusScope.of(context).unfocus();

                                        placeList.clear();
                                      });
                                    },
                                    icon: const Icon(
                                      Icons.place,
                                      size: 30,
                                      color: Colors.amber,
                                    )),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: TextFormField(
                                    //autofocus: true,
                                    maxLines: 1,
                                    controller: startAddress,
                                    focusNode: textfieldNode,
                                    onTap: () {
                                      savedList.clear();
                                      setState(() {
                                        isSearch = true;
                                      });
                                      if (startAddress.text != '') {
                                        myAutocomplete(startAddress.text);
                                      }
                                    },
                                    onChanged: (value) async {
                                      await myAutocomplete(value);
                                    },
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
                                            color: Colors.orange, width: 2.0),
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
                                child: isX
                                    ? IconButton(
                                        padding: EdgeInsets.zero,
                                        onPressed: () {
                                          setState(() {
                                            placeList.clear();
                                            savedList.clear();
                                            startAddress.text = '';
                                            journey.startLat = null;
                                            journey.startLng = null;
                                            journey.startAddress = null;

                                            isX = false;
                                            _markers.removeWhere((marker) =>
                                                marker.markerId.value ==
                                                "location");
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
                                                  .requestFocus(textfieldNode);
                                              savedList.clear();
                                              setState(() {
                                                isSearch = true;
                                              });
                                              // if (startAddress
                                              //     .text.isNotEmpty) {
                                              //   placeList.clear();

                                              //   await myAutocomplete(
                                              //       startAddress.text);
                                              // } else {
                                              //   placeList.clear();
                                              // }
                                            },
                                            icon: Icon(Icons.search,
                                                color: isSearch
                                                    ? Colors.orange
                                                    : Colors.grey[600],
                                                size: 28)),
                                      ),
                              ),
                              isX
                                  ? const SizedBox(width: 0, height: 0)
                                  : IconButton(
                                      onPressed: () async {
                                        placeList.clear();
                                        savedList.clear();
                                        textfieldNode.unfocus();
                                        setState(() {
                                          isSearch = false;
                                        });
                                        getSavedList();
                                      },
                                      icon: Icon(Icons.favorite,
                                          color: savedList.isNotEmpty
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
                      Row(
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.1,
                            child: IconButton(
                                onPressed: () {
                                  setState(() {
                                    // startState = true;
                                    FocusScope.of(context).unfocus();
                                    // startSearch = false;
                                    // endSearch = false;
                                    placeList.clear();
                                  });
                                },
                                icon: const Icon(
                                  Icons.place,
                                  size: 30,
                                  color: Color.fromARGB(255, 205, 37, 133),
                                )),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: TextFormField(
                                //autofocus: true,
                                maxLines: 1,
                                readOnly: true,
                                enabled: false,
                                controller: endAddress,
                                validator: RequiredValidator(
                                    errorText: "Please choose location"),
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.all(10),
                                  fillColor:
                                      const Color.fromARGB(180, 255, 255, 255),
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
                    ],
                  ),
                ),
              ),
            ),
            placeList.isNotEmpty
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(70, 50, 20, 0),
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

                                      startAddress.text = placeList[index]
                                          ['properties']['label'];

                                      _markers.add(Marker(
                                        markerId: const MarkerId('start'),
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
                                        journey.detail = '';
                                        journey.startLat = placeList[index]
                                                ['geometry']['coordinates'][1]
                                            .toDouble();
                                        journey.startLng = placeList[index]
                                                ['geometry']['coordinates'][0]
                                            .toDouble();
                                        journey.startAddress =
                                            startAddress.text;

                                        placeList.clear();
                                        isX = true;
                                        isSearch = false;
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
                    padding: const EdgeInsets.fromLTRB(70, 50, 20, 0),
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

                                      startAddress.text =
                                          savedList[index]['address'];

                                      _markers.add(Marker(
                                        markerId: const MarkerId('start'),
                                        position: LatLng(
                                            savedList[index]['latitude']
                                                .toDouble(),
                                            savedList[index]['longitude']
                                                .toDouble()),
                                        //infoWindow: InfoWindow(title: address)
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
                                        zoom: 16,
                                      );
                                      controller.animateCamera(
                                          CameraUpdate.newCameraPosition(
                                              kGooglePlex));

                                      setState(() {
                                        journey.startLat = savedList[index]
                                                ['latitude']
                                            .toDouble()
                                            .toDouble();
                                        journey.startLng = savedList[index]
                                                ['longitude']
                                            .toDouble();
                                        journey.startAddress =
                                            startAddress.text;
                                        journey.detail =
                                            savedList[index]['detail'];
                                        //journey.placeName =
                                        //   savedList[index]['placeName'];

                                        savedList.clear();
                                        isX = true;
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
            //               return FromSavedSubmitScreen(
            //                 startLat: journey.startLat,
            //                 startLng: journey.startLng,
            //                 endLat: journey.endLat,
            //                 endLng: journey.endLng,
            //                 startAddress: journey.startAddress,
            //                 endAddress: journey.endAddress,
            //                 detail: journey.detail,
            //                 placeName: journey.placeName,
            //               );
            //             }));
            //           }
            //         },
            //         style: ButtonStyle(
            //             //elevation: MaterialStateProperty.all(2),
            //             backgroundColor:
            //                 MaterialStateProperty.all(Colors.deepOrange),
            //             shape:
            //                 MaterialStateProperty.all<RoundedRectangleBorder>(
            //                     const RoundedRectangleBorder(
            //               borderRadius: BorderRadius.all(Radius.circular(50)),
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
