import 'package:cloud_firestore/cloud_firestore.dart';

import 'Punto.dart';

class Notificacion {
  String notificacionId;
  String choferId;
  String title;
  String bodytext;
  Punto punto;

  Notificacion(
      {this.notificacionId,
      this.choferId,
      this.title,
      this.bodytext,
      this.punto});

  factory Notificacion.fromJson(Map<String, dynamic> json) {
    return Notificacion(
      notificacionId: json['notificacionId'],
      choferId: json['choferId'],
      title: json['title'],
      bodytext: json['bodyText'],
      punto: Punto.fromJson(json['punto']),
    );
  }

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['notificacionId'] = this.notificacionId;
    data['choferId'] = this.choferId;
    data['title'] = this.title;
    data['bodyText'] = this.bodytext;
    data['punto'] = this.punto.toMap();

    return data;
  }
}
