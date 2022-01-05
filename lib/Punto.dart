import 'package:cloud_firestore/cloud_firestore.dart';

class Punto {
  double lat;
  double lng;
  double time;
  double speed;
  double altitude;

  Punto({this.lat, this.lng, this.time, this.speed, this.altitude});

  factory Punto.fromJson(Map<String, dynamic> json) {
    return Punto(
      lat: json['latitud'],
      lng: json['longitud'],
      time: json['time'].toDouble(),
      speed: json['speed'].toDouble(),
      altitude: json['altitude'].toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['Latitud'] = this.lat;
    data['Longitud'] = this.lng;
    data['Time'] = this.time;
    data['Speed'] = this.speed;
    data['Altitude'] = this.altitude;

    return data;
  }
}
