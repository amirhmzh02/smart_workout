import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fyp/modules/global_import.dart';

class UserController {
  static const _storage = FlutterSecureStorage();
  static const _apiUrl = 'http://$activeIP/get_user.php';

Future<Map<String, dynamic>?> fetchAndStoreUserData() async {
  print("Fetching user data...");
  final userId = await _storage.read(key: 'userId');
  if (userId == null) return null;

  try {
    final response = await http.post(
      Uri.parse(_apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'user_id': userId}),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['success']) {
      Map<String, dynamic> user = data['user'];

      // Save data in secure storage
      print("Storing name: ${user['name']}");

      await _storage.write(key: 'name', value: user['name']);
      await _storage.write(key: 'age', value: user['age'].toString());
      await _storage.write(key: 'weight', value: user['weight'].toString());
      await _storage.write(key: 'height', value: user['height'].toString());
      await _storage.write(key: 'gender', value: user['gender']);
      await _storage.write(key: 'fitness_goal', value: user['fitness_goal']);
      await _storage.write(key: 'email', value: user['email']);

      // Check if the name is stored correctly
      final storedName = await _storage.read(key: 'name');
      print("Stored name in secure storage: $storedName");

      return user;
    } else {
      print("User fetch failed: ${data['message']}");
      return null;
    }
  } catch (e) {
    print("Error fetching user data: $e");
    return null;
  }
}

  static Future<String?> getUsername() async {
    return await _storage.read(key: 'name');
  }

  static Future<void> clearUserData() async {
    await _storage.deleteAll();
  }

  static Future<int> FirstTimeUser() async {
  final age = await _storage.read(key: 'age');
  final weight = await _storage.read(key: 'weight');
  final height = await _storage.read(key: 'height');
  final gender = await _storage.read(key: 'gender');
  final fitnessGoal = await _storage.read(key: 'fitness_goal');

  if (age == null || weight == null || height == null || gender == null || fitnessGoal == null) {
    return 1; // First time user (data not filled in)
  }

  return 0; // Returning user (data exists)
}

}
