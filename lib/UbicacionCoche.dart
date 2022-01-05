import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:address_search_field/address_search_field.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_sms/flutter_sms.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:maps_toolkit/maps_toolkit.dart' as tk;
import 'package:mytracker/BateryView.dart';
import 'package:mytracker/DirectionsProvider.dart';
import 'package:mytracker/GenerarRuta.dart';
import 'package:mytracker/cronometro.dart';
import 'package:mytracker/push_notifications_provider.dart';
import 'package:mytracker/variables.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sms/sms.dart';
import 'package:url_launcher/url_launcher.dart';

import 'Components/List.dart';
import 'Botones.dart';
import 'MensajesProvider.dart';
import 'Punto.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title = ''}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int switchanimateCamera;
  StreamSubscription periodicSub;
  StreamSubscription periodicRuta;
  StreamSubscription pruebaMensaje;
  Boton b = new Boton();
  bool _isVisible = true;
  bool _cronometro = false;
  bool _generarRuta = false;
  bool _parar = false;

  bool _darkMode = false;
  StreamSubscription _streamSubscription;
  Location _tracker = Location();
  Marker marker;
  Map<MarkerId, Marker> _markers = Map();
  Circle circle;
  GoogleMapController _googleMapController;
  Location location;
  LocationData loc;
  List<Punto> ubicaciones = new List();
  int contador = 0;
  bool seguiminento = false;
  bool compartirSeguimiento = false;
  Color colorCompartir = Colors.grey;
  Color colorGuardarU = Colors.grey;
  SmsQuery query = new SmsQuery();
  FirebaseAnalytics mFirebaseAnalytics;
  LatLng actual;
  double dir;
  double velocidad;
  ListData ld = new ListData();
  int cont = 0;
  final origCtrl = TextEditingController();
  final destCtrl = TextEditingController();
  final polylines = Set<Polyline>();
  LatLng _initialPositon = LatLng(0.317658, -78.208968);
  Cronometro c = new Cronometro();
  int bateria = 0;
  double costo;
  final geoMethods = GeoMethods(
    googleApiKey: 'AIzaSyD3__Hy3qxzP6OBbTTJfhDD4miTppV1O10',
    language: 'es-419',
    countryCode: 'ec',
  );

//Posicion de camara inicial
  static final CameraPosition initialLocation = CameraPosition(
    target: LatLng(0.317658, -78.208968),
    zoom: 14.4746,
  );
//metodos de inicio de estados de notificaciones push
  @override
  void initState() {
    super.initState();
    final pushProvider = new PushNotificationProvider();
    pushProvider.initNotifications();
  }

  //visibilidad de menu de opciones
  void showMenuOptions() {
    setState(() {
      _isVisible = !_isVisible;
    });
  }

//visibilidad de cronometro de carreras
  void showCronometroCarrera() {
    setState(() {
      _cronometro = !_cronometro;
    });
  }

//visibilidad de actualizacion de ruta mas corta
  void showGenerarRuta() {
    setState(() {
      _generarRuta = !_generarRuta;
    });
  }

  //funcion para marcar al 911
  Future<void> _launched;
  String _phone = '911';
  Future<void> _makePhoneCall(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  bool switchValue = false;
  //cambiar tema del mapa
  changeMapMode() {
    setState(() {
      if (_darkMode == true) {
        getJsonFile("assets/json/light.json").then(setMapStyle);
      } else {
        getJsonFile("assets/json/night.json").then(setMapStyle);
      }
    });
  }

  Future<String> getJsonFile(String path) async {
    return await rootBundle.loadString(path);
  }

  void setMapStyle(String mapStyle) {
    _googleMapController.setMapStyle(mapStyle);
  }

  @override
  void dispose() {
    if (_streamSubscription != null ||
        periodicRuta != null ||
        periodicSub != null) {
      _streamSubscription.cancel();
      periodicSub.cancel();
      periodicRuta.cancel();
    }

    super.dispose();
  }

// ***************************Funcion guardar ruta actual *****************************************
  Future<http.Response> postRutas() async {
    Map<String, dynamic> ruta; //creo una nueva ruta
    List<LatLng> list = await ld.convertToLatLng(
        ubicaciones); //convierto a lista de formato LatLng la lista de ubicaciones
    var api = Provider.of<DirectionProvider>(context,
        listen: false); // instancia de la clase Direction Provider
    double totalkm = api.calcularKilometraje(list); //calculo el kilometraje
    DateTime dt = DateTime.now(); //obtiene fecha y hora actual
    String a = dt.toIso8601String(); // transforma a formato ISO
    ruta = {
      //crea el contenido de POST
      "carreraId": {},
      "usuario": "1003943832",
      "kilometro": totalkm,
      "tiempo": carreraTiempo,
      "costo": precio(totalkm),
      "createAt": a,
      "carrera": []
    };
    var listMap = ubicaciones
        .map((punto) => punto.toMap()); // extrae lat y lng de las ubicaciones
    ruta['carrera'].addAll(
        listMap); //agrega las latitudes y longitudes al contenido de POST
    final response = await http.post(
      //envia post al API
      Uri.https('apptaxis2.azurewebsites.net', '/Carrera/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(ruta),
    );
    return response;
  }

//******************** Actualiza  los datos la ubicacion del vehiculo **************************************
  Future<void> updateMarker(Uint8List imageData) async {
    Map<dynamic, dynamic> m;
    final response = await http.get(
      Uri.parse('https://flespi.io/gw/devices/2204321/messages'),
      headers: {
        HttpHeaders.authorizationHeader:
            'FlespiToken 00373P8oA5gngylXvcxMmPICEBbcs9ZiZSdQvc3V599cwiXRkltvY0VqpUsHUhQH',
      },
    ).then((response) {
      if (response.statusCode == 200) {
        String body = utf8.decode(response.bodyBytes);
        final jsonData = jsonDecode(body);
        List a = jsonData["result"];
        m = a.last;
        dir = m["position.direction"].toDouble();
        actual = LatLng(m["position.latitude"], m["position.longitude"]);
        setState(() {
          bateria = m["battery.level"];
        });
        if (seguiminento == true) {
          ubicaciones.add(new Punto(
              lat: m["position.latitude"],
              lng: m["position.longitude"],
              time: m["server.timestamp"],
              speed: m["position.speed"].toDouble(),
              altitude: m["position.altitude"].toDouble()));
        }
      }

      this.setState(() {
        marker = Marker(
            markerId: MarkerId("0"),
            position: actual, //posible error aqui
            rotation: m["position.direction"].toDouble(),
            draggable: false,
            zIndex: 2,
            flat: true,
            anchor: Offset(0.5, 0.5),
            icon: BitmapDescriptor.fromBytes(imageData));
        setState(() {
          _markers[marker.markerId] = marker;
        });
        circle = Circle(
            circleId: CircleId("carro"),
            radius: 10.0,
            zIndex: 1,
            strokeColor: Colors.blue,
            center: actual,
            fillColor: Colors.blue.withAlpha(70));
      });

      cont++;

      if (cont == 10) {
        var api = Provider.of<MensajesProvider>(context, listen: false);
        api.enviarNotificacion();
      }
      verificarCerca().then((value) {
        if (value == true) {
          if (m["position.speed"] > 40) {
            buildDialog(
                context, new Text("Has sobrepasado el limite de velocidad"));
            enviarNotificacion();
          }
        }
      });
    });
  }

  //***********************Anexa las polilineas de la visualizacion de rutas al mapa
  Map<MarkerId, Marker> unir() {
    var api = Provider.of<DirectionProvider>(context, listen: false);
    if (api.fin != null || api.inicio != null) {
      _markers[api.fin.markerId] = api.fin;
      _markers[api.inicio.markerId] = api.inicio;
    }
    if (api.alert != null) {
      _markers[api.alert.markerId] = api.alert;
    }
    return _markers;
  }

//******************* Obtiene la imagen del automovil **************************
  Future<Uint8List> getMarkerCar() async {
    ByteData byteData =
        await DefaultAssetBundle.of(context).load("assets/images/auto.png");
    return byteData.buffer.asUint8List();
  }

//**********************coloca un marcador al realizar tap en el mapa***********
  _onTap(LatLng position) {
    final markerId = MarkerId("1");
    final marker = Marker(markerId: markerId, position: position);
    setState(() {
      _markers[markerId] = marker;
    });
  }

//***********************actualiza el marcador del automovil********************
  void getCurrentLocationCar() async {
    Uint8List imageData = await getMarkerCar();
    updateMarker(imageData);
  }

//***********************actualiza la camara del mapa***************************
  void moverCamara() {
    if (_googleMapController != null) {
      _googleMapController.animateCamera(CameraUpdate.newCameraPosition(
          new CameraPosition(bearing: dir, target: actual, zoom: 18.00)));
    }
  }

//*******Obtiene la ruta mas corta mediante pubto de partida y destino**********
  Future<void> getRuta() async {
    Marker m;
    for (var v in _markers.values) {
      if (v.markerId.value.contains('1')) {
        m = v;
      }
    }
    LatLng latlng = LatLng(actual.latitude, actual.longitude);
    var api = Provider.of<DirectionProvider>(context, listen: false);
    api.findDirections(latlng, m.position);
  }

//***********************actualiza la ruta mas corta****************************
  void actualizarRuta() {
    var api = Provider.of<DirectionProvider>(context, listen: false);
    api.actualizarRuta(actual);
  }

//******************Disenio de menu principal***********************************
  @override
  Widget build(BuildContext context) {
    contexto = context;
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Consumer<DirectionProvider>(
              builder:
                  (BuildContext context, DirectionProvider api, Widget Child) {
                return GoogleMap(
                  zoomGesturesEnabled: true,
                  initialCameraPosition: initialLocation,
                  markers: Set.of(unir().values),
                  polylines: api.currentRoute,
                  circles: api.currentCircle,
                  onMapCreated: (GoogleMapController controller) {
                    _googleMapController = controller;
                  },
                  onTap: _onTap,
                );
              },
            ),
          ),
          Expanded(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.75,
              height: MediaQuery.of(context).size.width * 0.25,
              margin: EdgeInsets.only(
                top: MediaQuery.of(context).size.width * 1.60,
                right: MediaQuery.of(context).size.width * 0.20,
                left: MediaQuery.of(context).size.width * 0.21,
                bottom: MediaQuery.of(context).size.width * 0.05,
              ),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    FloatingActionButton(
                      onPressed: () {
                        showMenuOptions();
                      },
                      child: const Icon(Icons.menu),
                      backgroundColor: Colors.green,
                    ),
                    FloatingActionButton(
                      onPressed: () {
                        periodicSub =
                            new Stream.periodic(const Duration(seconds: 3))
                                .listen((_) => getCurrentLocationCar());
                        moverCamara();
                      },
                      child: const Icon(Icons.location_searching),
                      backgroundColor: Colors.green,
                    ),
                    FloatingActionButton(
                      onPressed: () {
                        posicion3D();
                      },
                      child: const Icon(Icons.navigation),
                      backgroundColor: Colors.green,
                    ),
                  ]),
            ),
          ),
          RouteSearchBox(
            geoMethods: geoMethods,
            originCtrl: origCtrl,
            destinationCtrl: destCtrl,
            builder: (context, originBuilder, destinationBuilder,
                waypointBuilder, waypointsMgr, relocate, getDirections) {
              if (origCtrl.text.isEmpty)
                relocate(AddressId.origin, _initialPositon.toCoords());
              return Container(
                margin: EdgeInsets.only(top: 30),
                height: 50.0,
                width: double.infinity,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    color: Colors.white),
                child: Column(
                  children: [
                    Row(children: [
                      Flexible(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Ingrese Direccion a Buscar',
                            border: InputBorder.none,
                            contentPadding:
                                EdgeInsets.only(left: 15.0, top: 15.0),
                          ),
                          controller: destCtrl,
                          onTap: () => showDialog(
                            context: context,
                            builder: (context) =>
                                destinationBuilder.buildDefault(
                              builder:
                                  AddressDialogBuilder(), // es el encargado de configurar el cuadro
                              onDone: (address) => null,
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.search),
                        onPressed: () async {
                          try {
                            final result = await getDirections();
                            final markerId = MarkerId("1");
                            final marker = Marker(
                                markerId: markerId,
                                position: result.destination.coords);
                            setState(() {
                              _markers[markerId] = marker;
                            });
                            setState(() {});
                            await _googleMapController.animateCamera(
                                CameraUpdate.newLatLngBounds(
                                    result.bounds, 60.0));
                          } catch (e) {
                            print(e);
                          }
                        },
                        iconSize: 30.0,
                      ),
                    ]),
                  ],
                ),
              );
            },
          ),
          Expanded(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.75,
              height: MediaQuery.of(context).size.width * 0.16,
              margin: EdgeInsets.only(
                top: MediaQuery.of(context).size.width * 0.25,
                right: MediaQuery.of(context).size.width * 0.05,
                left: MediaQuery.of(context).size.width * 0.8,
                bottom: MediaQuery.of(context).size.width * 0.5,
              ),
              child: BateryView(
                bateryGPS: bateria,
              ),
            ),
          ),
          Visibility(
            visible: _cronometro,
            child: Container(
              margin:
                  EdgeInsets.only(top: 100, right: 90, left: 90, bottom: 50),
              alignment: Alignment.center,
              height: 130,
              width: 250,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.black.withOpacity(0.4)),
              child: Cronometro(
                fStart: () {
                  if (seguiminento == true) {
                    postRutas().then((function) => ubicaciones.clear());
                    buildDialog(
                        context, new Text("Ruta guardada correctamente"));
                  } else {
                    buildDialog(context, new Text("Guardando ruta!"));
                  }
                  activaSeguimiento();
                },
                fReset: () {
                  ubicaciones.clear();
                },
              ),
              padding: EdgeInsets.all(20),
            ),
          ),
          Visibility(
            visible: _generarRuta,
            child: Container(
              margin:
                  EdgeInsets.only(top: 100, right: 90, left: 90, bottom: 50),
              alignment: Alignment.center,
              height: 130,
              width: 250,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.black.withOpacity(0.4)),
              child: GenerarRuta(
                fStart: () {
                  var api =
                      Provider.of<DirectionProvider>(context, listen: false);
                  api.fin = null;
                  api.inicio = null;
                  _markers.removeWhere((key, v) => v.markerId.value == "3");
                  _markers.removeWhere((key, v) => v.markerId.value == "4");

                  if (_markers.values.elementAt(0) ==
                      _markers.values.elementAt(1)) {
                    buildDialog(context, new Text("Ha llegado a su destino"));
                    periodicRuta.cancel();
                  } else {
                    periodicRuta =
                        new Stream.periodic(const Duration(seconds: 5))
                            .listen((_) => getRuta());
                  }
                },
                fReset: () {
                  if (periodicRuta != null) {
                    periodicRuta.cancel();
                  }
                },
              ),
              padding: EdgeInsets.all(20),
            ),
          ),
          Visibility(
            visible: _isVisible,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(22.0),
                    topRight: Radius.circular(22.0)),
              ),
              margin: EdgeInsets.only(
                  top: MediaQuery.of(context).size.width * 0.3,
                  right: MediaQuery.of(context).size.width * 0.6),
              alignment: Alignment.centerLeft,
              height: 620,
              width: 65,
              child: ListView(
                  shrinkWrap: true,
                  padding: EdgeInsets.all(5.0),
                  children: <Widget>[
                    SizedBox(
                      width: 10.0,
                    ),
                    new Switch(
                      activeColor: Colors.black87,
                      onChanged: (newValue) {
                        setState(() {
                          this.switchValue = newValue;
                          _darkMode = newValue;
                          changeMapMode();
                        });
                      },
                      value: switchValue,
                    ),
                    new Boton(
                        icon: Icon(Icons.save),
                        color: Colors.greenAccent,
                        pAction: () {
                          if (periodicRuta != null) {
                            periodicRuta.cancel();
                          }
                          Navigator.of(context).pushNamed('/screen4');
                        }),
                    new Boton(
                        icon: Icon(Icons.add_road_outlined),
                        color: Colors.orangeAccent,
                        pAction: () {
                          showGenerarRuta();
                          setState(() {
                            if (_cronometro) {
                              _cronometro = !_cronometro;
                            }
                          });
                        }),
                    new Boton(
                        icon: Icon(Icons.tour_sharp),
                        color: Colors.blueGrey,
                        pAction: () {
                          showCronometroCarrera();
                          setState(() {
                            if (_generarRuta) {
                              _generarRuta = !_generarRuta;
                            }
                          });
                        }),
                    new Boton(
                        icon: Icon(Icons.mail),
                        pAction: () {
                          Navigator.of(context).pushNamed('/screen3');
                        }),
                    new Boton(
                        icon: Icon(Icons.exit_to_app_outlined),
                        color: Colors.redAccent,
                        pAction: () async {
                          SharedPreferences preferences =
                              await SharedPreferences.getInstance();
                          await preferences.clear();
                          Navigator.of(context)
                              .pushReplacementNamed('/screen0');
                        }),
                    new Boton(
                        icon: Icon(Icons.people),
                        color: Colors.indigoAccent,
                        pAction: () async {
                          setState(() {
                            var api = Provider.of<DirectionProvider>(context,
                                listen: false);

                            api.findClusteres(3);
                          });
                        }),
                    new Boton(
                        icon: Icon(Icons.warning),
                        color: Colors.red,
                        pAction: () async {
                          enviarNotificacionEmergencia();
                        })
                  ]),
            ),
          ),
        ],
      ),
    );
  }
//******************activacion del seguimiento del automovil********************

  void activaSeguimiento() {
    if (seguiminento == true) {
      seguiminento = false;
    } else {
      seguiminento = true;
    }
  }
//***********************Vista en 3d del mapa principal*************************

  void posicion3D() {
    if (_googleMapController != null) {
      _googleMapController.animateCamera(
        CameraUpdate.newCameraPosition(new CameraPosition(
            bearing: dir,
            target: actual,
            tilt: 89.440717697143555,
            zoom: 25.00)),
      );
    }
  }
//***********************calculo de la tarifa de costo**************************
  double precio(double kilometro) {
    costo = 0;
    if (kilometro < 3) {
      costo = 1.25;
    }
    if (kilometro >= 3 && kilometro < 10) {
      double tar = 0.40;
      costo = 2.00 + (tar * (kilometro - 3));
    }
    if (kilometro > 10 && kilometro <= 15) {
      costo = 4.90;
    }
    if (kilometro > 15 && kilometro <= 20) {
      costo = 7.00;
    }
    if (kilometro > 20 && kilometro <= 25) {
      costo = 9.10;
    }
    if (kilometro > 25 && kilometro <= 30) {
      costo = 11.20;
    }
    if (kilometro > 30 && kilometro <= 40) {
      costo = 13.30;
    }
    if (kilometro > 40 && kilometro <= 50) {
      costo = 17.50;
    }
    if (kilometro > 50) {
      costo = 21.70;
    }
    return costo;
  }
//***************verifica si se encuentra dentro de la geocerca*****************
  Future<bool> verificarCerca() async {
    List<tk.LatLng> p = new List();
    bool a = false;
    tk.LatLng m = new tk.LatLng(actual.latitude, actual.longitude);
    final response = await http
        .get(Uri.https('apptaxis2.azurewebsites.net', '/Cerca'))
        .then((response) {
      if (response.statusCode == 200) {
        String body = utf8.decode(response.bodyBytes);
        final jsonData = jsonDecode(body);
        Map<String, dynamic> sd = jsonData.last;
        List<dynamic> l = sd['cercaPuntos'];
        for (final e in l) {
          p.add(new tk.LatLng(e['latitud'], e['longitud']));
        }
      }
    });
    a = tk.PolygonUtil.containsLocation(m, p, false);
    return a;
  }
//*****************centraliza la vista del mapa en un objetivo******************

  LatLngBounds bordePuntos(LatLng offerLatLng, LatLng currentLatLng) {
    LatLngBounds bound;
    if (offerLatLng.latitude > currentLatLng.latitude &&
        offerLatLng.longitude > currentLatLng.longitude) {
      bound = LatLngBounds(southwest: currentLatLng, northeast: offerLatLng);
    } else if (offerLatLng.longitude > currentLatLng.longitude) {
      bound = LatLngBounds(
          southwest: LatLng(offerLatLng.latitude, currentLatLng.longitude),
          northeast: LatLng(currentLatLng.latitude, offerLatLng.longitude));
    } else if (offerLatLng.latitude > currentLatLng.latitude) {
      bound = LatLngBounds(
          southwest: LatLng(currentLatLng.latitude, offerLatLng.longitude),
          northeast: LatLng(offerLatLng.latitude, currentLatLng.longitude));
    } else {
      bound = LatLngBounds(southwest: offerLatLng, northeast: currentLatLng);
    }
    return bound;
  }
}

Future<Widget> buildDialog(BuildContext contexto, Text content) async {
  return showDialog(
      context: contexto,
      builder: (buildcontext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(32.0))),
          title: Text("Atencion!"),
          content: content,
          actions: <Widget>[
            Container(
              height: 50,
              alignment: Alignment.center,
              child: RaisedButton(
                color: Colors.black,
                child: Text(
                  "CERRAR",
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  Navigator.of(contexto).pop();
                },
              ),
            )
          ],
        );
      });
}

Future<void> enviarNotificacion() async {
  final ByteData bytes2 = await rootBundle.load('assets/meta.png');
  final Uint8List list2 = bytes2.buffer.asUint8List();
  final response = await http
      .post(
    Uri.https('fcm.googleapis.com', '/fcm/send'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization':
          'key=AAAA6uAzADk:APA91bGIvOyNB2wOVEZNk3QB0JQcCRZ6MPRF-RiXcJiybPKeI8M9f3Iu6OxmQKozfoKqH7UzYsQDPScYZ-eRdxvyNK2qZyQXLlVUZR5c8_Hj-LDMiD01cBa5L09VANLM3TZLZIadTGyY'
    },
    body: jsonEncode({
      "to": keyGen,
      "notification": {
        "body": "Limite de velocidad excedido",
        "OrganizationId": "2",
        "content_available": true,
        "priority": "high",
        "subtitle": "Elementary School",
        "Title": "Alerta de exceso de velocidad",
        "image": list2
      },
      "data": {
        "click_action": "FLUTTER_NOTIFICATION_CLICK",
        "priority": "high",
        "sound": "app_sound.wav",
        "content_available": true,
        "bodyText": "estas siendo asaltado por el tuculu",
        "organization": "Elementary school"
      }
    }),
  )
      .then((response) {
    if (response.statusCode == 200) {
      int a = 1;
    }
  });
}

Future<void> enviarNotificacionBateria() async {
  final ByteData bytes2 = await rootBundle.load('assets/meta.png');
  final Uint8List list2 = bytes2.buffer.asUint8List();
  final response = await http
      .post(
    Uri.https('fcm.googleapis.com', '/fcm/send'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization':
          'key=AAAA6uAzADk:APA91bGIvOyNB2wOVEZNk3QB0JQcCRZ6MPRF-RiXcJiybPKeI8M9f3Iu6OxmQKozfoKqH7UzYsQDPScYZ-eRdxvyNK2qZyQXLlVUZR5c8_Hj-LDMiD01cBa5L09VANLM3TZLZIadTGyY'
    },
    body: jsonEncode({
      "to": keyGen,
      "notification": {
        "body": "Bateria de dispositivo GPS baja",
        "OrganizationId": "2",
        "content_available": true,
        "priority": "high",
        "subtitle": "Se requiere carga inmediatamente",
        "Title": "Alerta de bateria baja",
        "image": list2
      },
      "data": {
        "click_action": "FLUTTER_NOTIFICATION_CLICK",
        "priority": "high",
        "sound": "app_sound.wav",
        "content_available": true,
        "bodyText": "estas siendo asaltado por el tuculu",
        "organization": "Elementary school"
      }
    }),
  )
      .then((response) {
    if (response.statusCode == 200) {
      int a = 1;
    }
  });
}

Future<void> enviarNotificacionEmergencia() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final usu = await prefs.getString("usuario");
  final nombre = await prefs.getString("nombre");
  final response = await http
      .get(Uri.https('apptaxis2.azurewebsites.net', '/Usuario'))
      .then((response) async {
    if (response.statusCode == 200) {
      String body = utf8.decode(response.bodyBytes);
      final jsonData = jsonDecode(body);

      for (final e in jsonData) {
        if (e['codigoApp'] != null && e['cedula'] != usu) {
          final response = await http
              .post(
            Uri.https('fcm.googleapis.com', '/fcm/send'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
              'Authorization':
                  'key=AAAA6uAzADk:APA91bGIvOyNB2wOVEZNk3QB0JQcCRZ6MPRF-RiXcJiybPKeI8M9f3Iu6OxmQKozfoKqH7UzYsQDPScYZ-eRdxvyNK2qZyQXLlVUZR5c8_Hj-LDMiD01cBa5L09VANLM3TZLZIadTGyY'
            },
            body: jsonEncode({
              "to": e['codigoApp'],
              "notification": {
                "body": "" + nombre + " esta problemas ayudalo",
                "OrganizationId": "2",
                "content_available": true,
                "priority": "high",
                "subtitle": "Ayuda a tu compañero",
                "Title": "Alerta Peligro",
              },
              "data": {
                "click_action": "FLUTTER_NOTIFICATION_CLICK",
                "priority": "high",
                "sound": "app_sound.wav",
                "content_available": true,
                "bodyText": "estas siendo asaltado por el tuculu",
                "organization": "Elementary school"
              }
            }),
          )
              .then((response) async {
            if (response.statusCode == 200) {
              int a = 1;
              var not = {
                "choferId": e['cedula'],
                "title": "Alerta de Panico",
                "bodyText": "El usuario " + nombre + " tiene problemas",
                "lugar": {
                  "latitud": 0.325387,
                  "longitud": -78.212328,
                }
              };

              final response2 = await http.post(
                Uri.https('apptaxis2.azurewebsites.net', '/Notificacion/'),
                headers: <String, String>{
                  'Content-Type': 'application/json; charset=UTF-8',
                },
                body: jsonEncode(not),
              );
            }
          });
        }
      }
    }
  });
}
