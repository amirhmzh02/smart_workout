import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fyp/modules/global_import.dart';
import 'package:fyp/shared/models/meal_model.dart';
import 'package:fyp/shared/models/dairy_model.dart';


class DiaryController {
  final String apiUrl = 'http://$activeIP/get_diary.php';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<List<Map<String, dynamic>>> fetchUserDiary(DateTime month) async {
    try {
      final storage = FlutterSecureStorage();
      final userId = await storage.read(key: 'userId');
      if (userId == null) {
        debugPrint('No user ID found in secure storage');
        return [];
      }

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(
            {'user_id': userId, 'month': month.month, 'year': month.year}),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {
          return _processDiaryData(responseData['diary_entries']);
        } else {
          debugPrint('API Error: ${responseData['message']}');
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

  List<Map<String, dynamic>> _processDiaryData(List<dynamic> rawEntries) {
    final Map<String, double> dateCaloriesMap = {};

    for (var entry in rawEntries) {
      final date = entry['date'];
      final calories = double.tryParse(entry['calories'].toString()) ?? 0;

      if (dateCaloriesMap.containsKey(date)) {
        dateCaloriesMap[date] = dateCaloriesMap[date]! + calories;
      } else {
        dateCaloriesMap[date] = calories;
      }
    }

    return dateCaloriesMap.entries.map((entry) {
      final date = DateTime.parse(entry.key);
      return {
        'date': '${date.day} ${_getMonthAbbreviation(date.month)}',
        'calories': entry.value.round().toString(),
        'full_date': entry.key, // Keep original date for filtering
      };
    }).toList();
  }

  Future<List<Meal>> fetchMealsForDate({
    required String userId,
    required String date,
  }) async {
    try {

      final response = await http.post(
        Uri.parse('http://$activeIP/get_diary_details.php'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'user_id': userId,
          'date': date,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {
  final diary = Diary.fromJson(responseData);
  return diary.meals;
}
else {
          debugPrint('API Error: ${responseData['message']}');
          return [];
        }
      } else {
        debugPrint('Failed to fetch meals. Status: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      debugPrint('Exception fetching mealsssss: $e');
      return [];
    }
  }

  String _getMonthAbbreviation(int month) {
    const months = [
      'JAN',
      'FEB',
      'MAR',
      'APR',
      'MAY',
      'JUN',
      'JUL',
      'AUG',
      'SEP',
      'OCT',
      'NOV',
      'DEC'
    ];
    return months[month - 1];
  }
}
