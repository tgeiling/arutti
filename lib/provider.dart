import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserDataProvider with ChangeNotifier {
  String _firstName = "";
  String _surname = "";
  String _telephone = "";
  String _email = "";
  int _age = 0;
  int _height = 0;
  int _chest = 0;
  int _waist = 0;
  int _hips = 0;

  // Getters
  String get firstName => _firstName;
  String get surname => _surname;
  String get telephone => _telephone;
  String get email => _email;
  int get age => _age;
  int get height => _height;
  int get chest => _chest;
  int get waist => _waist;
  int get hips => _hips;

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

  void setAge(int age) {
    _age = age;
    notifyListeners();
    savePreferences();
  }

  void setHeight(int height) {
    _height = height;
    notifyListeners();
    savePreferences();
  }

  void setChest(int chest) {
    _chest = chest;
    notifyListeners();
    savePreferences();
  }

  void setWaist(int waist) {
    _waist = waist;
    notifyListeners();
    savePreferences();
  }

  void setHips(int hips) {
    _hips = hips;
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
    _age = prefs.getInt('age') ?? 0;
    _height = prefs.getInt('height') ?? 0;
    _chest = prefs.getInt('chest') ?? 0;
    _waist = prefs.getInt('waist') ?? 0;
    _hips = prefs.getInt('hips') ?? 0;
    notifyListeners();
  }

  // Save data to SharedPreferences
  Future<void> savePreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('firstName', _firstName);
    await prefs.setString('surname', _surname);
    await prefs.setString('telephone', _telephone);
    await prefs.setString('email', _email);
    await prefs.setInt('age', _age);
    await prefs.setInt('height', _height);
    await prefs.setInt('chest', _chest);
    await prefs.setInt('waist', _waist);
    await prefs.setInt('hips', _hips);
  }
}
