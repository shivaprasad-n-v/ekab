import 'package:codemagic/splash.dart';
import 'package:flutter/material.dart';
import 'package:codemagic/secrets.dart'; // Stores the Google Maps API Key
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'dart:math' show cos, sqrt, asin;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'taxiit',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home:ScreenShare(),
    );
  }
}

