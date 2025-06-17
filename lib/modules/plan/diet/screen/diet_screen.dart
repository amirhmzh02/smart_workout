import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fyp/modules/global_import.dart';
import 'package:fyp/modules/plan/diet/screen/menu_screen.dart';
import 'package:fyp/shared/widgets/chart.dart';
import 'package:intl/intl.dart';

class DietScreen extends StatefulWidget {
  const DietScreen({super.key});

  @override
  State<DietScreen> createState() => _DietScreenState();
}

class _DietScreenState extends State<DietScreen> {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  String calorieRange = 'Loading...';
  List<WeightData> weightHistory = [];
  bool isLoadingWeights = true;
  double? currentWeight;
  String? lastUpdated;

  final TextEditingController weightController = TextEditingController();
  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();
    fetchCalorieRange();
    fetchWeightData();
  }

  Future<void> fetchCalorieRange() async {
    final userId = await _storage.read(key: 'userId');

    if (userId == null) {
      setState(() {
        calorieRange = 'User ID not found';
      });
      return;
    }
    final url = Uri.parse('http://$activeIP/get_user_cal.php');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'user_id': userId}),
      );

      final data = jsonDecode(response.body);

      if (data['success']) {
        final min = data['data']['min_calories_per_day'];
        final max = data['data']['max_calories_per_day'];
        setState(() {
          calorieRange = '$min - $max';
        });
      } else {
        setState(() {
          calorieRange = 'No data found';
        });
      }
    } catch (e) {
      setState(() {
        calorieRange = 'Error loading data';
      });
    }
  }

  Future<void> fetchWeightData() async {
    final userId = await _storage.read(key: 'userId');
    if (userId == null) return;

    try {
      final response = await http.post(
        Uri.parse('http://$activeIP/get_weight_history.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'user_id': userId}),
      );

      final data = jsonDecode(response.body);

      if (data['success']) {
        List<WeightData> weights = [];
        double? latestWeight;
        String? latestDate;

        for (var entry in data['data']) {
          final weight = double.tryParse(entry['weight'].toString()) ?? 0;
          final date = DateTime.parse(entry['date']);

          weights.add(WeightData(date: date, weight: weight));

          if (latestDate == null || date.isAfter(DateTime.parse(latestDate))) {
            latestWeight = weight;
            latestDate = entry['date'];
          }
        }

        setState(() {
          weightHistory = weights;
          currentWeight = latestWeight;
          lastUpdated = latestDate;
          isLoadingWeights = false;
        });
      } else {
        setState(() => isLoadingWeights = false);
      }
    } catch (e) {
      setState(() => isLoadingWeights = false);
    }
  }

  Future<void> submitWeight(double weight) async {
    final userId = await _storage.read(key: 'userId');
    final url = Uri.parse(
        'http://$activeIP/update_weight.php'); // Adjust this to your API

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_id': userId,
        'weight': weight,
        'date': DateFormat('yyyy-MM-dd').format(DateTime.now()),
      }),
    );

    final data = jsonDecode(response.body);

    if (data['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Weight updated successfully')),
      );
      // Refresh the chart
      fetchWeightData(); // Make sure this function fetches updated weightHistory
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(data['message'] ?? 'Failed to update weight')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.07),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: screenHeight * 0.05),
              WeightChart(
                isLoading: isLoadingWeights,
                weightHistory: weightHistory,
              ),
              SizedBox(height: screenHeight * 0.04),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: weightController,
                      keyboardType:
                          TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: 'Your weight (kg)',
                        filled: true,
                        fillColor: AppColors.lightbackground,
                        labelStyle: TextStyle(color: AppColors.white),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: AppColors.pink),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: AppColors.pink, width: 2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      style: TextStyle(color: AppColors.white),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: isSubmitting
                        ? null
                        : () async {
                            final weightText = weightController.text.trim();
                            final weight = double.tryParse(weightText);

                            if (weight == null || weight <= 0) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content:
                                        Text('Please enter a valid weight')),
                              );
                              return;
                            }

                            setState(() => isSubmitting = true);

                            // You can customize this function to save weight to your DB/API
                            await submitWeight(weight);

                            weightController.clear();
                            setState(() => isSubmitting = false);
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.pink,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 18),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: isSubmitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                          )
                        : const Text(
                            'Submit',
                            style: TextStyle(
                              color: AppColors.white,
                              fontFamily: AppFonts.primary,
                            ),
                          ),
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.04),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(screenWidth * 0.07),
                decoration: BoxDecoration(
                  color: AppColors.lightbackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      'CALORIES INTAKE',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: screenHeight * 0.02,
                        fontFamily: AppFonts.primary,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          calorieRange,
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: screenHeight * 0.018,
                            fontFamily: AppFonts.secondary,
                          ),
                        ),
                        Text(
                          'kcal/day',
                          style: TextStyle(
                            color: AppColors.pink,
                            fontSize: screenHeight * 0.018,
                            fontFamily: AppFonts.secondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const MenuScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.pink,
                    padding: EdgeInsets.symmetric(
                      vertical: screenHeight * 0.02,
                      horizontal: screenWidth * 0.1,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'View Menu',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: screenHeight * 0.022,
                      fontFamily: AppFonts.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.05),
            ],
          ),
        ),
      ),
    );
  }
}
