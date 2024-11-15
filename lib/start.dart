import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

import 'provider.dart';

class StartPage extends StatefulWidget {
  @override
  _StartPageState createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  List<String> _imagePaths = [];

  @override
  void initState() {
    super.initState();
    _loadImages();
  }

  // Load saved image paths from SharedPreferences
  Future<void> _loadImages() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? savedImages = prefs.getStringList('images');
    if (savedImages != null) {
      setState(() {
        _imagePaths = savedImages;
      });
    }
  }

  // Save image paths to SharedPreferences
  Future<void> _saveImages() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('images', _imagePaths);
  }

  // Pick images from gallery and upload immediately
  Future<void> _pickImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile>? pickedFiles = await picker.pickMultiImage();
    if (pickedFiles != null && pickedFiles.isNotEmpty) {
      setState(() {
        _imagePaths.addAll(pickedFiles.map((file) => file.path).toList());
      });
      _saveImages(); // Save to SharedPreferences

      // Automatically upload images after selection
      await _saveModelSetcard(context);
    }
  }

  final storage = FlutterSecureStorage();

  Future<void> _saveModelSetcard(BuildContext context) async {
    const String serverUrl = 'http://35.204.22.68:3000/api/setcards';

    // Access the UserDataProvider to retrieve questionnaire data
    final userDataProvider =
        Provider.of<UserDataProvider>(context, listen: false);

    try {
      // Retrieve the token from secure storage
      final token = await storage.read(key: 'authToken');
      if (token == null) {
        print("No token found. Please authenticate first.");
        return;
      }

      // Prepare the multipart request
      final request = http.MultipartRequest('POST', Uri.parse(serverUrl))
        ..headers['Authorization'] = 'Bearer $token';

      // Add text fields to the request
      request.fields['name'] =
          userDataProvider.firstName + " " + userDataProvider.surname;
      request.fields['telephone'] = userDataProvider.telephone;
      request.fields['email'] = userDataProvider.email;

      // Add measurement fields, sending 0 if any field is missing or invalid
      request.fields['chest'] = (userDataProvider.chest > 0)
          ? userDataProvider.chest.toString()
          : '0';
      request.fields['waist'] = (userDataProvider.waist > 0)
          ? userDataProvider.waist.toString()
          : '0';
      request.fields['hips'] =
          (userDataProvider.hips > 0) ? userDataProvider.hips.toString() : '0';

      // Attach each image file
      for (String imagePath in _imagePaths) {
        request.files
            .add(await http.MultipartFile.fromPath('photos', imagePath));
      }

      // Send the request
      final response = await request.send();

      // Check the response status
      if (response.statusCode == 201) {
        print("Setcard saved successfully.");
      } else {
        print("Failed to save setcard: ${response.statusCode}");
        print(await response.stream.bytesToString());
      }
    } catch (e) {
      print("Error saving setcard: $e");
    }
  }

// Utility function to calculate age based on birth date
  int _calculateAge(DateTime? birthDate) {
    if (birthDate == null) return 0;
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  // Delete image from the list
  void _deleteImage(int index) {
    setState(() {
      _imagePaths.removeAt(index);
    });
    _saveImages();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          if (_imagePaths.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Align(
                alignment: Alignment.topRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Deine Setcard ist hochgeladen \n bearbeite sie nach belieben",
                      style: TextStyle(fontSize: 12),
                    ),
                    SizedBox(width: 10),
                    GestureDetector(
                      onTap: _pickImages,
                      child: Icon(Icons.add, size: 50),
                    ),
                  ],
                ),
              ),
            ),
          Expanded(
            child: _imagePaths.isEmpty
                ? Center(
                    child: GestureDetector(
                      onTap: _pickImages,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add, size: 100),
                          SizedBox(height: 20),
                          Text("Erstelle deine Setcard",
                              style: TextStyle(fontSize: 18)),
                        ],
                      ),
                    ),
                  )
                : Column(
                    children: [
                      SizedBox(height: 10),
                      Expanded(
                        child: GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 0.75,
                          ),
                          itemCount: _imagePaths.length,
                          itemBuilder: (context, index) {
                            return Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.file(
                                    File(_imagePaths[index]),
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity,
                                  ),
                                ),
                                Positioned(
                                  bottom: 10,
                                  right: 10,
                                  child: GestureDetector(
                                    onTap: () => _deleteImage(index),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.8),
                                        shape: BoxShape.rectangle,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      padding: EdgeInsets.all(8),
                                      child: Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
