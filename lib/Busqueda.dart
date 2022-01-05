import 'dart:convert';

import 'package:address_search_field/address_search_field.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../DirectionsProvider.dart';
import '../Punto.dart';

class Busqueda extends StatefulWidget {
  Map<MarkerId, Marker> markers;
  GoogleMapController googleMapController;

  Busqueda({this.markers, this.googleMapController});

  @override
  _BusquedaState createState() => _BusquedaState();
}

class _BusquedaState extends State<Busqueda> {
  final origCtrl = TextEditingController();

  final destCtrl = TextEditingController();

  final polylines = Set<Polyline>();

  LatLng _initialPositon = LatLng(0.317658, -78.208968);

  final geoMethods = GeoMethods(
    /// [Get API key](https://developers.google.com/maps/documentation/embed/get-api-key)
    googleApiKey: 'AIzaSyCvXQE4vCpRyKZh62x-RKPWt-Ep8RrbhVc',
    language: 'es-419',
    countryCode: 'ec',
  );

  @override
  Widget build(BuildContext context) {
    return RouteSearchBox(
      geoMethods: geoMethods,
      originCtrl: origCtrl,
      destinationCtrl: destCtrl,
      builder: (context, originBuilder, destinationBuilder, waypointBuilder,
          waypointsMgr, relocate, getDirections) {
        if (origCtrl.text.isEmpty)
          relocate(AddressId.origin, _initialPositon.toCoords());
        return Container(
          //contenedor para buscar direccion
          height: 50.0,
          width: double.infinity,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0), color: Colors.white),
          child: Column(
            children: [
              Row(children: [
                Flexible(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Ingrese Direccion a Buscar',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.only(left: 15.0, top: 15.0),
                    ),
                    controller: destCtrl,
                    onTap: () => showDialog(
                      context: context,
                      builder: (context) => destinationBuilder.buildDefault(
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
                      widget.markers.clear();
                      // polylines.clear();

                      final markerId = MarkerId("1");
                      final marker = Marker(
                          markerId: markerId,
                          position: result.destination.coords);
                      setState(() {
                        widget.markers[markerId] = marker;
                      });

                      setState(() {});
                      await widget.googleMapController.animateCamera(
                          CameraUpdate.newLatLngBounds(result.bounds, 60.0));
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
    );
  }
}
