import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Sign Up Method
  static Future<User?> signUp(String email, String password) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password)
          .timeout(const Duration(seconds: 20));

      final User? user = userCredential.user;

      if (user != null) {
        // Save user data to Firestore
        await _saveUserToFirestore(user, email);
        return user;
      }

      return null;
    } on TimeoutException {
      throw Exception(
        'Request timed out. Please check your internet connection.',
      );
    } on FirebaseAuthException catch (e) {
      _handleSignUpError(e);
      return null; // This line will never be reached due to rethrow
    } catch (e) {
      throw Exception('An unexpected error occurred. Please try again.');
    }
  }

  // Handle sign up errors
  static void _handleSignUpError(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        throw Exception('Password should be at least 6 characters long.');
      case 'email-already-in-use':
        throw Exception('An account already exists for this email.');
      case 'invalid-email':
        throw Exception('Please enter a valid email address.');
      case 'operation-not-allowed':
        throw Exception('Email/password accounts are not enabled.');
      case 'network-request-failed':
        throw Exception(
          'Network error. Please check your internet connection.',
        );
      default:
        throw Exception('Sign up failed: ${e.message ?? 'Unknown error'}');
    }
  }

  // Save user to Firestore
  static Future<void> _saveUserToFirestore(User user, String email) async {
    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .set({
            'uid': user.uid,
            'email': email,
            'createdAt': FieldValue.serverTimestamp(),
            'displayName': user.displayName ?? '',
            'photoURL': user.photoURL ?? '',
            'lastLogin': FieldValue.serverTimestamp(),
          })
          .timeout(const Duration(seconds: 10));
    } catch (e) {
      // Log error but don't prevent user creation
      print('Firestore save error: $e');
    }
  }

  // Login Method
  static Future<User?> login(String email, String password) async {
    try {
      UserCredential userCredential = await _auth
          .signInWithEmailAndPassword(email: email, password: password)
          .timeout(const Duration(seconds: 15));

      final User? user = userCredential.user;

      if (user != null) {
        await _updateLastLogin(user.uid);
      }

      return user;
    } on TimeoutException {
      throw Exception(
        'Login timed out. Please check your internet connection.',
      );
    } on FirebaseAuthException catch (e) {
      _handleLoginError(e);
      return null;
    } catch (e) {
      throw Exception('Login failed. Please try again.');
    }
  }

  // Handle login errors
  static void _handleLoginError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        throw Exception('No account found with this email.');
      case 'wrong-password':
        throw Exception('Incorrect password.');
      case 'invalid-email':
        throw Exception('Please enter a valid email address.');
      case 'user-disabled':
        throw Exception('This account has been disabled.');
      case 'too-many-requests':
        throw Exception('Too many failed attempts. Please try again later.');
      case 'network-request-failed':
        throw Exception(
          'Network error. Please check your internet connection.',
        );
      default:
        throw Exception('Login failed: ${e.message ?? 'Unknown error'}');
    }
  }

  // Update last login
  static Future<void> _updateLastLogin(String uid) async {
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .update({'lastLogin': FieldValue.serverTimestamp()})
          .timeout(const Duration(seconds: 5));
    } catch (e) {
      // Silent fail - not critical
    }
  }

  // Sign In Method (alias for login)
  static Future<User?> signIn(String email, String password) async {
    return await login(email, password);
  }

  // Sign Out Method
  static Future<void> signOut() async {
    await _auth.signOut();
  }

  // Get current user
  static User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Check if user is logged in
  static bool isLoggedIn() {
    return _auth.currentUser != null;
  }

  // Reset Password Method
  static Future<void> resetPassword(String email) async {
    try {
      await _auth
          .sendPasswordResetEmail(email: email)
          .timeout(const Duration(seconds: 15));
    } on TimeoutException {
      throw Exception('Request timed out. Please try again.');
    } on FirebaseAuthException catch (e) {
      _handlePasswordResetError(e);
    } catch (e) {
      throw Exception('Password reset failed. Please try again.');
    }
  }

  // Handle password reset errors
  static void _handlePasswordResetError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        throw Exception('No account found with this email.');
      case 'invalid-email':
        throw Exception('Please enter a valid email address.');
      case 'too-many-requests':
        throw Exception('Too many requests. Please try again later.');
      default:
        throw Exception(
          'Password reset failed: ${e.message ?? 'Unknown error'}',
        );
    }
  }

  // Get user data from Firestore
  static Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(uid)
          .get()
          .timeout(const Duration(seconds: 10));

      if (doc.exists) {
        return doc.data() as Map<String, dynamic>?;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Update user profile
  static Future<void> updateProfile(String displayName, String photoURL) async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        await user.updateDisplayName(displayName);
        await user.updatePhotoURL(photoURL);

        // Update Firestore
        await _firestore.collection('users').doc(user.uid).update({
          'displayName': displayName,
          'photoURL': photoURL,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  // Delete user account
  static Future<void> deleteAccount() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        // Delete from Firestore first
        await _firestore.collection('users').doc(user.uid).delete();
        // Then delete auth account
        await user.delete();
      }
    } catch (e) {
      throw Exception('Failed to delete account: $e');
    }
  }
}
