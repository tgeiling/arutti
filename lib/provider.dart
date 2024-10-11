import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserDataProvider with ChangeNotifier {
  String _firstName = "";
  String _surname = "";
  String _telephone = "";
  String _email = "";

  // Getters
  String get firstName => _firstName;
  String get surname => _surname;
  String get telephone => _telephone;
  String get email => _email;

  UserDataProvider() {
    loadPreferences();
  }

  // Setters with notifyListeners and save to SharedPreferences
  void setFirstName(String firstName) {
    _firstName = firstName;
    notifyListeners();
    savePreferences();
  }

  void setSurname(String surname) {
    _surname = surname;
    notifyListeners();
    savePreferences();
  }

  void setTelephone(String telephone) {
    _telephone = telephone;
    notifyListeners();
    savePreferences();
  }

  void setEmail(String email) {
    _email = email;
    notifyListeners();
    savePreferences();
  }

  // Load data from SharedPreferences
  Future<void> loadPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _firstName = prefs.getString('firstName') ?? "";
    _surname = prefs.getString('surname') ?? "";
    _telephone = prefs.getString('telephone') ?? "";
    _email = prefs.getString('email') ?? "";
    notifyListeners();
  }

  // Save data to SharedPreferences
  Future<void> savePreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('firstName', _firstName);
    await prefs.setString('surname', _surname);
    await prefs.setString('telephone', _telephone);
    await prefs.setString('email', _email);
  }
}
