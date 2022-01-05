import 'package:flutter/material.dart';

DecorationImage backgroundImage = new DecorationImage(
  image: new ExactAssetImage('assets/login.jpg'),
  fit: BoxFit.cover,
  colorFilter:
      new ColorFilter.mode(Colors.yellow.withOpacity(0.2), BlendMode.dstATop),
);

DecorationImage tick = new DecorationImage(
  image: new ExactAssetImage('assets/icono.png'),
  fit: BoxFit.cover,
);

DecorationImage fondo = new DecorationImage(
  image: new ExactAssetImage('assets/fondotaxi.jpg'),
  fit: BoxFit.cover,
);

DecorationImage meta = new DecorationImage(
  image: new ExactAssetImage('assets/meta.png'),
  fit: BoxFit.cover,
);
