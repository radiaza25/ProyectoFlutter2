import 'package:flutter/material.dart';

class Boton extends StatefulWidget {
  Icon icon;
  Color color;
  Function pAction;
  Boton({this.icon, this.color, this.pAction});

  @override
  _BotonState createState() => _BotonState();
}

class _BotonState extends State<Boton> {
  // bool activar = false;
  //Color pulsado = Colors.grey;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: FloatingActionButton(
          child: widget.icon,
          elevation: 5,
          backgroundColor: widget.color,
          onPressed: () {
            widget.pAction();
            // activaSeguimiento();
          }),
    );
  }

  /*void activaSeguimiento() {
    if (activar == true) {
      activar = false;
      setState(() {
        pulsado = Colors.grey;
      });
    } else {
      activar = true;
      setState(() {
        pulsado = widget.color;
      });
    }
  }*/
}
