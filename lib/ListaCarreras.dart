import 'dart:async';
import 'dart:typed_data';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:mytracker/DirectionsProvider.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'Punto.dart';

class ListaCarreras extends StatefulWidget {
  ListaCarreras({Key key, this.title = ''}) : super(key: key);
  final String title;

  @override
  _ListaCarrerasPageState createState() => _ListaCarrerasPageState();
}

class _ListaCarrerasPageState extends State<ListaCarreras> {
  List<Punto> p = new List();
  @override
  void initState() {
    super.initState();
    dibujarTrayectoria();
  }

  Future<http.Response> dibujarTrayectoria() async {
    Map<String, dynamic> ruta;
    final response =
        await http.get(Uri.http('192.168.100.160:18177', '/Carrera'));
    if (response.statusCode == 200) {
      String body = utf8.decode(response.bodyBytes);
      final jsonData = jsonDecode(body);
      Map<String, dynamic> sd = jsonData[0];
      List<dynamic> l = sd['carrera'];
      Map<String, dynamic> sc = l[0];

      var user = new Punto.fromJson(sc);
      for (final e in l) {
        p.add(Punto.fromJson(e));
      }

      int a = 1;
    }
    return response;
  }
  //function menu options

  //functions for call 911

  //Function for updateMarkerAndCircle

  @override
  Widget build(BuildContext context) {}
}
