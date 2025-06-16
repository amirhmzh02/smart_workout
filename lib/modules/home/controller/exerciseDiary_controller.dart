import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:fyp/modules/global_import.dart';

class ExerciseDiaryController {
  final String apiUrl = 'http://$activeIP/fetch_workout_diary.php';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<List<Map<String, dynamic>>> fetchUserDiary(DateTime month) async {
    try {
      final userId = await _storage.read(key: 'userId') ??
          '10'; // fallback ID for dev only
      if (userId == null) {
        debugPrint('User ID is null');
        return [];
      }

      final formattedMonth =
          "${month.year}-${month.month.toString().padLeft(2, '0')}";

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"user_id": userId, "month": formattedMonth}),
      );
      

      if (response.statusCode == 200) {
  print('this is the response body: ${response.body}');
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true &&
            responseData['diary_entries'] != null) {
          return _processDiaryData(responseData['diary_entries']);
        } else {
          debugPrint(
              'API Error or no data: ${responseData['message'] ?? 'No diary entries'}');
          return [];
        }
      } else {
        debugPrint('Failed to fetch diary. Status: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      debugPrint('Error fetching diary: $e');
      return [];
    }
  }

  List<Map<String, dynamic>> _processDiaryData(List<dynamic> entries) {
  return entries.map<Map<String, dynamic>>((entry) {
    return {
      'date': entry['date'], // Fix this!
      'full_date': entry['full_date'],
      'calories': entry['calories'],
    };
  }).toList();
}

}
