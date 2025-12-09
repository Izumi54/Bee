import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Firebase Authentication Service
/// Handles user authentication with email/password
class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get current Firebase user
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  /// Stream of auth state changes
  Stream<User?> authStateChanges() {
    return _auth.authStateChanges();
  }

  /// Sign up new user with email and password
  Future<UserCredential?> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      debugPrint('✅ User signed up: ${credential.user?.uid}');
      return credential;
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ Sign up error: ${e.code} - ${e.message}');

      // Rethrow with user-friendly message
      switch (e.code) {
        case 'weak-password':
          throw Exception('Password terlalu lemah. Minimal 6 karakter.');
        case 'email-already-in-use':
          throw Exception('Email sudah terdaftar. Silakan login.');
        case 'invalid-email':
          throw Exception('Format email tidak valid.');
        default:
          throw Exception('Pendaftaran gagal: ${e.message}');
      }
    } catch (e) {
      debugPrint('❌ Unexpected error: $e');
      throw Exception('Terjadi kesalahan. Coba lagi.');
    }
  }

  /// Sign in existing user with email and password
  Future<UserCredential?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      debugPrint('✅ User signed in: ${credential.user?.uid}');
      return credential;
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ Sign in error: ${e.code} - ${e.message}');

      switch (e.code) {
        case 'user-not-found':
          throw Exception('Email tidak terdaftar. Silakan daftar dulu.');
        case 'wrong-password':
          throw Exception('Password salah. Coba lagi.');
        case 'invalid-email':
          throw Exception('Format email tidak valid.');
        case 'user-disabled':
          throw Exception('Akun Anda telah dinonaktifkan.');
        default:
          throw Exception('Login gagal: ${e.message}');
      }
    } catch (e) {
      debugPrint('❌ Unexpected error: $e');
      throw Exception('Terjadi kesalahan. Coba lagi.');
    }
  }

  /// Sign out current user
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      debugPrint('✅ User signed out');
    } catch (e) {
      debugPrint('❌ Sign out error: $e');
      throw Exception('Logout gagal. Coba lagi.');
    }
  }

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      debugPrint('✅ Password reset email sent to: $email');
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ Password reset error: ${e.code}');

      switch (e.code) {
        case 'user-not-found':
          throw Exception('Email tidak terdaftar.');
        case 'invalid-email':
          throw Exception('Format email tidak valid.');
        default:
          throw Exception('Gagal mengirim email: ${e.message}');
      }
    } catch (e) {
      debugPrint('❌ Unexpected error: $e');
      throw Exception('Terjadi kesalahan. Coba lagi.');
    }
  }

  /// Delete current user account
  Future<void> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('Tidak ada user yang login');
      }

      await user.delete();
      debugPrint('✅ User account deleted');
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ Delete account error: ${e.code}');

      if (e.code == 'requires-recent-login') {
        throw Exception('Silakan login ulang untuk menghapus akun.');
      }
      throw Exception('Gagal menghapus akun: ${e.message}');
    } catch (e) {
      debugPrint('❌ Unexpected error: $e');
      throw Exception('Terjadi kesalahan. Coba lagi.');
    }
  }
}
