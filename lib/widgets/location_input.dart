import 'dart:convert';
import 'package:favorite_place/models/place.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;

class LoocationInput extends StatefulWidget {
  const LoocationInput({super.key, required this.onSelectedLocation});
  final void Function(PlaceLocation location) onSelectedLocation;

  @override
  State<LoocationInput> createState() => _LoocationInputState();
}

class _LoocationInputState extends State<LoocationInput> {
  PlaceLocation? _pickedLocatoin;

  String get locationImage {
    if (_pickedLocatoin == null) {
      return '';
    }
    final lat = _pickedLocatoin!.latitude;
    final lng = _pickedLocatoin!.longitude;
    return 'https://maps.googleapis.com/maps/api/staticmap?center=$lat,$lng&zoom=13&size=600x300&maptype=roadmap&markers=color:red%7Clabel:A%7C$lat,$lng&key=AIzaSyDx4Bn4yXMCTCuC3ttyF7_ZcSuuwwZzU0E';
  }

  var _isGettingLocation = false;
  Future<void> _savePlace(double lattitude, double longotude) async {
    final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$lattitude,$longotude&key=AIzaSyDx4Bn4yXMCTCuC3ttyF7_ZcSuuwwZzU0E');
    final response = await http.get(url);
    final resData = json.decode(response.body);
    final addres = resData['results'][0]['formatted_address'];

    setState(() {
      _pickedLocatoin = PlaceLocation(
        address: addres,
        latitude: lattitude,
        longitude: longotude,
      );
      _isGettingLocation = false;
    });
    widget.onSelectedLocation(_pickedLocatoin!);
  }

  void _getCurrentLocation() async {
    Location location = Location();

    bool serviceEnabled;
    PermissionStatus permissionGranted;
    LocationData locationData;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
    setState(() {
      _isGettingLocation = true;
    });

    locationData = await location.getLocation();
    // print(locationData.latitude);
    // print(locationData.longitude);

    final lat = locationData.latitude;
    final lng = locationData.longitude;

    if (lat == null || lng == null) {
      return;
    }
    _savePlace(lat, lng);
  }



  @override
  Widget build(BuildContext context) {
    Widget privieContent = Text(
      'No location chosen',
      textAlign: TextAlign.center,
      style: Theme.of(context)
          .textTheme
          .bodyLarge!
          .copyWith(color: Theme.of(context).colorScheme.onBackground),
    );
    if (_pickedLocatoin != null) {
      privieContent = Image.network(
        locationImage,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    }

    if (_isGettingLocation) {
      privieContent = const CircularProgressIndicator();
    }
    return Column(
      children: [
        Container(
            decoration: BoxDecoration(
              border: Border.all(
                width: 1,
                color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
              ),
            ),
            height: 170,
            alignment: Alignment.center,
            width: double.infinity,
            child: privieContent),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton.icon(
              onPressed: _getCurrentLocation,
              icon: const Icon(Icons.location_on),
              label: const Text('Get Current Location'),
            ),
   
          ],
        )
      ],
    );
  }
}
