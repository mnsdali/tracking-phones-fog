import 'dart:async';
import 'dart:convert';


import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:http/http.dart' as http;



class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  late GoogleMapController mapController;

  final LatLng _center = const LatLng(45.521563, -122.677433);

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          ElevatedButton(
              onPressed: () {
                _trackme();
              },
              child: const Text("Track Me")),
          
        ],
      ),
    );
  }

  // with timer
  Future<void> _trackme() async {
    //it will call location api every 3 seconds
    Timer.periodic(const Duration(seconds: 3), (timer) async {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      print("Latitude: ${position.latitude}");
      print("Longitude: ${position.longitude}");
      // Publish the location data to the MQTT topic
      await _publishLocation(position.latitude, position.longitude);
    });
  }

  // Publish the location data to the MQTT topic
  Future<void> _publishLocation(double latitude, double longitude) async {
    var headers = {'Content-Type': 'application/json'};
    var request =
        http.Request('POST', Uri.parse('http://127.0.0.1:5000/postion'));
    request.body = json.encode({
      'latitude': latitude.toString(),
      'longitude': longitude.toString(),
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
    } else {
      print(response.reasonPhrase);
    }
  }
}







// //without timer
  // Future<void> _getLocation() async {
  //   Position position = await Geolocator.getCurrentPosition(
  //       desiredAccuracy: LocationAccuracy.high);

  //   print("Latitude: ${position.latitude}");
  //   print("Longitude: ${position.longitude}");
  // }