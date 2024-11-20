import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ModelPage extends StatefulWidget {
  @override
  _ModelPageState createState() => _ModelPageState();
}

class _ModelPageState extends State<ModelPage> {
  List<Map<String, dynamic>> models = [];

  @override
  void initState() {
    super.initState();
    _fetchSetcards();
  }

  Future<void> _fetchSetcards() async {
    const String url =
        'http://35.204.22.68:3000/api/setcards'; // Your server URL

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          models = data.map<Map<String, dynamic>>((model) => model).toList();
        });
      } else {
        print("Failed to load setcards: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching setcards: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Models'),
      ),
      body: models.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: models.length,
              itemBuilder: (context, index) {
                final model = models[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 16.0),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 5,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${model['name'] ?? 'Unknown Name'}",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Age: ${model['age'] ?? 'N/A'}, Height: ${model['height'] ?? 'N/A'}",
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Measurements: Chest: ${model['measurements']['chest'] ?? '0'}, "
                            "Waist: ${model['measurements']['waist'] ?? '0'}, "
                            "Hips: ${model['measurements']['hips'] ?? '0'}",
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            height: 100, // Height of the gallery row
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: model['photos'].length,
                              itemBuilder: (context, photoIndex) {
                                final base64Image = model['photos'][photoIndex];
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8.0),
                                    child: base64Image != null
                                        ? Image.memory(
                                            base64Decode(
                                                base64Image.split(',')[1]),
                                            height: 100,
                                            width: 100,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error,
                                                    stackTrace) =>
                                                const Icon(Icons.broken_image,
                                                    size: 100),
                                          )
                                        : const Icon(Icons.broken_image,
                                            size: 100),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
