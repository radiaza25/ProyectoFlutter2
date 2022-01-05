import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:mytracker/Components/Calender.dart';
import 'package:mytracker/UbicacionCoche.dart';
import 'package:provider/provider.dart';

import 'Components/List.dart';
import 'DirectionsProvider.dart';
import 'Punto.dart';

class ViewRutas extends StatefulWidget {
  const ViewRutas({Key key}) : super(key: key);

  @override
  ViewRutasState createState() => new ViewRutasState();
}

class ViewRutasState extends State<ViewRutas> {
  List<String> fecha;
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.calendar_today),
              onPressed: () {},
            );
          },
        ),
        title: Text('Lista de Carreras'),
        actions: <Widget>[
          IconButton(
            icon: new Icon(Icons.merge_type),
            onPressed: () => print('hi on icon action'),
          ),
        ],
      ),
      body: new Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          FutureBuilder<List<Widget>>(
              future: getNotificacion(),
              builder: (context, AsyncSnapshot<List<Widget>> notificacion) {
                if (!notificacion.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                return Expanded(
                  child: ListView(
                    children: notificacion.data,
                  ),
                );
              })
        ],
      ),
    );
  }

  Future<List<Widget>> getNotificacion() async {
    List<Widget> notificaciones = new List<Widget>();

    Map<String, dynamic> ruta;
    List<List<Punto>> lp = new List();
    List<double> km = new List();
    fecha = new List();

    final response = await http
        .get(Uri.http('apptaxis2.azurewebsites.net', '/Carrera'))
        .then((response) {
      if (response.statusCode == 200) {
        String body = utf8.decode(response.bodyBytes);
        final jsonData = jsonDecode(body);
        for (final f in jsonData) {
          List<Punto> p = new List();
          Map<String, dynamic> sd = f;
          List<dynamic> l = sd['carrera'];
          fecha.add(sd['createAt']);
          km.add(sd['kilometro'].toDouble());
          for (final e in l) {
            p.add(Punto.fromJson(e));
          }
          lp.add(p);
        }

        int a = 1;
      }
    });

    for (List<Punto> punto in lp) {
      List<Punto> p = punto;
      notificaciones.add(new ListData(
        km: km,
        fecha: fecha,
        a: lp,
        punto: punto,
        funcion: () {
          Navigator.pop(context);
          polilinea(punto, context);
        },
      ).build(context));
    }

    return notificaciones;
  }

  Future<List<List<Punto>>> dibujarTrayectoria() async {
    Map<String, dynamic> ruta;
    List<List<Punto>> lp = new List();
    fecha = new List();
    final response = await http.get(
        Uri.http('apptaxis2.azurewebsites.net', '/Carrera?sort=-carreraId'));
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
