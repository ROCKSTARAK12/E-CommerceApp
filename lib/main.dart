import 'package:e_commerce_app/All_Screen/Onboarding_Screen.dart';
import 'package:e_commerce_app/All_Screen/home_screen.dart';
import 'package:e_commerce_app/auth/login.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Magic Mart',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const LaunchDecider(),
    );
  }
}

/// Decides whether to show onboarding, login, or main screen
class LaunchDecider extends StatefulWidget {
  const LaunchDecider({super.key});

  @override
  State<LaunchDecider> createState() => _LaunchDeciderState();
}

class _LaunchDeciderState extends State<LaunchDecider> {
  bool _isLoading = true;
  bool _hasSeenOnboarding = false;

  @override
  void initState() {
    super.initState();
    _checkFirstTimeUser();
  }

  Future<void> _checkFirstTimeUser() async {
    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getBool('hasSeenOnboarding') ?? false;

    setState(() {
      _hasSeenOnboarding = seen;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Show loading indicator while checking
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF6A1B9A),
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    // If user hasn't seen onboarding yet, show it
    if (!_hasSeenOnboarding) {
      return OnboardingScreen(
        onFinished: () async {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('hasSeenOnboarding', true);

          // Navigate to AuthWrapper after onboarding
          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const AuthWrapper()),
            );
          }
        },
      );
    }

    // If onboarding is done, check auth state
    return const AuthWrapper();
  }
}

/// Handles Firebase Auth state
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Show loading while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFF6A1B9A),
            body: Center(child: CircularProgressIndicator(color: Colors.white)),
          );
        }

        // User is logged in
        if (snapshot.hasData) {
          return const HomeScreen();
        }

        // User is not logged in
        return const LoginScreen();
      },
    );
  }
}
