import 'package:flutter/material.dart';
import 'package:fyp/modules/authentication/screen/login_screen.dart';
import 'package:fyp/modules/global_import.dart';
import 'package:fyp/modules/authentication/controller/update_controller.dart';

class UpdateScreen extends StatefulWidget {
  const UpdateScreen({super.key});

  @override
  State<UpdateScreen> createState() => _UpdateScreenState();
}

class _UpdateScreenState extends State<UpdateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _oldpasswordController= TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  Future<void> _submit() async {
  if (!_formKey.currentState!.validate()) return;

  setState(() => _isLoading = true);

  final controller = UpdatePasswordController();
  final (success, message) = await controller.updatePassword(
    userId: 10, // replace with the actual logged-in user ID
    oldPassword: _oldpasswordController.text,
    newPassword: _passwordController.text,
  );

  setState(() => _isLoading = false);

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message)),
  );

  if (success) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => LoginScreen()),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Half-circle avatar at top
          Positioned(
            top: -screenHeight * 0.10, // 0.06 * 1.5 (adjusted proportionally)
            left: screenWidth * 0.5 - screenHeight * 0.10, // 0.06 * 1.5
            child: Container(
              width: screenHeight * 0.20, // 0.12 * 1.5
              height: screenHeight * 0.20, // 0.12 * 1.5
              decoration: BoxDecoration(
                color: AppColors.pink,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Image.asset(
                  'assets/images/iconWhite.png',
                  height: screenHeight * 0.09, // 0.06 * 1.5
                  width: screenHeight * 0.09,
                ),
              ),
            ),
          ),

          // Main content
          SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.07),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  SizedBox(height: screenHeight * 0.08), // Space for the circle

                  // Title
                  Text(
                    'EDIT YOUR PASSWORD',
                    style: TextStyle(
                      fontFamily: AppFonts.primary,
                      fontSize: AppFonts.large,
                      fontWeight: AppFonts.bold,
                      color: AppColors.white,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  
             

                  // Sign Up Card
                  Card(
                    color: AppColors.lightbackground,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(screenWidth * 0.05),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Email
                          Text(
                            'old password',
                            style: TextStyle(
                              fontFamily: AppFonts.secondary,
                              fontSize: AppFonts.medium,
                              color: AppColors.white,
                            ),
                          ),
                          TextFormField(
                            controller: _oldpasswordController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your old';
                              }
                              return null;
                            },
                            obscureText: _obscurePassword,
                            style: TextStyle(
                              color: AppColors.background
                            ),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: AppColors.white,
                              
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: screenHeight * 0.018,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: AppColors.background,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.01),

                          // Password
                          Text(
                            'new password',
                            style: TextStyle(
                              fontFamily: AppFonts.secondary,
                              fontSize: AppFonts.medium,
                              color: AppColors.white,
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.01),
                          TextFormField(
                            controller: _passwordController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter new password';
                              }
                              if (value.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                            obscureText: _obscurePassword,
                            style: TextStyle(
                              color: AppColors.background
                            ),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: AppColors.white,
                              
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: screenHeight * 0.018,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: AppColors.background,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.03),

                          // Retype Password
                          Text(
                            'retype password',
                            style: TextStyle(
                              fontFamily: AppFonts.secondary,
                              fontSize: AppFonts.medium,
                              color: AppColors.white,
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.01),
                          TextFormField(
                            controller: _confirmPasswordController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please confirm password';
                              }
                              if (value != _passwordController.text) {
                                return 'Passwords do not match';
                              }
                              return null;
                            },
                            obscureText: _obscureConfirmPassword,
                            style: TextStyle(
                              color: AppColors.background
                            ),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: AppColors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: screenHeight * 0.018,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureConfirmPassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: AppColors.background,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscureConfirmPassword =
                                        !_obscureConfirmPassword;
                                  });
                                },
                              ),
                            ),
                          ),

                          SizedBox(height: screenHeight * 0.06),

                          // Sign Up Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isLoading
                                  ? null
                                  : _submit, // Empty onPressed for design
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.background,
                                padding: EdgeInsets.symmetric(
                                  vertical: screenHeight * 0.015,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: _isLoading
                                  ? CircularProgressIndicator(
                                      color: AppColors.white,
                                    )
                                  : Text(
                                      'NEXT',
                                      style: TextStyle(
                                        fontFamily: AppFonts.primary,
                                        fontSize: AppFonts.xLarge,
                                        fontWeight: AppFonts.bold,
                                        color: AppColors.white,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: screenHeight * 0.05),

                  // Already have an account text
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text.rich(
                      TextSpan(
                        text: "Already have an account? ",
                        style: TextStyle(
                          fontFamily: AppFonts.secondary,
                          fontSize: AppFonts.medium,
                          color: AppColors.white.withOpacity(0.7),
                        ),
                        children: [
                          TextSpan(
                            text: 'Login',
                            style: TextStyle(
                              color: AppColors.pink,
                              fontWeight: AppFonts.semiBold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.05),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
