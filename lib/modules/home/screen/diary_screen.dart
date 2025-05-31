import 'package:flutter/material.dart';
import 'package:fyp/modules/global_import.dart';
import 'package:fyp/modules/home/controller/diary_controller.dart';
import 'package:fyp/modules/home/screen/diaryDetail_screen.dart';

class DiaryScreen extends StatefulWidget {
  const DiaryScreen({super.key});

  @override
  State<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen> {
  final DiaryController _diaryController = DiaryController();
  List<Map<String, dynamic>> diaryEntries = [];
  bool isLoading = true;
  DateTime _currentMonth = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
    });
    final entries = await _diaryController.fetchUserDiary(_currentMonth);
    setState(() {
      diaryEntries = entries;
      isLoading = false;
    });
  }

  void _changeMonth(int delta) {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + delta);
      _loadData(); // Reload data when month changes
    });
  }

  String _getMonthName(DateTime date) {
    const monthNames = [
      'JANUARY',
      'FEBRUARY',
      'MARCH',
      'APRIL',
      'MAY',
      'JUNE',
      'JULY',
      'AUGUST',
      'SEPTEMBER',
      'OCTOBER',
      'NOVEMBER',
      'DECEMBER'
    ];
    return monthNames[date.month - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row with "YOUR DIARY" and logo
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: AppColors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Text(
                    'YOUR DIARY',
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: AppFonts.primary,
                    ),
                  ),
                  const SizedBox(
                      width: 48), // This balances the space on the right
                ],
              ),

              const SizedBox(height: 20),

              // Month selector
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Left arrow
                  IconButton(
                    icon: Icon(Icons.chevron_left, color: AppColors.white),
                    onPressed: () => _changeMonth(-1),
                  ),

                  // Month name
                  Text(
                    _getMonthName(_currentMonth),
                    style: TextStyle(
                      color: AppColors.white,
                      fontFamily: AppFonts.primary,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  // Right arrow
                  IconButton(
                    icon: Icon(Icons.chevron_right, color: AppColors.white),
                    onPressed: () => _changeMonth(1),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // Diary entries
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : diaryEntries.isEmpty
                        ? const Center(
                            child: Text(
                              'No diary entries found',
                              style: TextStyle(
                                color: AppColors.lightbackground,
                                fontSize: 18,
                              ),
                            ),
                          )
                        : ListView.builder(
                            itemCount: diaryEntries.length,
                            itemBuilder: (context, index) {
                              final entry = diaryEntries[index];
                              return Column(
                                children: [
                                  _buildDateEntry(entry),
                                  if (index < diaryEntries.length - 1)
                                    const SizedBox(height: 20),
                                ],
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateEntry(Map<String, dynamic> entry) {
    final date = entry['date']; // "31 MAY"
    final calories = entry['calories'];
    final fullDate = entry['full_date']; // "2025-05-30"

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DiaryDetailScreen(selectedDate: fullDate, date: date,),
          ),
        );
      },
      child: Container(
        // your UI code here, using date and calories as before
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        decoration: BoxDecoration(
          color: AppColors.lightbackground,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              date,
              style: const TextStyle(
                fontSize: 20,
                fontFamily: AppFonts.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '$calories ',
                    style: const TextStyle(
                      fontSize: 20,
                      fontFamily: AppFonts.primary,
                      fontWeight: FontWeight.bold,
                      color: AppColors.white,
                    ),
                  ),
                  TextSpan(
                    text: 'KCAL',
                    style: const TextStyle(
                      fontSize: 20,
                      fontFamily: AppFonts.primary,
                      fontWeight: FontWeight.normal,
                      color: AppColors.pink,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
