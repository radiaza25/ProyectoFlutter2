import 'package:flutter/material.dart';

class Boton extends StatelessWidget {
  Color color;
  Icon icon;
  Future<void> f;
  Boton({this.color, this.icon, this.f});
  @override
  Widget build(BuildContext context) {
    return (new Padding(
      padding: const EdgeInsets.all(8.0),
      child: FloatingActionButton(
          child: icon,
          elevation: 5,
          backgroundColor: color,
          onPressed: () {
            f;
          }),
    ));
  }
}
