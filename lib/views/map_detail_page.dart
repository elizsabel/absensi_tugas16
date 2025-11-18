import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapDetailPage extends StatefulWidget {
  final double lat;
  final double lng;

  const MapDetailPage({super.key, required this.lat, required this.lng});

  @override
  State<MapDetailPage> createState() => _MapDetailPageState();
}

class _MapDetailPageState extends State<MapDetailPage> {
  GoogleMapController? mapController;

  @override
  Widget build(BuildContext context) {
    final LatLng currentPos = LatLng(widget.lat, widget.lng);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber.shade600,
        title: const Text("Lokasi Anda"),
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(target: currentPos, zoom: 16),
        markers: {
          Marker(
            markerId: const MarkerId("currentLocation"),
            position: currentPos,
            infoWindow: const InfoWindow(title: "Lokasi Anda Sekarang"),
          ),
        },
        onMapCreated: (controller) => mapController = controller,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
      ),
    );
  }
}
