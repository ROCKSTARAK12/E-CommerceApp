import 'package:flutter/material.dart';

/// Creates a smooth slide transition route for page navigation
///
/// [page] - The destination widget to navigate to
/// [fromRight] - If true, slides from right to left. If false, slides from left to right
Route createSlideRoute(Widget page, {bool fromRight = true}) {
  return PageRouteBuilder(
    transitionDuration: const Duration(milliseconds: 500),
    reverseTransitionDuration: const Duration(milliseconds: 400),
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      // Define the slide direction
      final begin = Offset(fromRight ? 1.0 : -1.0, 0.0);
      const end = Offset.zero;

      // Use easeInOut curve for smooth animation
      final tween = Tween(begin: begin, end: end);
      final curvedAnimation = CurvedAnimation(
        parent: animation,
        curve: Curves.easeInOut,
        reverseCurve: Curves.easeIn,
      );

      return SlideTransition(
        position: tween.animate(curvedAnimation),
        child: child,
      );
    },
  );
}

/// Creates a fade transition route for page navigation
Route createFadeRoute(Widget page) {
  return PageRouteBuilder(
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: animation, child: child);
    },
  );
}

/// Creates a scale transition route (zoom effect) for page navigation
Route createScaleRoute(Widget page) {
  return PageRouteBuilder(
    transitionDuration: const Duration(milliseconds: 400),
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final tween = Tween(begin: 0.8, end: 1.0);
      final curvedAnimation = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      );

      return ScaleTransition(
        scale: tween.animate(curvedAnimation),
        child: FadeTransition(opacity: animation, child: child),
      );
    },
  );
}
