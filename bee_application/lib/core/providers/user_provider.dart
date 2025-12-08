import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// User Model
class User {
  final String fullName;
  final String email;
  final String phone;
  final String? ktpNumber;
  final bool isKycVerified;
  final DateTime createdAt;

  User({
    required this.fullName,
    required this.email,
    required this.phone,
    this.ktpNumber,
    this.isKycVerified = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Convert to JSON
  Map<String, dynamic> toJson() => {
    'fullName': fullName,
    'email': email,
    'phone': phone,
    'ktpNumber': ktpNumber,
    'isKycVerified': isKycVerified,
    'createdAt': createdAt.toIso8601String(),
  };

  /// Create from JSON
  factory User.fromJson(Map<String, dynamic> json) => User(
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
    fullName: fullName ?? this.fullName,
    email: email ?? this.email,
    phone: phone ?? this.phone,
    ktpNumber: ktpNumber ?? this.ktpNumber,
    isKycVerified: isKycVerified ?? this.isKycVerified,
    createdAt: createdAt,
  );
}

/// User Provider - Manages user state and persistence
class UserProvider extends ChangeNotifier {
  static const String _userKey = 'bee_user_data';
  static const String _pinKey = 'bee_user_pin';
  static const String _balanceKey = 'bee_user_balance';

  User? _currentUser;
  String? _hashedPin;
  double _balance = 0.0;
  bool _isLoggedIn = false;
  bool _isLoading = true;

  // Getters
  User? get currentUser => _currentUser;
  String? get hashedPin => _hashedPin;
  double get balance => _balance;
  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;
  bool get hasUser => _currentUser != null;
  bool get hasPin => _hashedPin != null && _hashedPin!.isNotEmpty;

  /// Initialize provider - load data from storage
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();

      // Load user data
      final userJson = prefs.getString(_userKey);
      if (userJson != null) {
        _currentUser = User.fromJson(jsonDecode(userJson));
      }

      // Load PIN
      _hashedPin = prefs.getString(_pinKey);

      // Load balance
      _balance = prefs.getDouble(_balanceKey) ?? 2500000.0; // Default 2.5jt
    } catch (e) {
      debugPrint('Error loading user data: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Register new user
  Future<bool> registerUser({
    required String fullName,
    required String email,
    required String phone,
  }) async {
    try {
      _currentUser = User(fullName: fullName, email: email, phone: phone);

      // Set initial balance for new users
      _balance = 2500000.0;

      await _saveUser();
      await _saveBalance();

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error registering user: $e');
      return false;
    }
  }

  /// Set PIN (hashed)
  Future<bool> setPin(String hashedPin) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_pinKey, hashedPin);
      _hashedPin = hashedPin;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error saving PIN: $e');
      return false;
    }
  }

  /// Verify PIN
  bool verifyPin(String hashedPinInput) {
    return _hashedPin == hashedPinInput;
  }

  /// Login user
  void login() {
    _isLoggedIn = true;
    notifyListeners();
  }

  /// Logout user
  void logout() {
    _isLoggedIn = false;
    notifyListeners();
  }

  /// Update KYC status
  Future<void> setKycVerified(bool verified) async {
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(isKycVerified: verified);
      await _saveUser();
      notifyListeners();
    }
  }

  /// Update balance
  Future<bool> updateBalance(double amount) async {
    final newBalance = _balance + amount;
    if (newBalance < 0) return false; // Prevent negative balance

    _balance = newBalance;
    await _saveBalance();
    notifyListeners();
    return true;
  }

  /// Deduct balance (for transfer)
  Future<bool> deductBalance(double amount) async {
    if (_balance < amount) return false; // Insufficient balance
    return updateBalance(-amount);
  }

  /// Add balance (for top up/receive)
  Future<bool> addBalance(double amount) async {
    return updateBalance(amount);
  }

  /// Save user to storage
  Future<void> _saveUser() async {
    if (_currentUser == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(_currentUser!.toJson()));
  }

  /// Save balance to storage
  Future<void> _saveBalance() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_balanceKey, _balance);
  }

  /// Clear all user data (for testing/reset)
  Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
    await prefs.remove(_pinKey);
    await prefs.remove(_balanceKey);

    _currentUser = null;
    _hashedPin = null;
    _balance = 0.0;
    _isLoggedIn = false;

    notifyListeners();
  }
}
