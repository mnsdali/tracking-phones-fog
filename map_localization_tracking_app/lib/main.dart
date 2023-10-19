import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

// ignore: use_key_in_widget_constructors
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyMapPage(),
    );
  }
}

// ignore: use_key_in_widget_constructors
class MyMapPage extends StatefulWidget {
  @override
  // ignore: library_private_types_in_public_api
  _MyMapPageState createState() => _MyMapPageState();
}

class _MyMapPageState extends State<MyMapPage> {
  late GoogleMapController mapController;
  final LatLng _center = const LatLng(34.7282712, 10.7155989);
  List<Marker> markers = [];
  String srvUrl = '';
  late Timer markerRemovalTimer;

  @override
  void initState() {
    super.initState();

    // Create a timer to remove markers every 60 seconds
    markerRemovalTimer = Timer.periodic(const Duration(seconds: 60), (timer) {
      removeMarkers();
    });

    _trackMe();
  }

  void removeMarkers() {
    setState(() {
      markers.clear();
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  double randomHue() {
    final random = Random();
    return random.nextDouble() * 360.0;
  }

  Future<String> _getIPAddress() async {
    final response = await http.get(Uri.parse('https://api.ipify.org?format=json'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['ip'];
    } else {
      return 'Unknown';
    }
  }

  Future<void> _publishLocation(double latitude, double longitude, String ipAddress) async {
    try {
      final payload = {
        'id': '$latitude$longitude',
        'content': {'latitude': latitude, 'longitude': longitude}
      };
      String message = json.encode(payload);

      final response = await http.post(
        Uri.parse(srvUrl),
        headers: {'Content-Type': 'application/json'},
        body: message,
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        for (var item in responseData) {
          var id = item['id'];
          var lat = item['content']['latitude'];
          var long = item['content']['longitude'];

          setState(() {
            markers.add(Marker(
              markerId: MarkerId(id),
              position: LatLng(lat, long),
              infoWindow: InfoWindow(
                title: '$lat$long',
                snippet: 'Lat: $lat, Lng: $long',
              ),
              icon: BitmapDescriptor.defaultMarkerWithHue(randomHue()),
            ));
          });
        }
      } else {
        // ignore: avoid_print
        print('Failed to send request. Status code: ${response.statusCode}');
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error sending request: $e');
    }
  }

  Future<void> _trackMe() async {
    final String ipAddress = await _getIPAddress();
    srvUrl = 'http://10.25.14.172:5000/position';

    Timer.periodic(const Duration(seconds: 5), (timer) async {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      // ignore: avoid_print
      print("Latitude: ${position.latitude}");
      // ignore: avoid_print
      print("Longitude: ${position.longitude}");
      await _publishLocation(position.latitude, position.longitude, ipAddress);
    });
  }

  @override
  void dispose() {
    super.dispose();
    markerRemovalTimer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      ),
    );
  }
}
