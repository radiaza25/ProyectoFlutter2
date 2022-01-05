import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mytracker/variables.dart';

class Cronometro extends StatefulWidget {
  Function fStart;
  Function fReset;

  Cronometro({Key key, this.fStart, this.fReset}) : super(key: key);

  @override
  _CronometroState createState() => _CronometroState();
}

class _CronometroState extends State<Cronometro> {
  bool _isStart = true;
  String _stopwatchText = '00:00:00';
  final _stopWatch = new Stopwatch();
  final _timeout = const Duration(seconds: 1);

  void _startTimeout() {
    new Timer(_timeout, _handleTimeout);
  }

  void _handleTimeout() {
    if (_stopWatch.isRunning) {
      _startTimeout();
    }
    setState(() {
      _setStopwatchText();
    });
  }

  void _startStopButtonPressed() {
    setState(() {
      if (_stopWatch.isRunning) {
        _isStart = true;
        _stopWatch.stop();
      } else {
        _isStart = false;
        _stopWatch.start();
        _startTimeout();
      }
    });
  }

  void _resetButtonPressed() {
    if (_stopWatch.isRunning) {
      _startStopButtonPressed();
    }
    setState(() {
      _stopWatch.reset();
      _setStopwatchText();
    });
  }

  void _setStopwatchText() {
    carreraTiempo = _stopwatchText;
    _stopwatchText = _stopWatch.elapsed.inHours.toString().padLeft(2, '0') +
        ':' +
        (_stopWatch.elapsed.inMinutes % 60).toString().padLeft(2, '0') +
        ':' +
        (_stopWatch.elapsed.inSeconds % 60).toString().padLeft(2, '0');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
      backgroundColor: Colors.transparent,
    );
  }

  Widget _buildBody() {
    return Container(
      child: Column(
        children: <Widget>[
          Expanded(
            child: Container(
              padding: EdgeInsets.only(right: 11.0, left: 9.0, top: 5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(22.0),
                    topRight: Radius.circular(22.0)),
              ),
              //color: Colors.white,
              width: 210,
              height: 45,
              child: Text(
                _stopwatchText,
                style: TextStyle(fontSize: 28),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Row(
            children: <Widget>[
              Expanded(
                child: Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.only(
                    right: MediaQuery.of(context).size.width * 0.01,
                    left: MediaQuery.of(context).size.width * 0.01,
                    top: MediaQuery.of(context).size.width * 0.01,
                    bottom: MediaQuery.of(context).size.width * 0.01,
                  ),
                  height: 45,
                  decoration: BoxDecoration(
                    color: Color.fromARGB(200, Color(0xfffdd835).red,
                        Color(0xfffdd835).green, Color(0xfffdd835).blue),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(22.0),
                    ),
                  ),
                  child: TextButton(
                      style: TextButton.styleFrom(
                        primary: Colors.white,
                        onSurface: Colors.grey,
                      ),
                      child: Icon(_isStart ? Icons.play_arrow : Icons.stop),
                      onPressed: () {
                        if (_isStart) {
                          _resetButtonPressed();
                        }

                        _startStopButtonPressed();

                        widget.fStart();
                      }),
                ),
              ),
              Expanded(
                child: Container(
                  padding: EdgeInsets.only(
                    right: MediaQuery.of(context).size.width * 0.01,
                    left: MediaQuery.of(context).size.width * 0.01,
                    top: MediaQuery.of(context).size.width * 0.01,
                    bottom: MediaQuery.of(context).size.width * 0.01,
                  ),
                  height: 45,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius:
                        BorderRadius.only(bottomRight: Radius.circular(22.0)),
                  ),
                  child: TextButton(
                      style: TextButton.styleFrom(
                        primary: Colors.white,
                        onSurface: Colors.grey,
                      ),
                      child: Icon(Icons.restart_alt),
                      onPressed: () {
                        _resetButtonPressed();
                        widget.fReset();
                      }),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
