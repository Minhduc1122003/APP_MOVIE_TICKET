import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationSelectionScreen extends StatefulWidget {
  final LatLng initialPosition;

  LocationSelectionScreen({required this.initialPosition});

  @override
  _LocationSelectionScreenState createState() =>
      _LocationSelectionScreenState();
}

class _LocationSelectionScreenState extends State<LocationSelectionScreen> {
  late LatLng currentPosition;

  @override
  void initState() {
    super.initState();
    currentPosition =
        widget.initialPosition; // Initialize with the passed position
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chọn vị trí'),
        actions: [
          IconButton(
            icon: Icon(Icons.check),
            onPressed: () {
              Navigator.pop(
                  context, currentPosition); // Return the current position
            },
          ),
        ],
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: currentPosition,
          zoom: 16.5,
        ),
        onMapCreated: (GoogleMapController controller) {
          // You can add any additional map setup here
        },
        markers: {
          Marker(
            markerId: MarkerId('selectedLocation'),
            position: currentPosition,
          ),
        },
        onTap: (LatLng position) {
          setState(() {
            currentPosition = position; // Update position on map tap
          });
        },
      ),
    );
  }
}
