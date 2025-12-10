import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/foundation.dart';
import '../services/services.dart';

/// User Model
class User {
  final String id; // Firebase Auth UID
  final String fullName;
  final String email;
  final String phone;
  final String? ktpNumber;
  final bool isKycVerified;
  final DateTime createdAt;

  User({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    this.ktpNumber,
    this.isKycVerified = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Convert to JSON (for Firestore)
  Map<String, dynamic> toJson() => {
    'fullName': fullName,
    'email': email,
    'phone': phone,
    'ktpNumber': ktpNumber,
    'isKycVerified': isKycVerified,
    'createdAt': createdAt.toIso8601String(),
  };

  /// Create from Firestore document
  factory User.fromJson(String id, Map<String, dynamic> json) => User(
    id: id,
    fullName: json['fullName'] ?? '',
    email: json['email'] ?? '',
    phone: json['phone'] ?? '',
    ktpNumber: json['ktpNumber'],
    isKycVerified: json['isKycVerified'] ?? false,
    createdAt: json['createdAt'] != null
        ? DateTime.parse(json['createdAt'])
        : DateTime.now(),
  );

  /// Copy with modifications
  User copyWith({
    String? fullName,
    String? email,
    String? phone,
    String? ktpNumber,
    bool? isKycVerified,
  }) => User(
    id: id,
    fullName: fullName ?? this.fullName,
    email: email ?? this.email,
    phone: phone ?? this.phone,
    ktpNumber: ktpNumber ?? this.ktpNumber,
    isKycVerified: isKycVerified ?? this.isKycVerified,
    createdAt: createdAt,
  );
}

/// User Provider - Firebase Auth + Firestore
class UserProvider extends ChangeNotifier {
  final FirebaseAuthService _authService = FirebaseAuthService();
  final FirestoreService _firestoreService = FirestoreService();

  firebase_auth.User? _firebaseUser;
  User? _currentUser;
  String? _hashedPin;
  double _balance = 0.0;
  bool _isLoggedIn = false;
  bool _isLoading = true;

  StreamSubscription? _userStreamSubscription;
  StreamSubscription? _authStreamSubscription;

  // Getters
  User? get currentUser => _currentUser;
  String? get hashedPin => _hashedPin;
  double get balance => _balance;
  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;
  bool get hasUser => _currentUser != null;
  bool get hasPin => _hashedPin != null && _hashedPin!.isNotEmpty;
  String? get userId => _firebaseUser?.uid;

  /// Initialize provider - listen to Firebase auth state
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Listen to auth state changes
      _authStreamSubscription = _authService.authStateChanges().listen((
        firebaseUser,
      ) {
        _firebaseUser = firebaseUser;

        if (firebaseUser != null) {
          // User is signed in, load user data from Firestore
          _loadUserData(firebaseUser.uid);
        } else {
          // User is signed out
          _clearLocalData();
        }
      });

      // Get current user if already signed in
      _firebaseUser = _authService.getCurrentUser();
      if (_firebaseUser != null) {
        await _loadUserData(_firebaseUser!.uid);
      }
    } catch (e) {
      debugPrint('❌ Initialize error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Load user data from Firestore
  Future<void> _loadUserData(String userId) async {
    try {
      // Cancel previous subscription if exists
      await _userStreamSubscription?.cancel();

      // Listen to user document changes (realtime balance updates!)
      _userStreamSubscription = _firestoreService.userStream(userId).listen((
        userData,
      ) {
        if (userData != null) {
          _currentUser = User.fromJson(userId, userData);
          _balance = (userData['balance'] as num?)?.toDouble() ?? 0.0;
          _hashedPin = userData['pinHash'];
          _isLoggedIn = true;
          notifyListeners();
        }
      });
    } catch (e) {
      debugPrint('❌ Load user data error: $e');
    }
  }

  /// Register new user with Firebase
  Future<bool> registerUser({
    required String fullName,
    required String email,
    required String phone,
    required String password, // NEW: Firebase needs password
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      // 1. Create Firebase Auth account
      final credential = await _authService.signUp(
        email: email,
        password: password,
      );

      if (credential == null || credential.user == null) {
        throw Exception('Gagal membuat akun');
      }

      final userId = credential.user!.uid;

      // 2. Create user document in Firestore
      await _firestoreService.createUser(userId, {
        'fullName': fullName,
        'email': email,
        'phone': phone,
        'balance': 2500000.0, // Initial balance 2.5M
        'isKycVerified': false,
      });

      debugPrint('✅ User registered: $userId');

      // User data will be loaded automatically via auth state listener
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      debugPrint('❌ Register error: $e');
      rethrow; // Let UI handle the error message
    }
  }

  /// Set PIN (hashed) in Firestore
  Future<bool> setPin(String hashedPin) async {
    try {
      if (_firebaseUser == null) {
        throw Exception('User not authenticated');
      }

      await _firestoreService.updateUser(_firebaseUser!.uid, {
        'pinHash': hashedPin,
      });

      _hashedPin = hashedPin;
      notifyListeners();
      debugPrint('✅ PIN saved');
      return true;
    } catch (e) {
      debugPrint('❌ Set PIN error: $e');
      return false;
    }
  }

  /// Verify PIN from Firestore
  bool verifyPin(String hashedPinInput) {
    return _hashedPin == hashedPinInput;
  }

  /// Login with email and password (Firebase Auth)
  Future<bool> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final credential = await _authService.signIn(
        email: email,
        password: password,
      );

      if (credential == null || credential.user == null) {
        throw Exception('Login gagal');
      }

      // User data will be loaded automatically via auth state listener
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      debugPrint('❌ Login error: $e');
      rethrow;
    }
  }

  /// Login user (for PIN login after auth)
  void login() {
    _isLoggedIn = true;
    notifyListeners();
  }

  /// Logout user from Firebase
  Future<void> logout() async {
    try {
      await _authService.signOut();
      _clearLocalData();
      debugPrint('✅ User logged out');
    } catch (e) {
      debugPrint('❌ Logout error: $e');
      rethrow;
    }
  }

  /// Update KYC status in Firestore
  Future<void> setKycVerified(bool verified) async {
    if (_firebaseUser == null) return;

    try {
      await _firestoreService.updateUser(_firebaseUser!.uid, {
        'isKycVerified': verified,
      });
      debugPrint('✅ KYC status updated');
    } catch (e) {
      debugPrint('❌ Set KYC error: $e');
    }
  }

  /// Update balance in Firestore
  Future<bool> updateBalance(double amount) async {
    if (_firebaseUser == null) return false;

    final newBalance = _balance + amount;
    if (newBalance < 0) return false; // Prevent negative balance

    try {
      await _firestoreService.updateBalance(_firebaseUser!.uid, newBalance);
      // Balance will update automatically via stream
      return true;
    } catch (e) {
      debugPrint('❌ Update balance error: $e');
      return false;
    }
  }

  /// Deduct balance (for transfer)
  Future<bool> deductBalance(double amount) async {
    if (_firebaseUser == null) return false;
    if (_balance < amount) return false; // Insufficient balance

    try {
      await _firestoreService.deductBalance(_firebaseUser!.uid, amount);
      // Balance will update automatically via stream
      return true;
    } catch (e) {
      debugPrint('❌ Deduct balance error: $e');
      return false;
    }
  }

  /// Add balance (for top up/receive)
  Future<bool> addBalance(double amount) async {
    if (_firebaseUser == null) return false;

    try {
      await _firestoreService.addBalance(_firebaseUser!.uid, amount);
      // Balance will update automatically via stream
      return true;
    } catch (e) {
      debugPrint('❌ Add balance error: $e');
      return false;
    }
  }

  /// Clear local data on sign out
  void _clearLocalData() {
    _currentUser = null;
    _hashedPin = null;
    _balance = 0.0;
    _isLoggedIn = false;
    _firebaseUser = null;
    notifyListeners();
  }

  /// Clear all user data (logout + delete account)
  Future<void> clearAllData() async {
    try {
      await _authService.deleteAccount();
      _clearLocalData();
      debugPrint('✅ All data cleared');
    } catch (e) {
      debugPrint('❌ Clear data error: $e');
      rethrow;
    }
  }

  @override
  void dispose() {
    _userStreamSubscription?.cancel();
    _authStreamSubscription?.cancel();
    super.dispose();
  }
}
