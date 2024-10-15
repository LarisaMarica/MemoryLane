import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:licenta/constants.dart';
import 'package:licenta/models/favourite_location.dart';
import 'package:licenta/models/patient.dart';
import 'package:licenta/repositories/favourite_location_repository.dart';
import 'package:licenta/repositories/patient_repository.dart';
import 'package:licenta/widgets/app_drawer_patient.dart';
import 'package:location/location.dart';

class LocationOption {
  final String name;
  final LatLng location;

  LocationOption(this.name, this.location);
}

class MapPatientScreen extends StatefulWidget {
  const MapPatientScreen({super.key});

  @override
  MapPatientScreenState createState() => MapPatientScreenState();
}

class MapPatientScreenState extends State<MapPatientScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  late Patient patient =
      Patient(firstName: '', lastName: '', dob: DateTime.now(), gender: '');

  LocationData? currentLocation;
  List<LatLng> polylineCoordinates = [];
  bool showRoute = false;
  late StreamSubscription<LocationData> _locationSubscription;

  List<FavouriteLocation> locations = [
    FavouriteLocation(
        name: 'Location', location: const LatLng(44.4268, 26.1025))
  ];
  FavouriteLocation? selectedLocation;

  @override
  void initState() {
    super.initState();
    _fetchSavedLocations();
    _fetchPatientData();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _locationSubscription.cancel();
    super.dispose();
  }

  _fetchSavedLocations() async {
    try {
      List<FavouriteLocation> fetchedLocations =
          await FavouriteLocationRepository().getLocations();

      List<FavouriteLocation> filteredLocations = fetchedLocations
          .where((location) => location.name != "Patient Last Location")
          .toList();

      if (mounted) {
        setState(() {
          locations = filteredLocations;
          selectedLocation =
              filteredLocations.isNotEmpty ? filteredLocations[0] : null;
        });
      }
    } catch (e) {
      print("Error fetching saved locations: $e");
    }
  }

  Future<void> _fetchPatientData() async {
    try {
      final fetchedPatient = await PatientRepository().getPatient();
      if (fetchedPatient != null && mounted) {
        setState(() {
          patient = fetchedPatient;
        });
      }
    } catch (e) {
      print("Error fetching patient data: $e");
    }
  }

  Future<void> _getCurrentLocation() async {
    var location = Location();

    try {
      currentLocation = await location.getLocation();
      if (currentLocation != null && selectedLocation != null) {
        _getPolyPoints(
          LatLng(currentLocation!.latitude!, currentLocation!.longitude!),
          selectedLocation!.location,
        );
      }
    } catch (e) {
      print("Error fetching location: $e");
    }

    _locationSubscription =
        location.onLocationChanged.listen((LocationData value) {
      if (mounted) {
        setState(() {
          currentLocation = value;
        });
      }
    });
  }

  Future<void> _getPolyPoints(LatLng source, LatLng destination) async {
    polylineCoordinates.clear();
    PolylinePoints polylinePoints = PolylinePoints();

    try {
      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        googleMapsApiKey,
        PointLatLng(source.latitude, source.longitude),
        PointLatLng(destination.latitude, destination.longitude),
      );

      if (result.points.isNotEmpty && mounted) {
        setState(() {
          for (var point in result.points) {
            polylineCoordinates.add(LatLng(point.latitude, point.longitude));
          }
        });
      }
    } catch (e) {
      print("Error fetching polyline: $e");
    }
  }

  Marker _buildSelectedLocationMarker() {
    return Marker(
      markerId: const MarkerId('selectedLocation'),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      position: selectedLocation?.location ?? const LatLng(0, 0),
      infoWindow: InfoWindow(
        title: selectedLocation?.name ?? '',
      ),
    );
  }

  Future<void> _moveCameraToLocation(LatLng location) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
        target: location,
        zoom: 15.0,
      ),
    ));
  }

  void updateLocationsList(FavouriteLocation newLocation) {
    setState(() {
      locations.add(newLocation);
      selectedLocation = newLocation;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map', style: TextStyle(color: Colors.white)),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [kPrimaryColor, kSecondaryColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      drawer: const AppDrawerPatient(),
      body: currentLocation == null
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(
                    currentLocation!.latitude!, currentLocation!.longitude!),
                zoom: 12,
              ),
              myLocationButtonEnabled: true,
              myLocationEnabled: true,
              polylines: showRoute
                  ? {
                      Polyline(
                        polylineId: const PolylineId('route'),
                        color: kSecondaryColor,
                        points: polylineCoordinates,
                      ),
                    }
                  : {},
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
              markers: {
                if (selectedLocation != null) _buildSelectedLocationMarker(),
              },
            ),
      bottomNavigationBar: BottomAppBar(
        elevation: 0, 
        color: Colors.white, 
        padding: const EdgeInsets.all(0),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                    color: Colors.grey[200],
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<FavouriteLocation>(
                      value: selectedLocation,
                      onChanged: (FavouriteLocation? newValue) {
                        if (newValue != null) {
                          setState(() {
                            showRoute = false;
                            selectedLocation = newValue;
                            _moveCameraToLocation(newValue
                                .location); // Move camera to the selected location
                          });
                        }
                      },
                      icon: const Icon(
                        Icons.arrow_drop_down,
                        color: kSecondaryColor,
                      ),
                      style: GoogleFonts.workSans(
                        color: kSecondaryColor,
                        fontSize: 16.0,
                      ),
                      isExpanded: true,
                      dropdownColor: Colors.grey[200],
                      items: locations.map<DropdownMenuItem<FavouriteLocation>>(
                        (FavouriteLocation location) {
                          return DropdownMenuItem<FavouriteLocation>(
                            value: location,
                            child: Text(
                              location.name!,
                              style: GoogleFonts.workSans(
                                color: kSecondaryColor,
                                fontSize: 16.0,
                              ),
                            ),
                          );
                        },
                      ).toList(),
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.directions),
                onPressed: () {
                  if (selectedLocation != null && currentLocation != null) {
                    _getPolyPoints(
                      LatLng(currentLocation!.latitude!,
                          currentLocation!.longitude!),
                      selectedLocation!.location,
                    ).then((_) {
                      setState(() {
                        showRoute = true;
                      });
                    });
                  }
                },
                color: kSecondaryColor,
                iconSize: 40,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
