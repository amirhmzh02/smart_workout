import 'package:flutter/material.dart';
import 'package:fyp/modules/global_import.dart';
import 'package:fyp/modules/authentication/controller/login_controller.dart';
import 'package:fyp/modules/authentication/screen/signup_screen.dart';
import 'package:fyp/modules/FirtTimeUser/firstTimeUser_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final (success, message) = await LoginController().login(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

    if (success) {
      try {
        await UserController().fetchAndStoreUserData();
      } catch (e) {
        print(e);
      }

      int firstTimeUser = await UserController.FirstTimeUser();
      if (firstTimeUser == 1) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const FirstTimeUserScreen()),
        );
      } else {
        try {
          await UserController().fetchAndStoreUserData();
        } catch (e) {
          print(e);
        }
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainNav()),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }

    setState(() => _isLoading = false);
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
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                SizedBox(height: screenHeight * 0.06),

                // Logo
                Image.asset(
                  'assets/images/logo.png',
                  height: screenHeight * 0.15,
                  width: screenHeight * 0.30,
                ),

                SizedBox(height: screenHeight * 0.03),

                // Login Card
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
                        Center(
                          child: Text(
                            'LOGIN',
                            style: TextStyle(
                              fontFamily: AppFonts.primary,
                              fontSize: AppFonts.xLarge,
                              fontWeight: AppFonts.bold,
                              color: AppColors.white,
                            ),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.03),

                        // Email
                        Text(
                          'email',
                          style: TextStyle(
                            fontFamily: AppFonts.secondary,
                            fontSize: AppFonts.medium,
                            color: AppColors.white,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.01),
                        TextFormField(
                          controller: _emailController,
                          validator: (value) =>
                              value!.isEmpty ? 'Please enter email' : null,
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
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.03),

                        // Password
                        Text(
                          'password',
                          style: TextStyle(
                            fontFamily: AppFonts.secondary,
                            fontSize: AppFonts.medium,
                            color: AppColors.white,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.01),
                        TextFormField(
                          controller: _passwordController,
                          validator: (value) =>
                              value!.isEmpty ? 'Please enter password' : null,
                          obscureText: true,
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
                          ),
                        ),

                        SizedBox(height: screenHeight * 0.06),

                        // Login Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _submit,
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

                // Sign Up Text
                Text.rich(
                  TextSpan(
                    text: "don't have an account? ",
                    style: TextStyle(
                      fontFamily: AppFonts.secondary,
                      fontSize: AppFonts.medium,
                      color: AppColors.white.withOpacity(0.7),
                    ),
                    children: [
                      WidgetSpan(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const SignUpScreen()),
                            );
                          },
                          child: Text(
                            'Sign up',
                            style: TextStyle(
                              color: AppColors.pink,
                              fontWeight: AppFonts.semiBold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: screenHeight * 0.05),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
