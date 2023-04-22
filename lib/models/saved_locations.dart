import 'package:cloud_firestore/cloud_firestore.dart';

class SavedLocation {
  double? latitude;
  double? longitude;
  String? address;
  String? placeName;
  String? detail;
  Timestamp? timestamp;

  SavedLocation(
      {this.latitude,
      this.longitude,
      this.address,
      this.placeName,
      this.detail,
      this.timestamp});
}
