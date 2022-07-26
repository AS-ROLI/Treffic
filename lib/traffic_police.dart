import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sts/login_screen.dart';
import 'package:sts/patient_info_fill.dart';
import 'package:sts/registration.dart';
import 'package:sts/single_patient.dart';
import 'package:sts/patient_list.dart';
import 'package:sts/traffic_police.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math';
import 'package:location/location.dart';

class traffic_police extends StatefulWidget {
  @override
  static const String id = 'traffic_police';
  _traffic_policeState createState() => _traffic_policeState();
}

class _traffic_policeState extends State<traffic_police> {
  @override

  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
late  User loggedInUser;
late  Future _future;

  var no_of_coordinates = 0;
  var plat = 0.0, plong = 0.0;
late  CameraPosition _initialPosition;
  final Set<Marker> _markers = Set();
  Completer<GoogleMapController> _controller = Completer();


  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  Future getCurrentUser() async {
    try {
      final user = await _auth.currentUser;
      if (user != null) {
        loggedInUser = user;
        print(loggedInUser.email);
      }
    } catch (e) {
      print(e);
      print(";_;");
    }
  }

  void initState() {
    super.initState();
    _future = getCurrentUser();
    var _location = getPoliceLocation();

  }

  void getPoliceLocation() async {

    Position position = _getCurrentLocation();
    plat = position.latitude;
    plong = position.longitude;
  }

  void ConfirmLogOut(BuildContext context) async{
    var alertDialog = AlertDialog(
      title: Text("Log Out?"),
      content: Text("Do you want to log out?"),
      actions: [
        FlatButton(
            child: Text("No"),
            onPressed: (){
              Navigator.pop(context);
            }
        ),
        FlatButton(
            child: Text("Yes"),
            onPressed: () async {
              await _auth.signOut();
              Navigator.pushNamed(context, login_screen.id) ;
            }
        ),
      ],
    );
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return alertDialog;
        }
    );
  }

  double getDistanceFromLatLonInKm(lat1,lon1,lat2,lon2) {
    var R = 6371; // Radius of the earth in km
    var dLat = deg2rad(lat2-lat1);  // deg2rad below
    var dLon = deg2rad(lon2-lon1);
    var a =
        sin(dLat/2) * sin(dLat/2) +
            cos(deg2rad(lat1)) * cos(deg2rad(lat2)) *
                sin(dLon/2) * sin(dLon/2)
    ;
    var c = 2 * atan2(sqrt(a), sqrt(1-a));
    var d = R * c; // Distance in km
    return d;
  }

  double deg2rad(deg) {
    return deg * (pi/180);
  }

  Widget loadingWidget = Center(
    child: CircularProgressIndicator(),
  );

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text("Ambulances near you"),
        backgroundColor: Colors.red,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            tooltip: 'log out',
            onPressed: () {
              ConfirmLogOut(context);
            },
          ),
        ],
      ),
      body: FutureBuilder(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return loadingWidget;
            }
            return StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection("ambulance_location").snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final  messages1 = snapshot.data?.docs;
                  _markers.clear();
                  no_of_coordinates = 0;
                  _initialPosition = CameraPosition(target: LatLng(plat, plong), zoom : 15.5);
                  for ( var message in  messages1!) {

                    double distanceInKMeters = getDistanceFromLatLonInKm(plat, plong, double.parse((message.data() as  Map<String, dynamic>)!['latitude']), double.parse((message.data() as  Map<String, dynamic>)!['longitude']));
                    if(distanceInKMeters <= 0.5) {
                      _markers.add(
                        Marker(
                          //markerId: MarkerId('dubai'), double.parse(message.data()['longitude'])
                          position: LatLng(double.parse((message.data() as  Map<String, dynamic>)!['latitude']), double.parse((message.data() as  Map<String, dynamic>)!['longitude'])),
                          infoWindow: InfoWindow(title: 'Ambulance',  snippet: (message.data() as  Map<String, dynamic>)!['address']),
                          markerId: MarkerId("Ambulance"),
                        ),
                      );
                      print((message.data() as  Map<String, dynamic>)!['latitude'] + " " + (message.data() as  Map<String, dynamic>)!['longitude']);
                    }
                    print(distanceInKMeters.toString()+ " " + (message.data() as  Map<String, dynamic>)!['latitude']+ " " + (message.data() as  Map<String, dynamic>)!['longitude']);
                  }
                }
                else return (Text("No ambulances around you!"));
                return Container(
                  child: GoogleMap(
                    markers: _markers,
                    mapType: MapType.hybrid,
                    myLocationEnabled: true,
                    onMapCreated: _onMapCreated,
                    initialCameraPosition: _initialPosition,
                  ),
                );
              },
            );
          }
      ),
    );
  }

   _getCurrentLocation() async {
    Position position =  await Geolocator.getCurrentPosition();
   }
}






