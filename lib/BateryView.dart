import 'package:battery/battery.dart';
import 'package:flutter/material.dart';

import 'package:flutter/foundation.dart';

import 'package:syncfusion_flutter_gauges/gauges.dart';

class BateryView extends StatefulWidget {
  int bateryGPS;
  BateryView({Key key, this.bateryGPS}) : super(key: key);

  @override
  BateryViewState createState() => new BateryViewState();
}

class BateryViewState extends State<BateryView> {
  Battery b = new Battery();
  int showBatteryLevels = 0;
  BatteryState state;
  Color rojo = Colors.red;
  Color verde = Colors.blue;
  Color gris = Colors.grey;
  bool broadcastBattery;

  @override
  void initState() {
    super.initState();
    _broadcastBatteryLevels();
    b.onBatteryStateChanged.listen((event) {
      setState(() {
        state = event;
      });
    });
  }

  _broadcastBatteryLevels() async {
    broadcastBattery = true;
    while (broadcastBattery) {
      var bLvls = await b.batteryLevel;
      setState(() {
        showBatteryLevels = widget.bateryGPS;
      });
      await Future.delayed(Duration(seconds: 5));
    }
  }

  @override
  void dispose() {
    super.dispose();
    setState(() {
      broadcastBattery = false;
    });
  }

//*********Disenio del widget de bateria baja
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.only(top: 1),
                width: MediaQuery.of(context).size.width * 0.15,
                height: MediaQuery.of(context).size.width * 0.15,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(200),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 7,
                        spreadRadius: -5,
                        offset: Offset(4, 4),
                        color: showBatteryLevels <= 10 ? rojo : verde,
                      ),
                    ]),
                child: SfRadialGauge(
                  axes: [
                    RadialAxis(
                      minimum: 0,
                      maximum: 100,
                      startAngle: 270,
                      endAngle: 270,
                      showLabels: false,
                      showTicks: false,
                      axisLineStyle: AxisLineStyle(
                          thickness: 1,
                          color: showBatteryLevels <= 10 ? verde : gris,
                          thicknessUnit: GaugeSizeUnit.factor),
                      pointers: <GaugePointer>[
                        RangePointer(
                          value: double.parse(showBatteryLevels.toString()),
                          width: 0.3,
                          color: Colors.white,
                          pointerOffset: 0.1,
                          cornerStyle: showBatteryLevels == 100
                              ? CornerStyle.bothFlat
                              : CornerStyle.endCurve,
                          sizeUnit: GaugeSizeUnit.factor,
                        )
                      ],
                      annotations: <GaugeAnnotation>[
                        GaugeAnnotation(
                          positionFactor: 0.5,
                          angle: 90,
                          widget: Text(
                            showBatteryLevels == null
                                ? 0
                                : showBatteryLevels.toString() + '%',
                            style: TextStyle(fontSize: 17, color: Colors.white),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  batteryContainer(double size, IconData icon, double iconSize, Color iconColor,
      bool hasGlow) {
    return Container(
      width: size,
      height: size,
      child: Icon(
        icon,
        size: iconSize,
        color: iconColor,
      ),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(100),
          boxShadow: [
            hasGlow
                ? BoxShadow(
                    blurRadius: 10,
                    spreadRadius: 2,
                    offset: Offset(0, 0),
                    color: iconColor)
                : BoxShadow(
                    blurRadius: 7,
                    spreadRadius: -5,
                    offset: Offset(2, 2),
                    color: gris,
                  )
          ]),
    );
  }
}
