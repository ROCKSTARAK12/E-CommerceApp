import 'package:e_commerce_app/auth/login.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'transition_helper.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onFinished; // ✅ single callback to notify completion

  const OnboardingScreen({super.key, required this.onFinished});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  late final AnimationController _iconController;
  late final AnimationController _fadeController;
  late final AnimationController _buttonPulseController;

  @override
  void initState() {
    super.initState();

    // 🌠 Floating & rotating icons
    _iconController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    // 🌈 Fade-in for text & main illustration
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..forward();

    // 💫 Pulsing button animation
    _buttonPulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
      lowerBound: 0.95,
      upperBound: 1.05,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _iconController.dispose();
    _fadeController.dispose();
    _buttonPulseController.dispose();
    super.dispose();
  }

  Widget _floatingIcon(
    String image,
    double delay,
    double size, {
    Offset offset = Offset.zero,
  }) {
    return AnimatedBuilder(
      animation: _iconController,
      builder: (context, child) {
        double dy =
            math.sin((_iconController.value * 2 * math.pi) + delay) * 10;
        double rotation =
            math.sin((_iconController.value * 2 * math.pi) + delay) * 0.3;

        return Transform.translate(
          offset: Offset(offset.dx, offset.dy + dy),
          child: Transform.rotate(angle: rotation, child: child),
        );
      },
      child: Image.network(image, height: size, width: size),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );

    return Scaffold(
      backgroundColor: const Color(0xFF6659FF),
      body: SafeArea(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 🌟 Floating icons
            Positioned(
              top: 120,
              left: 30,
              child: _floatingIcon(
                "https://cdn-icons-png.flaticon.com/512/869/869869.png",
                0.0,
                60,
              ),
            ),
            Positioned(
              top: 140,
              right: 40,
              child: _floatingIcon(
                "https://cdn-icons-png.flaticon.com/512/1828/1828911.png",
                0.8,
                60,
              ),
            ),
            Positioned(
              bottom: 280,
              left: 80,
              child: _floatingIcon(
                "https://cdn-icons-png.flaticon.com/512/2111/2111646.png",
                1.4,
                50,
              ),
            ),
            Positioned(
              bottom: 300,
              right: 90,
              child: _floatingIcon(
                "https://cdn-icons-png.flaticon.com/512/545/545682.png",
                2.0,
                50,
              ),
            ),

            // 🧠 Main content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: FadeTransition(
                opacity: fadeAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),

                    // 🪄 Title
                    const Text(
                      "Find your\nGadget",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 40),

                    // 🧍‍♂️ Illustration
                    Image.network(
                      "https://cdn-icons-png.flaticon.com/512/1077/1077012.png",
                      height: 280,
                      fit: BoxFit.contain,
                    ),

                    const SizedBox(height: 60),

                    // 🚀 Pulsing Get Started button
                    ScaleTransition(
                      scale: Tween(begin: 0.95, end: 1.05).animate(
                        CurvedAnimation(
                          parent: _buttonPulseController,
                          curve: Curves.easeInOut,
                        ),
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            elevation: 6,
                          ),
                          onPressed: () async {
                            // ✅ Notify LaunchDecider that onboarding is done
                            widget.onFinished();

                            // ✅ Navigate with smooth slide
                            Navigator.pushReplacement(
                              context,
                              createSlideRoute(
                                const LoginScreen(),
                                fromRight: true,
                              ),
                            );
                          },
                          child: const Text(
                            "Get started",
                            style: TextStyle(
                              color: Color(0xFF6659FF),
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
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
    );
  }
}
