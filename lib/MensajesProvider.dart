import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:mytracker/Notificacion.dart';
import 'package:mytracker/variables.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Components/List.dart';
import 'Punto.dart';

class MensajesProvider extends ChangeNotifier {
  Future<Response> GuardarNotificacion(Punto p) async {
    var not = {
      "choferId": "1003943832",
      "title": "Alerta Exceso de velocidad",
      "bodyText": "EL chofer ha excedido el exceso de velocidad",
      "lugar": {
        "latitud": p.lat.toString(),
        "longitud": p.lat.toString(),
        "time": p.time.toString(),
        "speed": p.speed.toString(),
      }
    };

    final response = await post(
      Uri.https('apptaxis2.azurewebsites.net', '/Notificaion/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(not),
    );

    return response;
  }

  Future<void> enviarNotificacion() async {
    final response = await http
        .post(
      Uri.https('fcm.googleapis.com', '/fcm/send'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization':
            'key=AAAA6uAzADk:APA91bGIvOyNB2wOVEZNk3QB0JQcCRZ6MPRF-RiXcJiybPKeI8M9f3Iu6OxmQKozfoKqH7UzYsQDPScYZ-eRdxvyNK2qZyQXLlVUZR5c8_Hj-LDMiD01cBa5L09VANLM3TZLZIadTGyY'
      },
      body: jsonEncode({
        "to": keyGen,
        "notification": {
          "body": "Limite de velocidad excedido",
          "OrganizationId": "2",
          "content_available": true,
          "priority": "high",
          "subtitle": "Elementary School",
          "Title": "Alerta de exceso de velocidad"
        },
        "data": {
          "click_action": "FLUTTER_NOTIFICATION_CLICK",
          "priority": "high",
          "sound": "app_sound.wav",
          "content_available": true,
          "bodyText": "estas siendo asaltado por el tuculu",
          "organization": "Elementary school"
        }
      }),
    )
        .then((response) {
      if (response.statusCode == 200) {
        int a = 1;
      }
    });
  }

  Future<void> lista(BuildContext context) async {
    List<Notificacion> a = await getNotificacion();
    Navigator.of(context).push(
      new MaterialPageRoute<void>(
        builder: (BuildContext context) {
          final Iterable<ListTile> tiles = a.map(
            (Notificacion not) {
              return ListTile(
                title: Text("" + not.title.toString()),
                leading: Icon(Icons.notification_important),
                subtitle: Text("" +
                    not.bodytext.toString() +
                    " lat:" +
                    not.punto.lat.toString() +
                    " long:" +
                    not.punto.lng.toString()),
                onTap: () {},
              );
            },
          );

          final List<Widget> divided = ListTile.divideTiles(
            context: context,
            tiles: tiles,
          ).toList();
          return new Scaffold(
            // Añadir 6 líneas desde aquí...
            appBar: new AppBar(
              title: const Text('Rutas Guardadas'),
            ),
            body: new ListView(children: divided),
          ); // ... hasta aquí.
        },
      ),
    );
  }

  Future<List<Notificacion>> getNotificacion() async {
    List<Notificacion> notificaciones;
    final response = await http
        .get(
      Uri.parse('apptaxis2.azurewebsites.net/Notificacion'),
    )
        .then((response) {
      if (response.statusCode == 200) {
        String body = utf8.decode(response.bodyBytes);
        final jsonData = jsonDecode(body);
        for (final f in jsonData) {
          notificaciones = new List<Notificacion>();

          notificaciones.add(Notificacion.fromJson(f));
        }
      }
    });
    return notificaciones;
  }
}
