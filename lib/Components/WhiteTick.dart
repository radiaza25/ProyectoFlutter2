import 'package:flutter/material.dart';

class Tick extends StatelessWidget {
  final DecorationImage image;
  Tick({this.image, Alignment alignment});
  @override
  Widget build(BuildContext context) {
    return (new Container(
      width: 250.0,
      height: 250.0,
      alignment: Alignment.center,
      decoration: new BoxDecoration(
        image: image,
      ),
    ));
  }
}
