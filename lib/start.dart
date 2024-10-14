import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  // Pick images from gallery
  Future<void> _pickImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile>? pickedFiles = await picker.pickMultiImage();
    if (pickedFiles != null && pickedFiles.isNotEmpty) {
      setState(() {
        _imagePaths.addAll(pickedFiles.map((file) => file.path).toList());
      });
      _saveImages(); // Save to SharedPreferences
    }
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
                        // Use GridView to make a collage-like gallery layout
                        child: GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2, // Two images per row
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio:
                                0.75, // Adjust the ratio as needed
                          ),
                          itemCount: _imagePaths.length,
                          itemBuilder: (context, index) {
                            return Stack(
                              children: [
                                // Display the image in a grid tile
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.file(
                                    File(_imagePaths[index]),
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity,
                                  ),
                                ),
                                // Positioned delete icon with white background
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
