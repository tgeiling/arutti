import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:provider/provider.dart';

import 'provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (context) => UserDataProvider()), // New User Data Provider
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Salomon Bottom Bar Example',
      theme: ThemeData(
        primarySwatch: Colors.grey,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: [
          Center(child: Text("Start Page")), // Placeholder for StartPage
          Center(child: Text("Level Page")), // Placeholder for Level Page
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBottomNavigationBar() {
    return SalomonBottomBar(
      margin: const EdgeInsets.symmetric(horizontal: 30),
      backgroundColor: Colors.grey,
      currentIndex: _currentIndex,
      onTap: (i) {
        setState(() {
          _currentIndex = i;
          _pageController.animateToPage(
            i,
            duration: Duration(milliseconds: 400),
            curve: Curves.easeOut,
          );
        });
      },
      items: [
        SalomonBottomBarItem(
          icon: Icon(
            CupertinoIcons.home,
            size: MediaQuery.of(context).size.width * 0.08,
            color: Colors.white,
          ),
          title: const Text("Play"),
          selectedColor: Colors.white,
        ),
        SalomonBottomBarItem(
          icon: Icon(
            CupertinoIcons.wand_stars_inverse,
            size: MediaQuery.of(context).size.width * 0.08,
            color: Colors.white,
          ),
          title: const Text("Level"),
          selectedColor: Colors.white,
        ),
      ],
    );
  }
}
