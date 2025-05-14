import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fyp/modules/authentication/screen/login_screen.dart';
import 'package:fyp/modules/main_nav.dart';
import 'package:fyp/modules/global_import.dart';
import 'package:fyp/modules/authentication/screen/signup_screen.dart';
import 'package:fyp/modules/FirtTimeUser/result_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

// ========== DEV CONFIG ==========
// Set this to quickly change which screen shows first during dev
enum DevStartScreen {
  authWrapper,
  login,
  signup,
  mainNav,
  result,
}

// Easily change this to pick your start screen
const DevStartScreen DEV_START_SCREEN = DevStartScreen.login;
// =================================

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: _buildAppTheme(),
      home: _getStartScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/main': (context) => const MainNav(),
      },
    );
  }

  ThemeData _buildAppTheme() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.deepPurple,
        brightness: Brightness.dark,
      ),
      useMaterial3: true,
      fontFamily: AppFonts.primary,
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontFamily: AppFonts.primary),
        displayMedium: TextStyle(fontFamily: AppFonts.primary),
        bodyLarge: TextStyle(fontFamily: AppFonts.secondary),
        bodyMedium: TextStyle(fontFamily: AppFonts.secondary),
      ),
    );
  }

  Widget _getStartScreen() {
    switch (DEV_START_SCREEN) {
      case DevStartScreen.login:
        return const LoginScreen();
      case DevStartScreen.signup:
        return const SignUpScreen();
      case DevStartScreen.mainNav:
        return const MainNav();
      case DevStartScreen.authWrapper:
      default:
        return const AuthWrapper();
    }
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  bool _isLoading = true;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    final userId = await _storage.read(key: 'userId');
    if (userId != null) {
      await UserController().fetchAndStoreUserData();
    }

    setState(() {
      _isLoggedIn = userId != null;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return _isLoggedIn ? const MainNav() : const LoginScreen();
  }
}
