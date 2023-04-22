import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
//import 'package:flutter_geocoder/geocoder.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sharing_taxi/models/journey.dart';
import 'package:sharing_taxi/services/location_service.dart';

class FastDriveScreen extends StatefulWidget {
  final double? lat;
  final double? lng;
  const FastDriveScreen({Key? key, @required this.lat, @required this.lng})
      : super(key: key);

  @override
  _FastDriveScreenState createState() => _FastDriveScreenState();
}

class _FastDriveScreenState extends State<FastDriveScreen> {
  //FastDriveScreen data = FastDriveScreen();

  TextEditingController _searchController = TextEditingController();
  String address = '';
  final Completer<GoogleMapController> _controller = Completer();

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

  List<LatLng> latlng = [
    LatLng(14.980897212188575, 102.07651271534304),
    LatLng(14.98170561708843, 102.0903636426428)
  ];

  static CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(14.980897212188575, 102.07651271534304),
    zoom: 16,
  );

  void setMarker(LatLng point) {
    setState(() {
      _markers.add(Marker(markerId: MarkerId('marker'), position: point));
    });
  }

  // final Set<Marker> list = {
  //   const Marker(
  //       markerId: MarkerId('1'),
  //       position: LatLng(14.980897212188575, 102.07651271534304),
  //       infoWindow: InfoWindow(title: 'The Mall')),
  //   const Marker(
  //       markerId: MarkerId('2'),
  //       position: LatLng(14.98170561708843, 102.0903636426428),
  //       infoWindow: InfoWindow(title: 'Terminal', snippet: 'yeah2')),
  // };
  // List<Marker> list = const [
  //   Marker(
  //       markerId: MarkerId('1'),
  //       position: LatLng(14.881657430951371, 102.02065328186208),
  //       infoWindow: InfoWindow(title: 'some Info ')),
  // ];

  loadData() {
    _getUserCurrentLocation().then((value) async {
      // _markers.add(Marker(
      //     markerId: const MarkerId('SomeId'),
      //     position: LatLng(value.latitude, value.longitude),
      //     infoWindow: InfoWindow(title: address)));

      final GoogleMapController controller = await _controller.future;
      CameraPosition _kGooglePlex = CameraPosition(
        target: LatLng(value.latitude, value.longitude),
        zoom: 16,
      );
      controller.animateCamera(CameraUpdate.newCameraPosition(_kGooglePlex));
      setState(() {});
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //_markers.addAll(list);

    // for (int i = 0; i < latlng.length; i++) {
    //   _markers.add(Marker(
    //     markerId: MarkerId(i.toString()),
    //     position: latlng[i],
    //     infoWindow: const InfoWindow(title: 'cooool', snippet: 'hotttt'),
    //     icon: BitmapDescriptor.defaultMarker,
    //   ));
    //   setState(() {});
    // }

    // _polyline.add(Polyline(
    //     polylineId: PolylineId('1'), points: latlng, color: Colors.red));

    loadData();
  }

  Travel travel = Travel();
  final TextEditingController ori_lat = TextEditingController();
  final TextEditingController ori_lng = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 241, 243, 244),
        elevation: 2,
        title: const Text('Pick up location'),
      ),
      body: SafeArea(
        child: Stack(
          //alignment: Alignment.bottomCenter,
          children: [
            GoogleMap(
              initialCameraPosition: const CameraPosition(
                target: LatLng(14.980897212188575, 102.07651271534304),
                zoom: 14,
              ),
              mapType: MapType.normal,
              myLocationButtonEnabled: true,
              myLocationEnabled: true,
              markers: Set<Marker>.of(_markers),
              polylines: _polyline,
              onTap: (latLng) async {
                print('${latLng.latitude}, ${latLng.longitude}');
                _markers.add(Marker(
                    markerId: const MarkerId('SomeId'),
                    position: LatLng(latLng.latitude, latLng.longitude),
                    infoWindow: InfoWindow(title: address)));
                final GoogleMapController controller = await _controller.future;
                CameraPosition _kGooglePlex = CameraPosition(
                  target: LatLng(latLng.latitude, latLng.longitude),
                  zoom: 16,
                );
                controller.animateCamera(
                    CameraUpdate.newCameraPosition(_kGooglePlex));
                ori_lat.text = latLng.latitude.toString();
                ori_lng.text = latLng.longitude.toString();
                travel.ori_lat = latLng.latitude;
                travel.ori_lng = latLng.longitude;
                setState(() {});
              },
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
            ),
            SizedBox(
              width: double.infinity,
              child: Form(
                  child: Column(
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width: 160,
                        child: TextFormField(
                            readOnly: true,
                            onSaved: (String? ori_lat) {
                              travel.ori_lat = ori_lat as double;
                            },
                            controller: ori_lat,
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.all(19),
                              fillColor: Color.fromARGB(250, 255, 255, 255),
                              hintText: 'ori_lat',
                              hintStyle: TextStyle(fontSize: 16),
                              border: OutlineInputBorder(
                                //borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide(
                                  width: 1,
                                  style: BorderStyle.none,
                                ),
                              ),
                              filled: true,
                            )),
                      ),
                      SizedBox(
                        width: 160,
                        child: TextFormField(
                            readOnly: true,
                            onSaved: (String? ori_lat) {
                              travel.ori_lat = ori_lat as double;
                            },
                            controller: ori_lng,
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.all(19),
                              fillColor: Color.fromARGB(250, 255, 255, 255),
                              hintText: 'ori_lng',
                              hintStyle: TextStyle(fontSize: 16),
                              border: OutlineInputBorder(
                                //borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide(
                                  width: 1,
                                  style: BorderStyle.none,
                                ),
                              ),
                              filled: true,
                            )),
                      ),
                      SizedBox(
                        height: 55,
                        width: 70,
                        child: ElevatedButton(
                          onPressed: () {
                            // print(ori_lat.text);
                            // print(ori_lng.text);
                            print(travel.ori_lat);
                            print(travel.ori_lng);
                            // Navigator.push(context, MaterialPageRoute(builder: (context) {
                            //   return const LoginScreen();
                            // }));
                          },
                          style: ButtonStyle(
                              //elevation: MaterialStateProperty.all(2),
                              backgroundColor:
                                  MaterialStateProperty.all(Colors.red),
                              shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                      //borderRadius: BorderRadius.circular(10.0),
                                      //side: BorderSide(color: Colors.red)
                                      ))),
                          child: Text("next",
                              style: GoogleFonts.cairo(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ],
              )),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _goToplace(Map<String, dynamic> place) async {
    final double lat = place['geometry']['location']['lat'];
    final double lng = place['geometry']['location']['lng'];
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(lat, lng), zoom: 12)));

    setMarker(LatLng(lat, lng));
  }

  searchbar() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 40, horizontal: 10),
      child: Row(
        children: [
          Expanded(
              child: TextFormField(
            controller: _searchController,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(hintText: 'Search'),
            onChanged: (value) {
              print(value);
            },
          )),
          IconButton(
            onPressed: () async {
              // Google billingคืออารัยย มันต้องจ่ายตังมั้ยนะ55555
              var place =
                  await LocationService().getPlace(_searchController.text);
              _goToplace(place);
            },
            icon: Icon(Icons.search),
          )
        ],
      ),
    );
  }
}
