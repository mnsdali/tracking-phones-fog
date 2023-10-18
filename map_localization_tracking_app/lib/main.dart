import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/services.dart';
// import 'package:wifi_info_flutter/wifi_info_flutter.dart';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late GoogleMapController mapController;

  final LatLng _center = const LatLng(34.7282712, 10.7155989);
  List<Marker> markers = [];
  String srvUrl = "";
  @override
  void initState() {
    super.initState();

    _trackme();
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: const Text('Maps Localization Tracking For Phones'),
            backgroundColor: Colors.green[700],
          ),
          body: GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: _center,
              zoom: 17.0,
            ),
            markers: Set<Marker>.from(markers),
          )),
    );
  }

  Future<String> _getIPAddress() async {
    final response =
        await http.get(Uri.parse('https://api.ipify.org?format=json'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['ip'];
    } else {
      return 'Unknown';
    }
  }

  Future<String> getWifiIP() async {
    final connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.wifi) {
      try {
        final result = await const MethodChannel("wifi_info_flutter")
            .invokeMethod("wifiIPAddress");
        return result ?? 'IP address not found';
      } on PlatformException catch (e) {
        return 'Error: ${e.message}';
      }
    } else {
      return 'Not connected to WiFi';
    }
  }

// Publish the location data to the MQTT topic
  Future<void> _publishLocation(
      double latitude, double longitude, String ipAdress) async {
    try {
      print(ipAdress);
      // Create a JSON payload with latitude and longitude
      final payload = {
        'id': "$latitude$longitude",
        'content': {'latitude': latitude, 'longitude': longitude}
      };
      String message = json.encode(payload);

      final response = await http.post(
        Uri.parse(srvUrl),
        headers: {'Content-Type': 'application/json'},
        body: message,
      );

      if (response.statusCode == 200) {
        print(json.decode(response.body).runtimeType);
        List<dynamic> responseData = json.decode(response.body);
        // Now you can iterate through the list and access each map as needed

        for (var item in responseData) {
          var id = item['id'];
          var lat = item['content']['latitude'];
          var long = item['content']['longitude'];
          var timeStamp = item['timestamp'];
          // final markerId = MarkerId(ipAddress);
          setState(() {
            markers.add(Marker(
              markerId: MarkerId(id),
              position: LatLng(lat, long),
              infoWindow: InfoWindow(
                title: '$lat$long',
                snippet: 'Lat: $lat, Lng: $long',
              ),
            ));
          });
        }
      } else {
        print('Failed to send request. Status code: ${response.statusCode}');
        srvUrl = await getUrl();
      }
    } catch (e) {
      print('Error sending request: $e');
    }
  }

  // [ {'ipAdress' : '1.1.1.1', 'content' : {'latitude': '3.1111', 'longitude': '4.2222'}}
// with timer
  Future<String> getUrl() async {
    final Random random = Random();
    final List<String> servers = [
      'http://192.168.112.151:5000/position',
      'http://192.168.112.104:5000/position',
    ];

    // Choose a random URL
    final String randomUrl = servers[random.nextInt(servers.length)];
    return randomUrl;
  }

  Future<void> _trackme() async {
    final String ipAddress = await _getIPAddress();
    srvUrl = await getUrl();
    //it will call location api every 3 seconds
    Timer.periodic(const Duration(seconds: 5), (timer) async {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      // await _addMarker(LatLng(position.latitude, position.longitude));
      print("Latitude: ${position.latitude}");
      print("Longitude: ${position.longitude}");
      // Publish the location data to the MQTT topic
      await _publishLocation(position.latitude, position.longitude, ipAddress);
    });
  }
}
