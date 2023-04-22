import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sharing_taxi/models/journey.dart';
import 'package:sharing_taxi/dump/des_location_screen.dart';
import 'package:sharing_taxi/services/location_service.dart';

class OriginLocationScreen extends StatefulWidget {
  final String? type;
  const OriginLocationScreen({Key? key, @required this.type}) : super(key: key);

  @override
  _OriginLocationScreenState createState() => _OriginLocationScreenState();
}

class _OriginLocationScreenState extends State<OriginLocationScreen> {
  Position? _position;
  StreamSubscription<Position>? _streamSubscription;
  //Address? _address;

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

  _getLocationName(double lat, double lng) async {
    await placemarkFromCoordinates(lat, lng).then((value) {
      address =
          "${value[2].name}, ${value[2].street}, ${value[2].locality}, ${value[2].subAdministrativeArea}, ${value[2].administrativeArea}, ${value[2].country}, ${value[2].postalCode}";

      placeName.text = address;
      //ori_lng.text = value.longitude.toString();
      setState(() {});
    }).onError((error, stackTrace) {
      placeName.text = error.toString();
    });

    //List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
    //print(placemarks);
    //return placemarks[0].toString();
  }

  final Set<Marker> _markers = {};
  //final List<Marker> _markers =  <Marker>[];
  final Set<Polyline> _polyline = {};

  // List<LatLng> latlng = [
  //   LatLng(14.980897212188575, 102.07651271534304),
  //   LatLng(14.98170561708843, 102.0903636426428)
  // ];

  void setMarker(LatLng point) {
    setState(() {
      _markers.add(Marker(markerId: MarkerId('marker'), position: point));
    });
  }

  loadData() {
    _getUserCurrentLocation().then((value) async {
      _markers.add(Marker(
          markerId: const MarkerId('origin'),
          position: LatLng(value.latitude, value.longitude),
          infoWindow: InfoWindow(title: address)));

      final GoogleMapController controller = await _controller.future;
      CameraPosition _kGooglePlex = CameraPosition(
        target: LatLng(value.latitude, value.longitude),
        zoom: 16,
      );
      controller.animateCamera(CameraUpdate.newCameraPosition(_kGooglePlex));
      _getLocationName(value.latitude, value.longitude);
      travel.ori_lat = value.latitude;
      travel.ori_lng = value.longitude;
      ori_lat.text = value.latitude.toString();
      ori_lng.text = value.longitude.toString();
      setState(() {});
    });
  }

  final type = OriginLocationScreen().type;
  Travel travel = Travel();
  final TextEditingController ori_lat = TextEditingController();
  final TextEditingController ori_lng = TextEditingController();
  final TextEditingController placeName = TextEditingController();
  CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(14.889937, 102.006134),
    zoom: 14,
  );

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    travel.type = widget.type;
    loadData();

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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: Colors.red[200],
      appBar: AppBar(
        centerTitle: true,
        backgroundColor:
            Colors.white, //const Color.fromARGB(255, 241, 243, 244),
        elevation: 2,
        title: const Text('Pick up location'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Stack(
              //alignment: Alignment.bottomCenter,
              children: [
                Container(
                  height: 420,
                  child: GoogleMap(
                    initialCameraPosition: _kGooglePlex,
                    mapType: MapType.normal,
                    myLocationButtonEnabled: true,
                    myLocationEnabled: true,
                    markers: Set<Marker>.of(_markers),
                    polylines: _polyline,
                    onTap: (latLng) async {
                      //print('${latLng.latitude}, ${latLng.longitude}');
                      _markers.add(Marker(
                          markerId: const MarkerId('origin'),
                          position: LatLng(latLng.latitude, latLng.longitude),
                          infoWindow: InfoWindow(title: address)));
                      final GoogleMapController controller =
                          await _controller.future;
                      CameraPosition _kGooglePlex = CameraPosition(
                        target: LatLng(latLng.latitude, latLng.longitude),
                        zoom: 16,
                      );
                      controller.animateCamera(
                          CameraUpdate.newCameraPosition(_kGooglePlex));
                      await _getLocationName(latLng.latitude, latLng.longitude);
                      //ori_lat.text = latLng.latitude.toString();
                      //ori_lng.text = latLng.longitude.toString();
                      travel.ori_lat = latLng.latitude;
                      travel.ori_lng = latLng.longitude;
                      setState(() {});
                    },
                    onMapCreated: (GoogleMapController controller) {
                      _controller.complete(controller);
                    },
                  ),
                ),
              ],
            ),
            Container(
              alignment: Alignment.bottomCenter,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(15)),
              ),
              //height: double.infinity,
              width: double.infinity,
              child: Padding(
                padding: EdgeInsets.fromLTRB(10, 20, 10, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    const Text(
                      "PICK UP Location :",
                      style: TextStyle(fontSize: 20),
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: TextFormField(
                          maxLines: 1,
                          readOnly: true,
                          // onSaved: (String? ori_lat) {
                          //   travel.ori_lat = ori_lat as double;
                          // },
                          controller: placeName,
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.all(19),
                            fillColor: Color.fromARGB(250, 255, 255, 255),
                            //label : Text('from'),
                            hintText: 'Place name',
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
                    const SizedBox(
                      height: 10,
                    ),
                    SizedBox(
                      height: 50,
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          print(travel.ori_lat);
                          print(travel.ori_lng);
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return DesLocationScreen(
                              ori_lat: travel.ori_lat,
                              ori_lng: travel.ori_lng,
                              type: travel.type,
                            );
                          }));
                        },
                        style: ButtonStyle(
                            //elevation: MaterialStateProperty.all(2),
                            backgroundColor:
                                MaterialStateProperty.all(Colors.red),
                            shape: MaterialStateProperty.all<
                                    RoundedRectangleBorder>(
                                const RoundedRectangleBorder(
                                    //borderRadius: BorderRadius.circular(10.0),
                                    //side: BorderSide(color: Colors.red)
                                    ))),
                        child: Text("ตกลง",
                            style: GoogleFonts.cairo(
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                                color: Colors.white)),
                      ),
                    ),
                    const SizedBox(
                      height: 12.9,
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
