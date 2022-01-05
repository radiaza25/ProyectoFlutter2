import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:mytracker/Components/List.dart';
import 'package:mytracker/Components/ListDataNotificaciones.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'DirectionsProvider.dart';
import 'MensajesProvider.dart';
import 'Notificacion.dart';

class ViewNotification extends StatefulWidget {
  const ViewNotification({Key key}) : super(key: key);

  @override
  ViewNotificationState createState() => new ViewNotificationState();
}

class ViewNotificationState extends State<ViewNotification> {
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
              icon: const Icon(Icons.menu),
              onPressed: () => print('hi on menu icon'),
            );
          },
        ),
        title: Text('Lista de Notificaciones'),
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
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final usu = await prefs.getString("usuario");
    List<Widget> notificaciones = new List<Widget>();
    ;
    final response = await http
        .get(
      Uri.https('apptaxis2.azurewebsites.net', '/Notificacion'),
    )
        .then((response) {
      if (response.statusCode == 200) {
        String body = utf8.decode(response.bodyBytes);
        final jsonData = jsonDecode(body);
        int contador = 0;

        for (final f in jsonData) {
          var e = f['lugar']['latitud'];
          var t = f['lugar']['longitud'];
          if (f['choferId'] == usu)
            notificaciones.add(new ListDataNotificaciones(
              titulo: f['title'],
              subtitulo: f['bodyText'],
              funcion: () {
                Navigator.pop(context);
                colocar(e, t, context);
              },
            ).build(context));
        }
      }
    });
    return notificaciones;
  }

  void colocar(double lat, double lng, BuildContext context) {
    var api = Provider.of<DirectionProvider>(context, listen: false);
    api.colocarMarkerAlerta(lat, lng);
  }
}
