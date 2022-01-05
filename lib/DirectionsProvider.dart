import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as maps;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/directions.dart';
import 'package:google_maps_webservice/distance.dart';
import 'dart:math' show cos, sqrt, asin;
import 'package:http/http.dart' as http;

class DirectionProvider extends ChangeNotifier {
  maps.Circle circle;

  final markerStream = new StreamController();
  //Stream<maps.Marker> get markerGet => markerStream.stream;
  Map<maps.MarkerId, maps.Marker> markers = Map();

  GoogleMapsDirections directionsApi =
      GoogleMapsDirections(apiKey: "AIzaSyD3__Hy3qxzP6OBbTTJfhDD4miTppV1O10");
  Set<maps.Polyline> _route = Set();
  Set<maps.Circle> _listCirculos = Set();

  List<maps.LatLng> points;
  maps.Marker inicio;
  maps.Marker fin;
  maps.Marker alert;

  //Map<maps.MarkerId, maps.Marker> markers = Map();

  Set<maps.Polyline> get currentRoute => _route;
  Set<maps.Circle> get currentCircle => _listCirculos;

//********Consumo directionsApi para calcular la ruta mas corta*****************
  findDirections(maps.LatLng from, maps.LatLng to) async {
    var origin = Location(lat: from.latitude, lng: from.longitude);
    var destination = Location(lat: to.latitude, lng: to.longitude);

    var result = await directionsApi.directionsWithLocation(
      origin,
      destination,
      travelMode: TravelMode.driving,
    );

    Set<maps.Polyline> newRoute = Set();

    if (result.isOkay) {
      var route = result.routes[0];
      var leg = route.legs[0];

      points = [];

      leg.steps.forEach((step) {
        points.add(maps.LatLng(step.startLocation.lat, step.startLocation.lng));
        points.add(maps.LatLng(step.endLocation.lat, step.endLocation.lng));
      });

      var line = maps.Polyline(
        points: points,
        polylineId: maps.PolylineId("mejor ruta"),
        color: Colors.red,
        width: 4,
      );
      newRoute.add(line);

      print(line);

      _route = newRoute;
      notifyListeners();
    } else {
      print("ERRROR !!! ${result.status}");
    }
  }


  void actualizarRuta(maps.LatLng actual) {
    Set<maps.Polyline> newRoute = Set();

    points[0] = actual;
    var line = maps.Polyline(
      points: points,
      polylineId: maps.PolylineId("mejor ruta"),
      color: Colors.red,
      width: 4,
    );
    newRoute.add(line);

    print(line);

    _route = newRoute;
    notifyListeners();
  }

  //*****************Dibujar la ruta guardada seleccionada**********************

  findGuardado(List<maps.LatLng> points) async {
    Set<maps.Polyline> newRoute = Set();

    var line = maps.Polyline(
      points: points,
      polylineId: maps.PolylineId("mejor ruta"),
      color: Colors.deepPurple,
      width: 4,
    );
    newRoute.add(line);

    print(line);
    var e = points.last;
    final ByteData bytes = await rootBundle.load('assets/inicio.png');
    final Uint8List list = bytes.buffer.asUint8List();
    final ByteData bytes2 = await rootBundle.load('assets/meta.png');
    final Uint8List list2 = bytes2.buffer.asUint8List();
    _route = newRoute;
    inicio = maps.Marker(
      markerId: maps.MarkerId("3"),
      position: points[0], 
      draggable: false,
      zIndex: 2,
      flat: true,
      anchor: Offset(0.5, 0.5),
      icon: maps.BitmapDescriptor.fromBytes(list),
    );
    fin = maps.Marker(
      markerId: maps.MarkerId("4"),
      position: points.last, 
      draggable: false,
      zIndex: 2,
      flat: true,
      anchor: Offset(0.5, 0.5),
      icon: maps.BitmapDescriptor.fromBytes(list2),
    );
    markers[inicio.markerId] = inicio;
    markers[fin.markerId] = fin;
    notifyListeners();
  }
//**********************Funcion calculo del quilometraje************************
  calcularKilometraje(List<maps.LatLng> points) {
    double kcarrera = 0;
    for (int i = 0; i < points.length - 1; i++) {
      Location a =
          new Location(lat: points[i].latitude, lng: points[i].longitude);
      Location b = new Location(
          lat: points[i + 1].latitude, lng: points[i + 1].longitude);
      kcarrera += _coordinateDistance(points[i].latitude, points[i].longitude,
          points[i + 1].latitude, points[i + 1].longitude);
    }

    notifyListeners();
    return kcarrera;
  }
//***************Colocar marcador de alerta de panico
  colocarMarkerAlerta(double lat, double lng) async {
    final ByteData bytes2 = await rootBundle.load('assets/alerta.png');
    final Uint8List list2 = bytes2.buffer.asUint8List();
    alert = maps.Marker(
      markerId: maps.MarkerId("5"),
      position: maps.LatLng(lat, lng), //posible error aqui
      draggable: false,
      zIndex: 2,
      flat: true,
      anchor: Offset(0.5, 0.5),
      icon: maps.BitmapDescriptor.fromBytes(list2),
    );
    markers[alert.markerId] = alert;
    notifyListeners();
  }
//*********************Seniala los clusteres de las carreras********************

  findClusteres(int dia) async {
    Set<maps.Circle> newCirculos = Set();
    final response = await http
        .get(
      Uri.https('apptaxis2.azurewebsites.net', '/Cluster'),
    )
        .then((response) {
      if (response.statusCode == 200) {
        String body = utf8.decode(response.bodyBytes);
        final jsonData = jsonDecode(body);
        for (Map<String, dynamic> datos in jsonData) {
          var n = datos['nombreCluster'];
          var listCluster = datos['listCLuster'];
          if (n == dia.toString()) {
            int fr = 1;
            for (Map cluster in listCluster) {
              double p = cluster["latitud"];
              double x = cluster["longitud"];

              circle = new maps.Circle(
                  strokeWidth: 1,
                  circleId: maps.CircleId("" + fr.toString()),
                  center: LatLng(p, x),
                  radius: 200,
                  fillColor: Color.fromRGBO(160, 160, 160, 1).withOpacity(0.5),
                  strokeColor: Color.fromRGBO(0, 0, 0, 1),
                  onTap: () {
                    //findDirections(p, x);
                  });
              newCirculos.add(circle);
              fr++;
            }
          }
        }
      }
    });

    _listCirculos = newCirculos;
  }
}
//Funcion calcular distancia entre 2 puntos
double _coordinateDistance(lat1, lon1, lat2, lon2) {
  var p = 0.017453292519943295;
  var c = cos;
  var a = 0.5 -
      c((lat2 - lat1) * p) / 2 +
      c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
  return 12742 * asin(sqrt(a));
}
