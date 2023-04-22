import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
// ignore: library_prefixes
import 'package:socket_io_client/socket_io_client.dart' as IO;

class LocationMap extends StatefulWidget {
  const LocationMap({super.key});

  @override
  State<LocationMap> createState() => _LocationMapState();
}

class _LocationMapState extends State<LocationMap> {
  late IO.Socket socket;
  late Map<MarkerId, Marker> _markers;
  final Completer<GoogleMapController> _controller = Completer();

  static const CameraPosition _cameraPosition = CameraPosition(
      target: LatLng(37.42796133580664, -122.085749655962), zoom: 15);
  @override
  void initState() {
    super.initState();
    _markers = <MarkerId, Marker>{};
    _markers.clear();
    initSocket();
  }

  Future<void> initSocket() async {
    try {
      socket = IO.io("http://10.12.23.127:3700/", <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': true,
      });
      socket.connect();
      socket.on("position-change", (data) async {
        var latLng = jsonDecode(data);
        final GoogleMapController controller = await _controller.future;
        await controller.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(latLng['lat'], latLng['lng']),
              zoom: 19,
            ),
          ),
        );

        var image = await BitmapDescriptor.fromAssetImage(
          const ImageConfiguration(),
          "assets/mark-re.png",
        );
        print("Hello______________________________");
        Marker marker = Marker(
            markerId: const MarkerId("ID"),
            icon: image,
            position: LatLng(latLng['lat'], latLng['lng']));
        setState(() {
          _markers[const MarkerId("ID")] = marker;
        });
        print("Done_____________________________");
      });
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        initialCameraPosition: _cameraPosition,
        mapType: MapType.normal,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
        markers: Set<Marker>.of(_markers.values),
      ),
    );
  }
}
