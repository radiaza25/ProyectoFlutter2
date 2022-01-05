import 'dart:async';

import 'package:flutter/material.dart';
import './InputFields.dart';

class FormContainer extends StatelessWidget {
  final TextEditingController usernameController = new TextEditingController();
  final TextEditingController passwordController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return (new Container(
      margin: new EdgeInsets.symmetric(horizontal: 20.0),
      child: new Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          new Form(
              child: new Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              new Container(
                  decoration: new BoxDecoration(
                    border: new Border(
                      bottom: new BorderSide(
                        width: 0.5,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  child: Text(
                    'COOP 29 DE DICIEMBRE',
                    style: TextStyle(
                        fontSize: 40.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  )),
              new Container(
                decoration: new BoxDecoration(
                  border: new Border(
                    bottom: new BorderSide(
                      width: 0.5,
                      color: Colors.black,
                    ),
                  ),
                ),
                child: new TextFormField(
                  controller: usernameController,
                  obscureText: false,
                  style: const TextStyle(
                    color: Colors.black,
                  ),
                  decoration: new InputDecoration(
                    icon: new Icon(
                      Icons.person_outline,
                      color: Colors.black,
                    ),
                    border: InputBorder.none,
                    hintText: "Usuario",
                    hintStyle:
                        const TextStyle(color: Colors.black, fontSize: 15.0),
                    contentPadding: const EdgeInsets.only(
                        top: 30.0, right: 30.0, bottom: 30.0, left: 5.0),
                  ),
                ),
              ),
              new Container(
                decoration: new BoxDecoration(
                  border: new Border(
                    bottom: new BorderSide(
                      width: 0.5,
                      color: Colors.black,
                    ),
                  ),
                ),
                child: new TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  style: const TextStyle(
                    color: Colors.black,
                  ),
                  decoration: new InputDecoration(
                    icon: new Icon(
                      Icons.lock_outline,
                      color: Colors.black,
                    ),
                    border: InputBorder.none,
                    hintText: "Password",
                    hintStyle:
                        const TextStyle(color: Colors.black, fontSize: 15.0),
                    contentPadding: const EdgeInsets.only(
                        top: 30.0, right: 30.0, bottom: 30.0, left: 5.0),
                  ),
                ),
              ),
            ],
          )),
        ],
      ),
    ));
  }

  void performLogin() {
    String username = passwordController.text;
    String password = usernameController.text;

    print('login attempt: $username with $password');
  }
}
