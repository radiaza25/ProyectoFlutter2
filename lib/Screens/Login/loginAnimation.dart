import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mytracker/UbicacionCoche.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dart:async';

import '../../Usuario.dart';
import '../../variables.dart';
import 'index.dart';

class StaggerAnimation extends StatelessWidget {
  StaggerAnimation({Key key, this.buttonController, this.user, this.pass})
      : buttonSqueezeanimation = new Tween(
          begin: 320.0,
          end: 70.0,
        ).animate(
          new CurvedAnimation(
            parent: buttonController,
            curve: new Interval(
              0.0,
              0.150,
            ),
          ),
        ),
        buttomZoomOut = new Tween(
          begin: 70.0,
          end: 1000.0,
        ).animate(
          new CurvedAnimation(
            parent: buttonController,
            curve: new Interval(
              0.550,
              0.999,
              curve: Curves.bounceOut,
            ),
          ),
        ),
        containerCircleAnimation = new EdgeInsetsTween(
          begin: const EdgeInsets.only(bottom: 50.0),
          end: const EdgeInsets.only(bottom: 0.0),
        ).animate(
          new CurvedAnimation(
            parent: buttonController,
            curve: new Interval(
              0.500,
              0.800,
              curve: Curves.ease,
            ),
          ),
        ),
        super(key: key);

  final AnimationController buttonController;
  String user;
  String pass;
  final Animation<EdgeInsets> containerCircleAnimation;
  final Animation buttonSqueezeanimation;
  final Animation buttomZoomOut;

  Future<Null> _playAnimation() async {
    try {
      await buttonController.forward();
      await buttonController.reverse();
    } on TickerCanceled {}
  }

  Widget _buildAnimation(BuildContext context, Widget child) {
    return new Padding(
      padding: buttomZoomOut.value == 70
          ? const EdgeInsets.only(bottom: 170.0)
          : containerCircleAnimation.value,
      child: new InkWell(
          onTap: () async {
            _playAnimation();
          },
          child: new Hero(
            tag: "fade",
            child: buttomZoomOut.value <= 300
                ? new Container(
                    width: 320.0,
                    height: 60, //alto del boton
                    alignment: FractionalOffset.center,
                    decoration: new BoxDecoration(
                      color: Colors.black,
                      borderRadius: buttomZoomOut.value < 400
                          ? new BorderRadius.all(const Radius.circular(30.0))
                          : new BorderRadius.all(const Radius.circular(0.0)),
                    ),
                    child: buttonSqueezeanimation.value > 75.0
                        ? new Text(
                            "Sign In",
                            style: new TextStyle(
                              color: Colors.white,
                              fontSize: 20.0,
                              fontWeight: FontWeight.w300,
                              letterSpacing: 0.3,
                            ),
                          )
                        : buttomZoomOut.value < 300.0
                            ? new CircularProgressIndicator(
                                value: null,
                                strokeWidth: 8.0,
                                valueColor: new AlwaysStoppedAnimation<Color>(
                                    Colors.white),
                              )
                            : null)
                : new Container(
                    alignment: FractionalOffset.center,
                    width: buttomZoomOut.value,
                    height: buttomZoomOut.value,
                    decoration: new BoxDecoration(
                      shape: buttomZoomOut.value < 500
                          ? BoxShape.circle
                          : BoxShape.rectangle,
                      color: Colors.black,
                    ),
                  ),
          )),
    );
  }

  @override
  Widget build(BuildContext context) {
    buttonController.addListener(() {
      if (buttonController.isCompleted) {
        getUsuario(context);
      }
    });
    return new AnimatedBuilder(
      builder: _buildAnimation,
      animation: buttonController,
    );
  }

  void getUsuario(BuildContext context) async {
    var url = Uri.https(
        'apptaxis2.azurewebsites.net', '/Usuario/' + user + '/' + pass);
    final response = await http.get(url);
    if (response.statusCode == 200) {
      String body = utf8.decode(response.bodyBytes);
      final jsonData = jsonDecode(body);
      saveValueNombre(jsonData['nombre']);
      saveValue(user);
      usuario = user;
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute<Null>(builder: (BuildContext context) {
        return new MyHomePage();
      }), (Route<dynamic> route) => false);
    } else {
      errorDialog(context).then((value) => _reset(context));
    }
  }

  void _reset(BuildContext context) {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: Duration.zero,
        pageBuilder: (_, __, ___) => LoginScreen(),
      ),
    );
  }

  Future<Widget> errorDialog(BuildContext contexto) async {
    return showDialog(
        context: contexto,
        builder: (buildcontext) {
          return AlertDialog(
            title: Text("Error!"),
            content: Text("usuario o clave erroneos"),
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

Widget buildAlertDialog(BuildContext context) {
  return AlertDialog(
    title: Text('Notificaciones'),
    content:
        Text("¿Desea recibir notificaciones? Serán muy pocas de verdad :)"),
    actions: [
      FlatButton(
          child: Text("Aceptar"),
          textColor: Colors.blue,
          onPressed: () {
            Navigator.of(context).pop();
          }),
      FlatButton(
          child: Text("Cancelar"),
          textColor: Colors.red,
          onPressed: () {
            Navigator.of(context).pop();
          }),
    ],
  );
}

saveValue(String usuario) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('usuario', usuario);
}

saveValueNombre(String nombre) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('nombre', nombre);
}
