import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:licenta/constants.dart';
import 'package:licenta/firebase/utils.dart';
import 'package:licenta/models/favourite_location.dart';
import 'package:licenta/models/place_auto_complete_response.dart';
import 'dart:async';
import 'package:licenta/repositories/favourite_location_repository.dart';

class SearchLocationScreen extends StatefulWidget {
  const SearchLocationScreen({super.key});

  @override
  SearchLocationScreenState createState() => SearchLocationScreenState();
}

class SearchLocationScreenState extends State<SearchLocationScreen> {
  List<FavouriteLocation> placePredictions = [];
  bool isLoading = false;
  Timer? _debounce;

  void _searchLocation(String query) async {
    if (query.isEmpty) {
      setState(() {
        placePredictions = [];
      });
      return;
    }
    setState(() {
      isLoading = true;
    });
    Uri uri = Uri.https(
        'maps.googleapis.com', '/maps/api/place/findplacefromtext/json', {
      'input': query,
      'inputtype': 'textquery',
      'fields': 'formatted_address,name,geometry',
      'key': googleMapsApiKey,
    });
    String? response = await fetchUrl(uri);
    if (response != null) {
      try {
        PlaceAutoCompleteResponse result =
            PlaceAutoCompleteResponse.parseAutoCompleteResponse(response);
        if (result.candidates != null) {
          setState(() {
            placePredictions = result.candidates!;
          });
        }
      } catch (e) {
        // ignore: avoid_print
        print('Failed to parse response: $e');
      }
    }
    setState(() {
      isLoading = false;
    });
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _searchLocation(query);
    });
  }

  Future<void> _showNameInputDialog(FavouriteLocation location) async {
    final TextEditingController controller = TextEditingController();
    String? customName = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter a custom name'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'e.g., Home, Work'),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () {
                Navigator.of(context).pop(controller.text);
              },
            ),
          ],
        );
      },
    );

    if (customName != null && customName.isNotEmpty) {
      final updatedLocation = FavouriteLocation(
        formattedAddress: location.formattedAddress,
        name: customName,
        location: location.location,
      );

      await FavouriteLocationRepository().addLocation(updatedLocation);

      // ignore: use_build_context_synchronously
      Navigator.pop(context, updatedLocation);
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              onChanged: _onSearchChanged,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Search Location',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    setState(() {
                      placePredictions = [];
                    });
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
          ),
          const Divider(),
          if (isLoading)
            const Padding(
              padding: EdgeInsets.all(10.0),
              child: CircularProgressIndicator(),
            )
          else if (placePredictions.isEmpty)
            const Padding(
              padding: EdgeInsets.all(10.0),
              child: Text('No results found'),
            )
          else
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: placePredictions.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading:
                        const Icon(Icons.location_on, color: kPrimaryColor),
                    title: Text(
                      placePredictions[index].formattedAddress ?? '',
                      style: GoogleFonts.workSans(),
                    ),
                    subtitle: Text(
                      placePredictions[index].name ?? '',
                      style: GoogleFonts.workSans(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    onTap: () {
                      _showNameInputDialog(placePredictions[index]);
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
