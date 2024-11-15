import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:provider/provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'provider.dart';
import 'start.dart';
import 'events.dart';
import 'auth.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => UserDataProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Arutti App',
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

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  // Connectivity and Authentication State
  bool? _authenticated;
  bool? _loggedIn;
  bool _isConnected = true;
  bool _isLoading = true;

  final AuthService _authService = AuthService();
  late Connectivity _connectivity;
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    _checkAuthentication();
    WidgetsBinding.instance.addObserver(this);

    // Initialize connectivity
    _connectivity = Connectivity();
    _connectivitySubscription = _connectivity.onConnectivityChanged
        .listen((List<ConnectivityResult> result) {
      _updateConnectionStatus(result);
    });
    _checkInitialConnectivity();
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Connectivity and Authentication Functions
  void _updateConnectionStatus(List<ConnectivityResult> results) {
    setState(() {
      _isConnected = !results.contains(ConnectivityResult.none);
    });
  }

  Future<void> _checkInitialConnectivity() async {
    List<ConnectivityResult> results = await _connectivity.checkConnectivity();
    _updateConnectionStatus(results);
  }

  Future<void> _checkAuthentication() async {
    setState(() {
      _isLoading = true;
    });

    bool isGuest = await _authService.isGuestToken();
    bool tokenExpired = await _authService.isTokenExpired();

    if (!isGuest) {
      setState(() {
        _setAuthenticated(true);
        print("User is logged in.");
      });

      if (tokenExpired) {
        setState(() {
          _setAuthenticated(false);
          print("Token expired.");
        });
      }
    } else {
      await _authService.setGuestToken();
      setState(() {
        _setAuthenticated(false);
        print("Guest token set.");
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _setAuthenticated(bool authenticated) {
    setState(() => _authenticated = authenticated);
    _setLoggedIn(authenticated);
  }

  void _setLoggedIn(bool loggedIn) {
    setState(() {
      _loggedIn = loggedIn;
      print("Logged in state updated: $loggedIn");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/logo.jpg',
              height: 40, // Adjust the height based on your logo size
            ),
          ],
        ),
        backgroundColor: Colors.white,
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: [
          Center(child: StartPage()),
          Center(child: EventsPage()),
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
            CupertinoIcons.camera,
            size: MediaQuery.of(context).size.width * 0.08,
            color: Colors.white,
          ),
          title: const Text("Setcard"),
          selectedColor: Colors.white,
        ),
        SalomonBottomBarItem(
          icon: Icon(
            CupertinoIcons.calendar_today,
            size: MediaQuery.of(context).size.width * 0.08,
            color: Colors.white,
          ),
          title: const Text("Events"),
          selectedColor: Colors.white,
        ),
      ],
    );
  }
}
