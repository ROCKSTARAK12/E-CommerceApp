import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ✅ Replace with your actual default profile image link
  static const String _defaultProfileURL =
      "https://firebasestorage.googleapis.com/v0/b/YOUR_BUCKET_NAME_HERE/o/default_profile.png?alt=media";

  // 🟣 SIGN UP METHOD
  static Future<User?> signUp(
    String name,
    String email,
    String password,
  ) async {
    try {
      // Create Firebase Auth user
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password)
          .timeout(const Duration(seconds: 20));

      final User? user = userCredential.user;

      if (user != null) {
        // ✅ Update display name and photo URL
        await user.updateDisplayName(name);
        await user.updatePhotoURL(_defaultProfileURL);
        await user.reload();

        // ✅ Save user info to Firestore
        await _saveUserToFirestore(user, name, email);
        return user;
      }
      return null;
    } on TimeoutException {
      throw Exception('Request timed out. Please check your internet.');
    } on FirebaseAuthException catch (e) {
      _handleSignUpError(e);
      return null;
    } catch (e) {
      throw Exception('An unexpected error occurred. Please try again.');
    }
  }

  // 🟣 HANDLE SIGN-UP ERRORS
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
        throw Exception('Network error. Please check your internet.');
      default:
        throw Exception('Sign-up failed: ${e.message ?? 'Unknown error'}');
    }
  }

  // 🟣 SAVE USER TO FIRESTORE
  static Future<void> _saveUserToFirestore(
    User user,
    String name,
    String email,
  ) async {
    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .set({
            'uid': user.uid,
            'name': name,
            'email': email,
            'photoURL': _defaultProfileURL,
            'createdAt': FieldValue.serverTimestamp(),
            'lastLogin': FieldValue.serverTimestamp(),
          })
          .timeout(const Duration(seconds: 10));
    } catch (e) {
      // Don't break signup on Firestore error
      print('⚠️ Firestore save error: $e');
    }
  }

  // 🟣 LOGIN METHOD
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
      throw Exception('Login timed out. Please check your internet.');
    } on FirebaseAuthException catch (e) {
      _handleLoginError(e);
      return null;
    } catch (e) {
      throw Exception('Login failed. Please try again.');
    }
  }

  // 🟣 HANDLE LOGIN ERRORS
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
        throw Exception('Too many failed attempts. Try again later.');
      case 'network-request-failed':
        throw Exception('Network error. Please check your internet.');
      default:
        throw Exception('Login failed: ${e.message ?? 'Unknown error'}');
    }
  }

  // 🟣 UPDATE LAST LOGIN
  static Future<void> _updateLastLogin(String uid) async {
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .update({'lastLogin': FieldValue.serverTimestamp()})
          .timeout(const Duration(seconds: 5));
    } catch (_) {
      // Silent fail
    }
  }

  // 🟣 SIGN OUT
  static Future<void> signOut() async {
    await _auth.signOut();
  }

  // 🟣 GET CURRENT USER
  static User? getCurrentUser() => _auth.currentUser;

  // 🟣 CHECK LOGIN STATUS
  static bool isLoggedIn() => _auth.currentUser != null;

  // 🟣 RESET PASSWORD
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

  static void _handlePasswordResetError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        throw Exception('No account found with this email.');
      case 'invalid-email':
        throw Exception('Please enter a valid email address.');
      case 'too-many-requests':
        throw Exception('Too many requests. Try again later.');
      default:
        throw Exception(
          'Password reset failed: ${e.message ?? 'Unknown error'}',
        );
    }
  }

  // 🟣 GET USER DATA
  static Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(uid)
          .get()
          .timeout(const Duration(seconds: 10));

      if (doc.exists) return doc.data() as Map<String, dynamic>?;
      return null;
    } catch (_) {
      return null;
    }
  }

  // 🟣 UPDATE PROFILE
  static Future<void> updateProfile(String displayName, String photoURL) async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        await user.updateDisplayName(displayName);
        await user.updatePhotoURL(photoURL);

        await _firestore.collection('users').doc(user.uid).update({
          'name': displayName,
          'photoURL': photoURL,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  // 🟣 DELETE ACCOUNT
  static Future<void> deleteAccount() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).delete();
        await user.delete();
      }
    } catch (e) {
      throw Exception('Failed to delete account: $e');
    }
  }
}
