import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'styles.dart';
import 'loginAnimation.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/animation.dart';
import 'dart:async';
import '../../Components/SignUpLink.dart';
import '../../Components/Form.dart';
import '../../Components/SignInButton.dart';
import '../../Components/WhiteTick.dart';
import 'package:flutter/services.dart';
import 'package:flutter/scheduler.dart' show timeDilation;
import '../../Components/Usuario.dart';
import 'package:http/http.dart' as http;

class LoginScreen extends StatefulWidget {
  final String username;
  final String password;
  final FormContainer fct;

  const LoginScreen({Key key, this.username, this.password, this.fct})
      : super(key: key);

  @override
  LoginScreenState createState() => new LoginScreenState();
}

class LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  FormContainer fc = new FormContainer();

  //inconveniente aso

  AnimationController _loginButtonController;
  var animationStatus = 0;
  @override
  void initState() {
    super.initState();
    _loginButtonController = new AnimationController(
        duration: new Duration(milliseconds: 15000), vsync: this);
  }

  @override
  void dispose() {
    _loginButtonController.dispose();
    super.dispose();
  }

  Future<Null> _playAnimation() async {
    try {
      await _loginButtonController.forward();
      await _loginButtonController.reverse();
    } on TickerCanceled {}
  }

  Future<bool> _onWillPop() {
    return showDialog(
          context: context,
          builder: (context) {
            return new AlertDialog(
              title: new Text('Esta seguro?'),
              actions: <Widget>[
                new TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: new Text('Si'),
                ),
                new TextButton(
                  onPressed: () => Navigator.pushReplacementNamed(context,
                      "/bottom_ba"), // aqui es lo que estaba buscando para linkear a pagina
                  child: new Text('No'),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    timeDilation = 0.4;
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    return (new WillPopScope(
        onWillPop: _onWillPop,
        child: new Scaffold(
          body: new Container(
              decoration: new BoxDecoration(
                image: fondo,
              ),
              child: new Container(
                  decoration: new BoxDecoration(
                      gradient: new LinearGradient(
                    colors: <Color>[
                      const Color.fromRGBO(10, 10, 10, 0.9),
                      const Color.fromRGBO(51, 51, 63, 0.9),
                    ],
                    stops: [0.2, 1.0],
                    begin: const FractionalOffset(0.0, 0.0),
                    end: const FractionalOffset(0.0, 1.0),
                  )),
                  child: new ListView(
                    //padding: const EdgeInsets.all(10.0),
                    children: <Widget>[
                      new Stack(
                        alignment: AlignmentDirectional.bottomCenter,
                        children: <Widget>[
                          new Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              Container(
                                alignment: Alignment.bottomCenter,
                                padding: EdgeInsets.all(20),
                                width: 220,
                                height: 290,
                                decoration: new BoxDecoration(
                                    color: Color.fromARGB(
                                        200,
                                        Color(0xfffdd835).red,
                                        Color(0xfffdd835).green,
                                        Color(0xfffdd835).blue),
                                    shape: BoxShape.circle),
                                child: Container(
                                  alignment: Alignment.bottomCenter,
                                  padding: EdgeInsets.all(20),
                                  width: 220,
                                  height: 290,
                                  decoration: new BoxDecoration(
                                      color: Color.fromARGB(
                                          155,
                                          Color(0xfffdd835).red,
                                          Color(0xfffdd835).green,
                                          Color(0xfffdd835).blue),
                                      shape: BoxShape.circle),
                                  child: Container(
                                    alignment: Alignment.bottomCenter,
                                    padding: EdgeInsets.all(20),
                                    width: 220,
                                    height: 290,
                                    decoration: new BoxDecoration(
                                        color: Color.fromARGB(
                                            100,
                                            Color(0xfffdd835).red,
                                            Color(0xfffdd835).green,
                                            Color(0xfffdd835).blue),
                                        shape: BoxShape.circle),
                                    child: Container(
                                      alignment: Alignment.topCenter,
                                      padding: EdgeInsets.all(10),
                                      width: 170,
                                      height: 290,
                                      decoration: new BoxDecoration(
                                          color: Color.fromARGB(
                                              255,
                                              Color(0xfffdd835).red,
                                              Color(0xfffdd835).green,
                                              Color(0xfffdd835).blue),
                                          shape: BoxShape.circle),
                                      child: new Tick(image: tick),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                //inconveniente aso
                                alignment: Alignment.bottomCenter,
                                padding: EdgeInsets.all(30),
                                width: MediaQuery.of(context).size.width,
                                height: MediaQuery.of(context).size.height / 2 +
                                    125.0,
                                decoration: BoxDecoration(
                                    color: Colors.yellow[600],
                                    borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(50.0),
                                        topRight: Radius.circular(50.0))),
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      fc,
                                    ]),
                              ),
                            ],
                          ),
                          animationStatus == 0
                              ? new Padding(
                                  padding: const EdgeInsets.only(bottom: 130.0),
                                  child: new InkWell(
                                    onTap: () {
                                      setState(() {
                                        animationStatus = 1;
                                      });
                                      _playAnimation();
                                      //  getUsuario();
                                    },
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: <Widget>[
                                          new SignIn(),
                                          new SignUp()
                                        ]),
                                  ),
                                )
                              : new StaggerAnimation(
                                  buttonController: _loginButtonController.view,
                                  user: fc.usernameController.text,
                                  pass: fc.passwordController.text),
                        ],
                      ),
                    ],
                  ))),
        )));
  }
}
