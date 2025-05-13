import 'package:flutter/material.dart';
import 'package:fyp/modules/global_import.dart';
import 'package:fyp/modules/FirtTimeUser/firstTimeUser_controller.dart';
import 'package:fyp/modules/FirtTimeUser/result_screen.dart';

class FirstTimeUserScreen extends StatefulWidget {
  const FirstTimeUserScreen({super.key});

  @override
  State<FirstTimeUserScreen> createState() => _FirstTimeUserScreenState();
}

class _FirstTimeUserScreenState extends State<FirstTimeUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final _controller = FirstTimeUserController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  String? _selectedGender;
  bool _isSubmitting = false;
  double _activityLevel = 3;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.08,
            vertical: screenHeight * 0.05,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Text(
                  'Welcome',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                    fontFamily: AppFonts.primary,
                  ),
                ),
                SizedBox(height: screenHeight * 0.01),
                Text(
                  'Tell us about yourself',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.white.withOpacity(0.7),
                    fontFamily: AppFonts.secondary,
                  ),
                ),
                SizedBox(height: screenHeight * 0.05),

                // Name Field
                _buildLabel('Name'),
                _buildTextField(_nameController, hint: 'Enter your full name'),
                SizedBox(height: screenHeight * 0.03),

                // Age Field
                _buildLabel('Age'),
                _buildTextField(
                  _ageController,
                  hint: 'Enter your age',
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: screenHeight * 0.03),

                // Weight Field
                _buildLabel('Weight (kg)'),
                _buildTextField(
                  _weightController,
                  hint: 'Enter your weight',
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: screenHeight * 0.03),

                // Height Field
                _buildLabel('Height (cm)'),
                _buildTextField(
                  _heightController,
                  hint: 'Enter your height',
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: screenHeight * 0.05),

                // Gender Selection
                _buildLabel('Gender'),
                Row(
                  children: [
                    _buildGenderOption('Male', 'male'),
                    SizedBox(width: screenWidth * 0.1),
                    _buildGenderOption('Female', 'female'),
                  ],
                ),
                SizedBox(height: screenHeight * 0.08),
// Activity Level Slider
                _buildLabel('Activity Level (${_activityLevel.round()})'),
                Slider(
                  value: _activityLevel,
                  min: 1,
                  max: 5,
                  divisions: 4,
                  activeColor: AppColors.pink,
                  inactiveColor: Colors.grey[700],
                  label: _activityLevel.round().toString(),
                  onChanged: (value) {
                    setState(() {
                      _activityLevel = value;
                    });
                  },
                ),
                Text(
                  _getActivityDescription(_activityLevel.round()),
                  style: TextStyle(
                    color: AppColors.white.withOpacity(0.7),
                    fontFamily: AppFonts.secondary,
                  ),
                ),

                // Next Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.pink,
                      padding: EdgeInsets.symmetric(
                        vertical: screenHeight * 0.02,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'NEXT',
                      style: TextStyle(
                        fontFamily: AppFonts.primary,
                        fontSize: AppFonts.large,
                        fontWeight: FontWeight.bold,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: AppFonts.secondary,
          fontSize: AppFonts.medium,
          color: AppColors.white,
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller, {
    String? hint,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      style: TextStyle(color: AppColors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade500),
        filled: true,
        fillColor: AppColors.lightbackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      keyboardType: keyboardType,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'This field is required';
        }
        return null;
      },
    );
  }

  Widget _buildGenderOption(String label, String value) {
    return GestureDetector(
      onTap: () => setState(() => _selectedGender = value),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: _selectedGender == value ? AppColors.pink : Colors.grey,
                width: 2,
              ),
            ),
            child: _selectedGender == value
                ? Center(
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.pink,
                      ),
                    ),
                  )
                : null,
          ),
          SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: AppColors.white,
              fontFamily: AppFonts.secondary,
            ),
          ),
        ],
      ),
    );
  }

  String _getActivityDescription(int level) {
    switch (level) {
      case 1:
        return "Sedentary (little or no exercise)";
      case 2:
        return "Lightly active (light exercise 1–3 days/week)";
      case 3:
        return "Moderately active (moderate exercise 3–5 days/week)";
      case 4:
        return "Very active (hard exercise 6–7 days/week)";
      case 5:
        return "Super active (very hard exercise, physical job)";
      default:
        return "";
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedGender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select your gender')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // Get raw values first
      final weight = double.tryParse(_weightController.text) ?? 0;
      final height = double.tryParse(_heightController.text) ?? 0;

      // Option 1: Calculate locally
      final bmiResult = await FirstTimeUserController.submitUserData(
        name: _nameController.text,
        age: _ageController.text,
        weight: weight.toString(),
        height: height.toString(),
        gender: _selectedGender!,
        activityLevel: _activityLevel.round(),
      );

     

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResultsScreen(
            bmi: bmiResult.bmi,
            category: bmiResult.category,
            goal: bmiResult.goal.toUpperCase(),
          ),
        ),
      );

      print(bmiResult);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }
}
