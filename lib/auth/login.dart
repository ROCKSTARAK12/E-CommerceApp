import 'package:e_commerce_app/All_Screen/Home_Screen.dart';
import 'package:e_commerce_app/auth/Signup_Page.dart';
import 'package:e_commerce_app/auth/auth_sevices.dart';
import 'package:e_commerce_app/auth/forgotPassword.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'Transition_helper.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;

  late final AnimationController _headerController;
  late final AnimationController _formController;
  late final AnimationController _buttonPulseController;

  @override
  void initState() {
    super.initState();

    _headerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..forward();

    _formController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) _formController.forward();
    });

    // ✅ FIXED: Proper bounds for AnimationController
    _buttonPulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
      lowerBound: 0.0, // Changed from 0.97
      upperBound: 1.0, // Changed from 1.05
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    _headerController.dispose();
    _formController.dispose();
    _buttonPulseController.dispose();
    super.dispose();
  }

  /// 🟣 FIXED LOGIN FUNCTION — catches FirebaseAuthException safely
  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showMessage("Please enter email and password");
      return;
    }

    // ✅ Fixed email validation regex
    if (!RegExp(r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,4}$').hasMatch(email)) {
      _showMessage("Please enter a valid email address");
      return;
    }

    setState(() => _isLoading = true);

    try {
      // This should return a Firebase User
      User? user = await AuthService.login(email, password);

      if (user != null) {
        _showMessage("Login Successful!");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      } else {
        _showMessage("Login failed. Please try again.");
      }
    } on FirebaseAuthException catch (e) {
      // ✅ Firebase-safe error handling
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = "No account found for this email.";
          break;
        case 'wrong-password':
          message = "Incorrect password. Try again.";
          break;
        case 'invalid-email':
          message = "Invalid email format.";
          break;
        case 'user-disabled':
          message = "This user account has been disabled.";
          break;
        default:
          message = "Login failed: ${e.message}";
      }
      _showMessage(message);
    } catch (e) {
      // ✅ Prevent app crash on unknown exceptions
      _showMessage("Something went wrong: ${e.toString()}");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void goToSignUp() {
    Navigator.push(
      context,
      createSlideRoute(const SignUpScreen(), fromRight: true),
    );
  }

  void goToForgotPassword() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()),
    );
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: message.contains('Successful')
            ? Colors.green
            : Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final slideAnimation =
        Tween<Offset>(begin: const Offset(0, -0.5), end: Offset.zero).animate(
          CurvedAnimation(parent: _headerController, curve: Curves.easeOut),
        );

    final fadeAnimation = CurvedAnimation(
      parent: _formController,
      curve: Curves.easeOut,
    );

    return Scaffold(
      backgroundColor: const Color(0xFF6659FF),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 60),

              // 🟣 Animated Header
              SlideTransition(
                position: slideAnimation,
                child: FadeTransition(
                  opacity: _headerController,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 30),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Welcome\nback",
                        style: TextStyle(
                          fontSize: 40,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          height: 1.1,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 60),

              // 🧾 Login Container
              FadeTransition(
                opacity: fadeAnimation,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 30,
                  ),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(35),
                      topRight: Radius.circular(35),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Login",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),

                      TextField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.email_outlined),
                          labelText: "Email",
                          border: UnderlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ✅ FIXED: Replaced TextButton with IconButton
                      TextField(
                        controller: passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.lock_outline),
                          labelText: "Password",
                          border: const UnderlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: Colors.grey,
                            ),
                            onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: goToForgotPassword,
                          child: const Text(
                            "Forgot passcode?",
                            style: TextStyle(color: Color(0xFF6659FF)),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ✅ FIXED: AnimatedBuilder with manual scale calculation
                      AnimatedBuilder(
                        animation: _buttonPulseController,
                        builder: (context, child) {
                          // Map 0.0-1.0 to 0.97-1.05 scale
                          final scale =
                              0.97 + (_buttonPulseController.value * 0.08);
                          return Transform.scale(
                            scale: scale,
                            child: SizedBox(
                              width: double.infinity,
                              height: 55,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : login,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF6659FF),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                                child: _isLoading
                                    ? const CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      )
                                    : const Text(
                                        "Login",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 20),

                      Center(
                        child: GestureDetector(
                          onTap: goToSignUp,
                          child: const Text(
                            "Create account",
                            style: TextStyle(
                              color: Color(0xFF6659FF),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
