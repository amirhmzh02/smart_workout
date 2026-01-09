import 'package:flutter/material.dart';
import 'package:fyp/modules/global_import.dart';

class DaySelector extends StatefulWidget {
  final DateTime startDate;
  final ValueChanged<DateTime> onDateSelected;
  final DateTime? initialDate;

  const DaySelector({
    super.key,
    required this.startDate,
    required this.onDateSelected,
    this.initialDate,
  });

  @override
  State<DaySelector> createState() => _DaySelectorState();
}

class _DaySelectorState extends State<DaySelector> {
  late DateTime _selectedDate;
  late List<DateTime> _weekDates;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate ?? widget.startDate;
    _generateWeekDates();
  }

  void _generateWeekDates() {
    _weekDates = List.generate(
        5, (index) => widget.startDate.add(Duration(days: index)));
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      // Wrap the entire content in Center
      child: Container(
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.9),
        height: 70,
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: ListView.separated(
          shrinkWrap: true,
          physics: const ClampingScrollPhysics(),
          scrollDirection: Axis.horizontal,
          itemCount: _weekDates.length,
          separatorBuilder: (context, index) => const SizedBox(width: 12),
          itemBuilder: (context, index) {
            final date = _weekDates[index];
            final isSelected = _selectedDate.day == date.day;
            final dayName = _getAbbreviatedDayName(date.weekday);
            final dateNumber = date.day;

            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedDate = date;
                });
                widget.onDateSelected(date);
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    dayName,
                    style: TextStyle(
                      fontSize: 14,
                      color: isSelected
                          ? AppColors.pink
                          : AppColors.white.withOpacity(0.7),
                      fontWeight: FontWeight.bold,
                      fontFamily: AppFonts.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.pink : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        dateNumber.toString(),
                        style: TextStyle(
                          fontSize: 14,
                          color: isSelected
                              ? AppColors.white
                              : AppColors.white.withOpacity(0.7),
                          fontWeight: FontWeight.bold,
                          fontFamily: AppFonts.primary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  String _getAbbreviatedDayName(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'MON';
      case DateTime.tuesday:
        return 'TUE';
      case DateTime.wednesday:
        return 'WED';
      case DateTime.thursday:
        return 'THU';
      case DateTime.friday:
        return 'FRI';
      case DateTime.saturday:
        return 'SAT';
      case DateTime.sunday:
        return 'SUN';
      default:
        return '';
    }
  }
}
