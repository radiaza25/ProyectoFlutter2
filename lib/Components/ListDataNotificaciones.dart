import 'package:flutter/material.dart';

import '../Punto.dart';

class ListDataNotificaciones extends StatelessWidget {
  String titulo;
  String subtitulo;
  Punto punto;
  Function funcion;

  ListDataNotificaciones(
      {this.titulo, this.subtitulo, this.punto, this.funcion});
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: new Text(titulo),
      subtitle: new Text(subtitulo),
      leading: new Icon(Icons.warning),
      onTap: () {
        funcion();
      },
    );
  }
}
