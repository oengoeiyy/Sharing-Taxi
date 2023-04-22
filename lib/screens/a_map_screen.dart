import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sharing_taxi/services/location_service.dart';

class MapScreen extends StatefulWidget {
  // final double? lat;
  // final double? lng;
  const MapScreen({Key? key}) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
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

  void setMarker(LatLng point) {
    setState(() {
      _markers.add(Marker(markerId: MarkerId('marker'), position: point));
    });
  }

  loadData() {
    _getUserCurrentLocation().then((value) async {
      // _markers.add(Marker(
      //     markerId: const MarkerId('current'),
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

    loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: Colors.red[200],
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Color.fromARGB(
            255, 232, 232, 232), //const Color.fromARGB(255, 241, 243, 244),
        elevation: 0,
        title: const Text('Google Maps'),
      ),
      body: SafeArea(
        child: Stack(
          //alignment: Alignment.bottomCenter,
          children: [
            GoogleMap(
              initialCameraPosition: const CameraPosition(
                target: LatLng(14.980897212188575, 102.07651271534304),
                zoom: 16,
              ),
              mapType: MapType.normal,
              myLocationButtonEnabled: true,
              myLocationEnabled: true,
              //markers: Set<Marker>.of(_markers),
              polylines: _polyline,
              onTap: (latLng) async {
                //print('${latLng.latitude}, ${latLng.longitude}');
                _markers.add(Marker(
                    markerId: const MarkerId('origin'),
                    position: LatLng(latLng.latitude, latLng.longitude),
                    infoWindow: InfoWindow(title: address)));
                final GoogleMapController controller = await _controller.future;
                CameraPosition _kGooglePlex = CameraPosition(
                  target: LatLng(latLng.latitude, latLng.longitude),
                  zoom: 16,
                );
                controller.animateCamera(
                    CameraUpdate.newCameraPosition(_kGooglePlex));
                setState(() {});
              },
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
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
