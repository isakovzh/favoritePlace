import 'package:uuid/uuid.dart';
import 'dart:io';

class PlaceLocation {
  const PlaceLocation(
      {required this.address, required this.latitude, required this.longitude});

  final double latitude;
  final double longitude;
  final String address;

  get toJson => null;
}

const uuid = Uuid();

class Place {
  Place({
    required this.title,
    required this.image,
  required this.location
  }) : id = uuid.v4();

  final String id;
  final String title;
  final File image;
  final PlaceLocation location;
}
