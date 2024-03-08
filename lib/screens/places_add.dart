import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:favorite_place/models/place.dart';
import 'package:favorite_place/providers/user_places.dart';
import 'package:favorite_place/widgets/image_input.dart';
import 'package:favorite_place/widgets/location_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddPlaceScreen extends ConsumerStatefulWidget {
  const AddPlaceScreen({super.key});

  @override
  ConsumerState<AddPlaceScreen> createState() => _AddPlaceScreenState();
}

class _AddPlaceScreenState extends ConsumerState<AddPlaceScreen> {
  final _titleController = TextEditingController();
  File? _slectedImage;
  PlaceLocation? _selectLocations;
  @override
  void dispose() {
    _titleController;
    super.dispose();
  }

  void _savePlace() async {
    final enteredTitle = _titleController.text;
    if (enteredTitle.isEmpty ||
        _slectedImage == null ||
        _selectLocations == null) {
      return;
    }

    ref
        .read(userPlacesProvider.notifier)
        .addPlace(enteredTitle, _slectedImage!, _selectLocations!);
    final url = Uri.https(
        'favorite-place-ad6e9-default-rtdb.firebaseio.com', 'add-place.json');
    List<int> imageBytes = await _slectedImage!.readAsBytes();
    String base64Image = base64Encode(imageBytes);
    http.post(url,
        headers: {
          'Content-Type': 'aplication/json',
        },
        body: json.encode({
          'descr': enteredTitle,
          'image': base64Image,
          'latitude': _selectLocations!.latitude,
          'longitude':_selectLocations!.longitude
        }));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add new Place'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'Title'),
              controller: _titleController,
              style:
                  TextStyle(color: Theme.of(context).colorScheme.onBackground),
            ),
            const SizedBox(
              height: 10,
            ),
            ImageInput(
              onPickImage: ((image) {
                _slectedImage = image;
              }),
            ),
            const SizedBox(
              height: 10,
            ),
            LoocationInput(
              onSelectedLocation: (location) {
                _selectLocations = location;
              },
            ),
            const SizedBox(
              height: 16,
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              onPressed: _savePlace,
              label: const Text('Add Place'),
            )
          ],
        ),
      ),
    );
  }
}
