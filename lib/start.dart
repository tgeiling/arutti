import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class StartPage extends StatefulWidget {
  @override
  _StartPageState createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  final List<String> layouts = [
    'assets/layouts/1.png',
    'assets/layouts/2.png',
    'assets/layouts/3.png',
  ];
  int _selectedLayoutIndex = -1; // No layout selected by default
  List<String> _slotImages = []; // Tracks images for the slots

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Setcard erstellen")),
      body: Center(
        child: Column(
          children: [
            // Main View with Layout Preview and Slots
            Expanded(
              child: _selectedLayoutIndex == -1
                  ? Center(
                      child: ElevatedButton(
                        onPressed: () => _showLayoutSelectionDialog(context),
                        child: const Text("Setcard erstellen"),
                      ),
                    )
                  : Column(
                      children: [
                        // Display Selected Layout
                        Expanded(
                          child: Stack(
                            children: [
                              Image.asset(
                                layouts[_selectedLayoutIndex],
                                fit: BoxFit.contain,
                                width: double.infinity,
                              ),
                              // Overlay slots dynamically
                              _buildSlotOverlay(),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () => _saveSetcard(),
                          child: const Text("Save Setcard"),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // Dialog for Selecting a Layout
  Future<void> _showLayoutSelectionDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: SizedBox(
            height: 300,
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    "Select a Layout",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: layouts.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedLayoutIndex = index;
                            _initializeSlots();
                          });
                          Navigator.pop(context);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Image.asset(layouts[index]),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Initialize Slot Images for Selected Layout
  void _initializeSlots() {
    final slotCounts = [3, 5, 8]; // Number of slots per layout
    _slotImages = List.generate(slotCounts[_selectedLayoutIndex], (_) => "");
  }

  // Build Slot Overlay for the Layout
  Widget _buildSlotOverlay() {
    final slotCounts = [3, 5, 8]; // Number of slots per layout
    final slotPositions = [
      // Positions for slots (percentages of the layout image)
      [
        Offset(0.2, 0.3),
        Offset(0.5, 0.3),
        Offset(0.8, 0.3),
      ],
      [
        Offset(0.2, 0.2),
        Offset(0.5, 0.2),
        Offset(0.8, 0.2),
        Offset(0.35, 0.6),
        Offset(0.65, 0.6),
      ],
      [
        Offset(0.1, 0.1),
        Offset(0.4, 0.1),
        Offset(0.7, 0.1),
        Offset(0.2, 0.4),
        Offset(0.5, 0.4),
        Offset(0.8, 0.4),
        Offset(0.35, 0.7),
        Offset(0.65, 0.7),
      ],
    ];

    final positions = slotPositions[_selectedLayoutIndex];
    return Stack(
      children: positions.asMap().entries.map((entry) {
        final index = entry.key;
        final position = entry.value;
        final slotImage = _slotImages[index];
        return Positioned(
          left: position.dx * MediaQuery.of(context).size.width,
          top: position.dy * MediaQuery.of(context).size.height,
          child: GestureDetector(
            onTap: () => _addImageToSlot(index),
            child: Stack(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.white,
                  ),
                  child: slotImage.isEmpty
                      ? const Icon(Icons.add_photo_alternate, size: 40)
                      : Image.file(
                          File(slotImage),
                          fit: BoxFit.cover,
                        ),
                ),
                if (slotImage.isNotEmpty)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () => _removeImageFromSlot(index),
                      child: const Icon(Icons.cancel, color: Colors.red),
                    ),
                  ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // Add Image to Slot
  Future<void> _addImageToSlot(int index) async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _slotImages[index] = pickedFile.path;
      });
    }
  }

  // Remove Image from Slot
  void _removeImageFromSlot(int index) {
    setState(() {
      _slotImages[index] = "";
    });
  }

  // Save Setcard (Placeholder for backend integration)
  void _saveSetcard() {
    print("Saving Setcard with Layout: $_selectedLayoutIndex");
    print("Slot Images: $_slotImages");
  }
}
