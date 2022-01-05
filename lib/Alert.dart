import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as maps;
import 'package:google_maps_webservice/directions.dart';
import 'package:google_maps_webservice/distance.dart';
import 'dart:math' show cos, sqrt, asin;

class DialogProvider extends ChangeNotifier {
  Text title;
  Text content;
  DialogProvider({this.title, this.content});

  buildDialog(BuildContext contexto) async {
    return showDialog(
        context: contexto,
        builder: (buildcontext) {
          return AlertDialog(
            title: Text("Alerta!"),
            content: Text("has llegado a tu destino"),
            actions: <Widget>[
              RaisedButton(
                child: Text(
                  "CERRAR",
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  Navigator.of(contexto).pop();
                },
              )
            ],
          );
        });
  }
}
