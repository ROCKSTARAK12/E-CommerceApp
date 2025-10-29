import 'package:e_commerce_app/auth/login.dart';
import 'package:e_commerce_app/auth/auth_sevices.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'transition_helper.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen>
    with TickerProviderStateMixin {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _isChecked = false;
  bool _obscurePassword = true;
  bool _isLoading = false;

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
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    _headerController.dispose();
    _formController.dispose();
    _buttonPulseController.dispose();
    super.dispose();
  }

  void goToLogin() {
    Navigator.pushReplacement(
      context,
      createSlideRoute(const LoginScreen(), fromRight: false),
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

  /// ✅ Firebase Signup with full error handling
  Future<void> _signUp() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    // ✅ Validation checks
    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      _showMessage("Please fill all fields");
      return;
    }

    if (!RegExp(r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,4}$').hasMatch(email)) {
      _showMessage("Please enter a valid email address");
      return;
    }

    if (password.length < 6) {
      _showMessage("Password must be at least 6 characters long");
      return;
    }

    if (!_isChecked) {
      _showMessage("Please agree to Terms and Privacy Policy");
      return;
    }

    setState(() => _isLoading = true);

    try {
      // ✅ Call your AuthService (handles FirebaseAuth internally)
      User? user = await AuthService.signUp(name, email, password);

      if (user != null) {
        _showMessage("Account Created Successfully!");
        goToLogin();
      } else {
        _showMessage("Signup failed. Please try again.");
      }
    } on FirebaseAuthException catch (e) {
      // ✅ Friendly Firebase error messages
      String message;
      switch (e.code) {
        case 'email-already-in-use':
          message = "This email is already registered.";
          break;
        case 'invalid-email':
          message = "Invalid email address format.";
          break;
        case 'weak-password':
          message = "Password is too weak. Try a stronger one.";
          break;
        default:
          message = "Signup failed: ${e.message}";
      }
      _showMessage(message);
    } catch (e) {
      // ✅ Prevent unhandled crash
      _showMessage("Something went wrong: ${e.toString()}");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
                        "Create\nAccount",
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

              // 🧾 Animated Form Container
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
                        "Register",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // 👤 Full Name
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.person_outline),
                          labelText: "Full Name",
                          border: UnderlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ✉️ Email
                      TextField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.email_outlined),
                          labelText: "Email Address",
                          border: UnderlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // 🔑 Password
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

                      const SizedBox(height: 15),

                      // ☑️ Terms Checkbox
                      Row(
                        children: [
                          Checkbox(
                            value: _isChecked,
                            activeColor: const Color(0xFF6659FF),
                            onChanged: (val) =>
                                setState(() => _isChecked = val ?? false),
                          ),
                          Expanded(
                            child: RichText(
                              text: const TextSpan(
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 14,
                                ),
                                children: [
                                  TextSpan(text: "I agree to "),
                                  TextSpan(
                                    text: "Terms",
                                    style: TextStyle(color: Color(0xFF6659FF)),
                                  ),
                                  TextSpan(text: " and "),
                                  TextSpan(
                                    text: "Privacy Policy",
                                    style: TextStyle(color: Color(0xFF6659FF)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 25),

                      // 🚀 Animated Register Button - FIXED
                      AnimatedBuilder(
                        animation: _buttonPulseController,
                        builder: (context, child) {
                          // ✅ FIXED: Map 0.0-1.0 to 0.97-1.05 scale
                          final scale =
                              0.97 + (_buttonPulseController.value * 0.08);
                          return Transform.scale(
                            scale: scale,
                            child: SizedBox(
                              width: double.infinity,
                              height: 55,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _signUp,
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
                                        "Sign Up",
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

                      const SizedBox(height: 25),

                      // 👤 Already have an account
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Already have an account? "),
                            GestureDetector(
                              onTap: goToLogin,
                              child: const Text(
                                "Log In",
                                style: TextStyle(
                                  color: Color(0xFF6659FF),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
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
