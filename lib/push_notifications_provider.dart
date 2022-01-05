import 'dart:async';
import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:mytracker/variables.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PushNotificationProvider {
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final _mensajesStreamController = StreamController<String>.broadcast();
  Stream<String> get mensajes => _mensajesStreamController.stream;

  Future initialize(context) async {
    _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
  }

  initNotifications() {
    _firebaseMessaging.requestPermission();

    _firebaseMessaging.getToken().then((token) {
      print('======= FCM Token ========');
      print(token);
      keyGen = token;
      putCodigoApp(token);
      //dOFMBqIGR9WY4mjPHyL24S:APA91bHLKBBRAtSQKfHY1Z0B_pcty2Xf3J5L1aPHbyAI7nePBbHa6r_TduYUIHIQNqpqTHL-muEwrljXQQkrqxf_26lB5VzxIi_2RP7lBAOdLT4LPz88y5toDUhWWDbvnqLz1h3_XB8K
      //daZGG6RLS1a6saAno1DhWy:APA91bF-6iI6M5BQoyWNmH_iuZ0bg8wfrH1hx1wH2xGwGS9m1EtZfg1Xb91pF80JqWDjDmEl0bGeTXOrCuUkwDrxLtJUPEO6UWUDjvG8mu4r10s7esCJDhmFduVQ965187QT2iNSQ_I4
    });

    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage message) {
      print('getInitialMessage data: ${message.data}');
    });
    // onMessage: When the app is open and it receives a push notification
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {});

    // replacement for onResume: When the app is in the background and opened directly from the push notification.
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('onMessageOpenedApp data: ${message.data}');
      Navigator.of(contexto).pushNamed('/screen3');
    });
  }

  dispose() {
    _mensajesStreamController.close();
  }
}

Future<Response> putCodigoApp(String token) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final usu = await prefs.getString("usuario");

  Map<String, dynamic> ruta;
  ruta = {"codigoApp": token};
  final response = await put(
    Uri.https('apptaxis2.azurewebsites.net',
        '/Usuario/2/actualizar/codigoApp/' + usu),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(ruta),
  );
  return response;
}
