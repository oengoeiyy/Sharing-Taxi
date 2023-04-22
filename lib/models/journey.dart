// ignore_for_file: non_constant_identifier_names

import 'package:cloud_firestore/cloud_firestore.dart';

class Travel {
  double? ori_lat;
  double? ori_lng;
  double? des_lat;
  double? des_lng;
  String? type;
  String? start_name;
  String? end_name;

  Travel(
      {this.ori_lat,
      this.ori_lng,
      this.des_lat,
      this.des_lng,
      this.type,
      this.start_name,
      this.end_name});
}

class Journey {
  double? startLat;
  double? startLng;
  double? endLat;
  double? endLng;
  String? startAddress;
  String? endAddress;
  String? placeName;
  String? detail;
  double? distance;
  double? cost;
  int? person;
  String? status;
  String? creator;
  Timestamp? timestamp;

  Journey(
      {this.startLat,
      this.startLng,
      this.endLat,
      this.endLng,
      this.startAddress,
      this.endAddress,
      this.placeName,
      this.detail,
      this.distance,
      this.cost,
      this.person,
      this.status,
      this.creator,
      this.timestamp});
}
