import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

Future<String?> getAuthToken() async {
  const storage = FlutterSecureStorage();
  try {
    final String? token = await storage.read(key: 'authToken');
    return token;
  } catch (e) {
    print("Error reading token from secure storage: $e");
    return null;
  }
}
