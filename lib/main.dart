import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:mytracker/BateryView.dart';
import 'package:mytracker/DirectionsProvider.dart';
import 'package:mytracker/Screens/Login/index.dart';
import 'package:mytracker/ViewNotification.dart';
import 'package:mytracker/ViewRutas.dart';
import 'package:mytracker/push_notifications_provider.dart';
import 'package:mytracker/variables.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'UbicacionCoche.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final usu = await prefs.getString("usuario");
  Future<String> usuario = returnValue().then((value) {
    if (value == null) {
      runApp(MyApp());
    } else {
      runApp(MyApp2());
    }
  });
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application. _initialPositon = await _getPosition();
  final GlobalKey<NavigatorState> navigatorKey =
      new GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DirectionProvider(),
      child: MaterialApp(
        navigatorKey: navigatorKey,
        routes: {
          '/screen0': (BuildContext context) => new LoginScreen(),
          '/screen1': (BuildContext context) => new BateryView(),
          '/screen2': (BuildContext context) => new MyHomePage(),
          '/screen3': (BuildContext context) => new ViewNotification(),
          '/screen4': (BuildContext context) => new ViewRutas(),
        },
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: LoginScreen(),
      ),
    );
  }
}

class MyApp2 extends StatelessWidget {
  // This widget is the root of your application. _initialPositon = await _getPosition();
  final GlobalKey<NavigatorState> navigatorKey =
      new GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DirectionProvider(),
      child: MaterialApp(
        navigatorKey: navigatorKey,
        routes: {
          '/screen0': (BuildContext context) => new LoginScreen(),
          '/screen1': (BuildContext context) => new BateryView(),
          '/screen2': (BuildContext context) => new MyHomePage(),
          '/screen3': (BuildContext context) => new ViewNotification(),
          '/screen4': (BuildContext context) => new ViewRutas(),
        },
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: MyHomePage(),
      ),
    );
  }
}

Future<String> returnValue() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final token = await prefs.getString("usuario");
  return token;
}
