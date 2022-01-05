import 'package:flutter/material.dart';

class SignUp extends StatelessWidget {
  SignUp();
  @override
  Widget build(BuildContext context) {
    return (new Padding(
      padding: const EdgeInsets.only(
        top: 30.0,
      ),
      child: new Text(
        "Ha olvidado su contraseña? ",
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
        softWrap: true,
        style: new TextStyle(
            fontWeight: FontWeight.w300,
            letterSpacing: 0.5,
            color: Colors.black,
            fontSize: 12.0),
      ),
    ));
  }
}
