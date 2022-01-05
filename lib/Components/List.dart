import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../DirectionsProvider.dart';
import '../Punto.dart';

class ListData extends StatelessWidget {
  List<String> fecha;
  List<List<Punto>> a;
  List<Punto> punto;
  Function funcion;
  List<double> km;
  List<String> tiempo;

  ListData({this.fecha, this.a, this.punto, this.funcion, this.km});
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text("" +
          DateTime.parse(fecha.elementAt(a.indexOf(punto)))
              .toLocal()
              .year
              .toString() +
          "/" +
          DateTime.parse(fecha.elementAt(a.indexOf(punto)))
              .toLocal()
              .month
              .toString() +
          "/" +
          DateTime.parse(fecha.elementAt(a.indexOf(punto)))
              .toLocal()
              .day
              .toString()),
      leading: Icon(Icons.star_border),
      subtitle: Text(dia(DateTime.parse(fecha.elementAt(a.indexOf(punto)))
              .toLocal()
              .weekday) +
          " - " +
          DateTime.parse(fecha.elementAt(a.indexOf(punto)))
              .toLocal()
              .hour
              .toString() +
          ":" +
          DateTime.parse(fecha.elementAt(a.indexOf(punto)))
              .toLocal()
              .minute
              .toString() +
          "   Distancia: " +
          km.elementAt(a.indexOf(punto)).toStringAsFixed(2) +
          "km"),
      onTap: () {
        funcion();
        // Navigator.pop(context);
        // polilinea(punto, context);
      },
    );
  }

  Future<List<List<Punto>>> dibujarTrayectoria() async {
    Map<String, dynamic> ruta;
    List<List<Punto>> lp = new List();
    fecha = new List();
    final response =
        await http.get(Uri.http('apptaxis2.azurewebsites.net', '/Carrera'));
    if (response.statusCode == 200) {
      String body = utf8.decode(response.bodyBytes);
      final jsonData = jsonDecode(body);
      for (final f in jsonData) {
        List<Punto> p = new List();
        Map<String, dynamic> sd = f;
        List<dynamic> l = sd['carrera'];
        fecha.add(sd['createAt']);
        for (final e in l) {
          p.add(Punto.fromJson(e));
        }
        lp.add(p);
      }

      int a = 1;
    }
    return lp;
  }

  String dia(int dia) {
    switch (dia) {
      case 1:
        return "Lunes";
        break;
      case 2:
        return "Martes";
        break;
      case 3:
        return "Miercoles";
        break;
      case 4:
        return "Jueves";
        break;
      case 5:
        return "Viernes";
        break;
      case 6:
        return "Sabado";
        break;
      case 7:
        return "Domingo";
        break;
    }
  }

  void polilinea(List<Punto> punto, BuildContext context) {
    List<LatLng> list = convertToLatLng(punto);
    var api = Provider.of<DirectionProvider>(context, listen: false);
    api.findGuardado(list);
  }

  List<LatLng> convertToLatLng(List<Punto> punto) {
    List<LatLng> lp = new List();
    for (final f in punto) {
      LatLng latlng = new LatLng(f.lat, f.lng);
      lp.add(latlng);
    }
    return lp;
  }
}
