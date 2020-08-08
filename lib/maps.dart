import 'dart:math'show cos, sqrt, asin;

import 'package:codemagic/hatch.dart';
import 'package:codemagic/secrets.dart';
import 'package:codemagic/temp/seadan.dart';
import 'package:codemagic/temp/xuv.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapView extends StatefulWidget {
@override
_MapViewState createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  CameraPosition _initialLocation = CameraPosition(target: LatLng(0.0, 0.0));
  GoogleMapController mapController;

  final Geolocator _geolocator = Geolocator();

  Position _currentPosition;
  String _currentAddress;

  final startAddressController = TextEditingController();
  final destinationAddressController = TextEditingController();

  String _startAddress = '';
  String _destinationAddress = '';
  String _placeDistance;

  Set<Marker> markers = {};

  PolylinePoints polylinePoints;
  Map<PolylineId, Polyline> polylines = {};
  List<LatLng> polylineCoordinates = [];

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  Widget _textField({
    TextEditingController controller,
    String label,
    String hint,
    double width,
    Icon prefixIcon,
    Widget suffixIcon,
    Function(String) locationCallback,
  }) {
    return Container(
      width: width * 0.8,
      child: TextField(
        onChanged: (value) {
          locationCallback(value);
        },
        controller: controller,
        decoration: new InputDecoration(
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(10.0),
            ),
            borderSide: BorderSide(
              color: Colors.grey[400],
              width: 2,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(10.0),
            ),
            borderSide: BorderSide(
              color: Colors.blue[300],
              width: 2,
            ),
          ),
          contentPadding: EdgeInsets.all(15),
          hintText: hint,
        ),
      ),
    );
  }

  // Method for retrieving the current location
  _getCurrentLocation() async {
    await _geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) async {
      setState(() {
        _currentPosition = position;
        print('CURRENT POS: $_currentPosition');
        mapController.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(position.latitude, position.longitude),
              zoom: 18.0,
            ),
          ),
        );
      });
      await _getAddress();
    }).catchError((e) {
      print(e);
    });
  }

  // Method for retrieving the address
  _getAddress() async {
    try {
      List<Placemark> p = await _geolocator.placemarkFromCoordinates(
          _currentPosition.latitude, _currentPosition.longitude);

      Placemark place = p[0];

      setState(() {
        _currentAddress =
        "${place.name}, ${place.locality}, ${place.postalCode}, ${place
            .country}";
        startAddressController.text = _currentAddress;
        _startAddress = _currentAddress;
      });
    } catch (e) {
      print(e);
    }
  }

  // Method for calculating the distance between two places
  Future<bool> _calculateDistance() async {
    try {
      // Retrieving placemarks from addresses
      List<Placemark> startPlacemark =
      await _geolocator.placemarkFromAddress(_startAddress);
      List<Placemark> destinationPlacemark =
      await _geolocator.placemarkFromAddress(_destinationAddress);

      if (startPlacemark != null && destinationPlacemark != null) {
        // Use the retrieved coordinates of the current position,
        // instead of the address if the start position is user's
        // current position, as it results in better accuracy.
        Position startCoordinates = _startAddress == _currentAddress
            ? Position(
            latitude: _currentPosition.latitude,
            longitude: _currentPosition.longitude)
            : startPlacemark[0].position;
        Position destinationCoordinates = destinationPlacemark[0].position;

        // Start Location Marker
        Marker startMarker = Marker(
          markerId: MarkerId('$startCoordinates'),
          position: LatLng(
            startCoordinates.latitude,
            startCoordinates.longitude,
          ),
          infoWindow: InfoWindow(
            title: 'Start',
            snippet: _startAddress,
          ),
          icon: BitmapDescriptor.defaultMarker,
        );

        // Destination Location Marker
        Marker destinationMarker = Marker(
          markerId: MarkerId('$destinationCoordinates'),
          position: LatLng(
            destinationCoordinates.latitude,
            destinationCoordinates.longitude,
          ),
          infoWindow: InfoWindow(
            title: 'Destination',
            snippet: _destinationAddress,
          ),
          icon: BitmapDescriptor.defaultMarker,
        );

        // Adding the markers to the list
        markers.add(startMarker);
        markers.add(destinationMarker);

        print('START COORDINATES: $startCoordinates');
        print('DESTINATION COORDINATES: $destinationCoordinates');
        double miny = (startCoordinates.latitude <=
            destinationCoordinates.latitude)
            ? startCoordinates.latitude
            : destinationCoordinates.latitude;
        double minx = (startCoordinates.longitude <=
            destinationCoordinates.longitude)
            ? startCoordinates.longitude
            : destinationCoordinates.longitude;
        double maxy = (startCoordinates.latitude <=
            destinationCoordinates.latitude)
            ? destinationCoordinates.latitude
            : startCoordinates.latitude;
        double maxx = (startCoordinates.longitude <=
            destinationCoordinates.longitude)
            ? destinationCoordinates.longitude
            : startCoordinates.longitude;

        Position _southwestCoordinates = Position(
            latitude: miny,
            longitude: minx
        );
        Position _northeastCoordinates = Position(
            latitude: maxy,
            longitude: maxx
        );
        // Accommodate the two locations within the
        // camera view of the map
        mapController.animateCamera(
          CameraUpdate.newLatLngBounds(
            LatLngBounds(
              northeast: LatLng(
                _northeastCoordinates.latitude,
                _northeastCoordinates.longitude,
              ),
              southwest: LatLng(
                _southwestCoordinates.latitude,
                _southwestCoordinates.longitude,
              ),
            ),
            100.0,
          ),
        );

        // Calculating the distance between the start and the end positions
        // with a straight path, without considering any route
        double distanceInMeters = await Geolocator().bearingBetween(
          startCoordinates.latitude,
          startCoordinates.longitude,
          destinationCoordinates.latitude,
          destinationCoordinates.longitude,
        );

// List of coordinates to join

        await _createPolylines(startCoordinates, destinationCoordinates);


        double totalDistance = 0.0;

        // Calculating the total distance by adding the distance
        // between small segments
        print(" TEGDHFJFJDFK${polylineCoordinates.length}");

        for (int i = 0; i < polylineCoordinates.length - 1; i++) {
          totalDistance += _coordinateDistance(
            polylineCoordinates[i].latitude,
            polylineCoordinates[i].longitude,
            polylineCoordinates[i + 1].latitude,
            polylineCoordinates[i + 1].longitude,
          );
        }

        setState(() {
          _placeDistance = totalDistance.toStringAsFixed(4);
          print('DISTANCE: $_placeDistance km');
        });

        return true;
      }
    } catch (e) {
      print(e);
    }
    return false;
  }

  // Formula for calculating distance between two coordinates
  // https://stackoverflow.com/a/54138876/11910277
  double _coordinateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  // Create the polylines for showing the route between two places
  _createPolylines(Position start, Position destination) async {
    polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      Secrets.API_KEY, // Google Maps API Key
      PointLatLng(start.latitude, start.longitude),
      PointLatLng(destination.latitude, destination.longitude),
      travelMode: TravelMode.driving,
    );

    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }

    PolylineId id = PolylineId('poly');
    Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.red,
      points: polylineCoordinates,
      width: 20,
    );
    polylines[id] = polyline;
  }

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery
        .of(context)
        .size
        .height;
    var width = MediaQuery
        .of(context)
        .size
        .width;
    return Container(
        height: height,
        width: width,
        child: Scaffold(
            key: _scaffoldKey,
            appBar: AppBar(
              backgroundColor: Colors.lightGreen,
            ),
            drawer: Drawer(
              child: Column(
                children: <Widget>[
                  DrawerHeader(child: Container(
                    width: double.infinity,
                    child: CircleAvatar(
                      radius: 8,
                    ),
                  )),
                  Card(
                    child:   ListTile(
                      leading: Icon(Icons.home),
                      title: Text("Home",style: TextStyle(color: Colors.black),),
                    ),
                  ),
                  Card(
                    child:   ListTile(
                      leading: Icon(Icons.notifications_active),
                      title: Text("Notification",style: TextStyle(color: Colors.black),),
                    ),
                  ),
                  Card(
                    child:   ListTile(
                      leading: Icon(Icons.account_balance_wallet),
                      title: Text("Payment",style: TextStyle(color: Colors.black),),
                    ),
                  ),
                  Card(
                    child:   ListTile(
                      leading: Icon(Icons.settings),
                      title: Text("settings",style: TextStyle(color: Colors.black),),
                    ),
                  ),
                  Card(
                    child:   ListTile(
                      leading: Icon(Icons.delete_outline),
                      title: Text("Logout",style: TextStyle(color: Colors.black),),
                    ),
                  )
                ],
              ),
            ),





            body: Stack(
                children: <Widget>[
                  // Map View
                  GoogleMap(
                    markers: markers != null ? Set<Marker>.from(markers) : null,
                    initialCameraPosition: _initialLocation,
                    myLocationEnabled: true,
                    myLocationButtonEnabled: false,
                    mapType: MapType.normal,
                    zoomGesturesEnabled: true,
                    zoomControlsEnabled: false,
                    polylines: Set<Polyline>.of(polylines.values),
                    onMapCreated: (GoogleMapController controller) {
                      mapController = controller;
                    },
                  ),
                  // Show zoom buttons
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          ClipOval(
                            child: Material(
                              color: Colors.blue[100], // button color
                              child: InkWell(
                                splashColor: Colors.blue, // inkwell color
                                child: SizedBox(
                                  width: 50,
                                  height: 50,
                                  child: Icon(Icons.add),
                                ),
                                onTap: () {
                                  mapController.animateCamera(
                                    CameraUpdate.zoomIn(),
                                  );
                                },
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          ClipOval(
                            child: Material(
                              color: Colors.blue[100], // button color
                              child: InkWell(
                                splashColor: Colors.blue, // inkwell color
                                child: SizedBox(
                                  width: 50,
                                  height: 50,
                                  child: Icon(Icons.remove),
                                ),
                                onTap: () {
                                  mapController.animateCamera(
                                    CameraUpdate.zoomOut(),
                                  );
                                },
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  // Show the place input fields & button for
                  // showing the route
                  SafeArea(
                      child: Align(
                          alignment: Alignment.topCenter,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 10.0),


                            child: Padding(
                              padding: const EdgeInsets.only(
                                  top: 10.0, bottom: 10.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Text(
                                    'Places',
                                    style: TextStyle(fontSize: 20.0),
                                  ),
                                  SizedBox(height: 10),
                                  _textField(
                                      label: 'Start',
                                      hint: 'Choose starting point',
                                      prefixIcon: Icon(Icons.looks_one),
                                      suffixIcon: IconButton(
                                        icon: Icon(Icons.my_location),
                                        onPressed: () {
                                          startAddressController.text =
                                              _currentAddress;
                                          _startAddress = _currentAddress;
                                        },
                                      ),
                                      controller: startAddressController,
                                      width: width,
                                      locationCallback: (String value) {
                                        setState(() {
                                          _startAddress = value;
                                        });
                                      }),
                                  SizedBox(height: 10),
                                  _textField(
                                      label: 'Destination',
                                      hint: 'Choose destination',
                                      prefixIcon: Icon(Icons.looks_two),
                                      controller: destinationAddressController,
                                      width: width,
                                      locationCallback: (String value) {
                                        setState(() {
                                          _destinationAddress = value;
                                        });
                                      }),
                                  SizedBox(height: 10),

                                  SizedBox(height: 5),


                                  // Show current location button
                                  SafeArea(
                                    child: Align(
                                      alignment: Alignment.bottomRight,
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            right: 10.0, bottom: 10.0),
                                        child: ClipOval(
                                          child: Material(
                                            color: Colors.orange[100],
                                            // button color
                                            child: InkWell(
                                              splashColor: Colors.orange,
                                              // inkwell color
                                              child: SizedBox(
                                                width: 56,
                                                height: 56,
                                                child: Icon(Icons.my_location),
                                              ),
                                              onTap: () {
                                                mapController.animateCamera(
                                                  CameraUpdate
                                                      .newCameraPosition(
                                                    CameraPosition(
                                                      target: LatLng(
                                                        _currentPosition
                                                            .latitude,
                                                        _currentPosition
                                                            .longitude,
                                                      ),
                                                      zoom: 18.0,
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ))),
                  GestureDetector(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        height: 50,
                        width: 390,
                        color: Colors.green,
                        child: Center(child: Text(
                          "Book Now", style: TextStyle(color: Colors.white,),)),
                      ),
                    ),
                    onTap:(_startAddress != '' &&
    _destinationAddress != '')
    ? () async {
                      setState(() {
                        if (markers.isNotEmpty) markers.clear();
                        if (polylines.isNotEmpty)
                          polylines.clear();
                        if (polylineCoordinates.isNotEmpty)
                          polylineCoordinates.clear();
                        _placeDistance = null;
                      });

                      _calculateDistance().then((isCalculated) {
                        if (isCalculated) {
                          _scaffoldKey.currentState.showSnackBar(
                            SnackBar(
                              content: Text(
                                  'Distance Calculated Sucessfully'),
                            ),

                          ); popup(context);
                        } else {
                          _scaffoldKey.currentState.showSnackBar(
                            SnackBar(
                              content: Text(
                                  'Error Calculating Distance'),
                            ),
                          );
                          popup(context);
                        }
                      });

                    }

                    :null
                  )


                ])));
  }

  void popup(context) {
    showModalBottomSheet(context: context, builder: (BuildContext bc) {
      return ListView(
        children: [
          Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(

                  topLeft: Radius.circular(30), topRight: Radius.circular(20),
                ),
              ),
              child: Column(

                children: [
                  SizedBox(height: 8,),
                  GestureDetector(
                    onTap: (){

                      Navigator.push(
                          context, MaterialPageRoute(builder: (context) => hatch()));

                    },
                    child: Card(
                      elevation: 30,

                      child: Container(
                        height: 100,
                        child: Row(
                          children: [
                            SizedBox(width: 8,),
                            Container(
                              height: 90,
                              width: 120,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                    image: AssetImage("assets/hatch.jpeg")),
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            SizedBox(width: 8,),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("sedan/hatch(4seaters)", style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 20),),
                                SizedBox(height: 8,),
                                Text("Price:350")

                              ],
                            )


                          ],
                        ),
                      ),
                    ),

                  ),
                  SizedBox(height: 8,),
                  GestureDetector(
                    onTap: (){

                      Navigator.push(
                          context, MaterialPageRoute(builder: (context) => sedian()));

                    },
                    child: Card(
                      elevation: 30,

                      child: Container(
                        height: 100,
                        child: Row(
                          children: [
                            SizedBox(width: 8,),
                            Container(
                              height: 90,
                              width: 120,
                              decoration: BoxDecoration(

                                image: DecorationImage(
                                    image: AssetImage("assets/siden.png")),
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            SizedBox(width: 8,),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Luxury (4+1 seaters)", style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 20),),
                                SizedBox(height: 8,),
                                Text("Price:120")

                              ],
                            )


                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 8,),
                  GestureDetector(
                    onTap: (){

                      Navigator.push(
                          context, MaterialPageRoute(builder: (context) => xuv()));

                    },
                    child: Card(
                      elevation: 30,

                      child: Container(
                        height: 100,
                        child: Row(
                          children: [
                            SizedBox(width: 8,),
                            Container(
                              height: 90,
                              width: 120,
                              decoration: BoxDecoration(

                                image: DecorationImage(
                                    image: AssetImage("assets/muv.png")),
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            SizedBox(width: 8,),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("XUV/MUV(7 seaters)", style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 20),),
                                SizedBox(height: 8,),
                                Text("Price:350")

                              ],
                            )


                          ],
                        ),
                      ),
                    ),
                  ),


                ],
              )


          ),
        ],
      );
    }


    );
  }
}