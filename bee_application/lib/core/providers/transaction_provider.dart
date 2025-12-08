import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Transaction Type
enum TransactionType { transfer, receive, topUp, payment }

/// Transaction Model
class Transaction {
  final String id;
  final TransactionType type;
  final double amount;
  final String description;
  final String? recipientName;
  final String? recipientAccount;
  final DateTime createdAt;

  Transaction({
    String? id,
    required this.type,
    required this.amount,
    required this.description,
    this.recipientName,
    this.recipientAccount,
    DateTime? createdAt,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
       createdAt = createdAt ?? DateTime.now();

  /// Is this an incoming transaction (positive balance)
  bool get isIncoming =>
      type == TransactionType.receive || type == TransactionType.topUp;

  /// Convert to JSON
  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.index,
    'amount': amount,
    'description': description,
    'recipientName': recipientName,
    'recipientAccount': recipientAccount,
    'createdAt': createdAt.toIso8601String(),
  };

  /// Create from JSON
  factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
    id: json['id'],
    type: TransactionType.values[json['type'] ?? 0],
    amount: (json['amount'] ?? 0).toDouble(),
    description: json['description'] ?? '',
    recipientName: json['recipientName'],
    recipientAccount: json['recipientAccount'],
    createdAt: json['createdAt'] != null
        ? DateTime.parse(json['createdAt'])
        : DateTime.now(),
  );
}

/// Transaction Provider - Manages transaction history
class TransactionProvider extends ChangeNotifier {
  static const String _transactionsKey = 'bee_transactions';
  static const int _maxTransactions = 100; // Keep last 100 transactions

  List<Transaction> _transactions = [];
  bool _isLoading = true;

  // Getters
  List<Transaction> get transactions => _transactions;
  bool get isLoading => _isLoading;

  /// Get recent transactions (for home screen)
  List<Transaction> get recentTransactions => _transactions.take(5).toList();

  /// Initialize provider - load transactions from storage
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final transactionsJson = prefs.getString(_transactionsKey);

      if (transactionsJson != null) {
        final List<dynamic> decoded = jsonDecode(transactionsJson);
        _transactions = decoded.map((e) => Transaction.fromJson(e)).toList();
      }
    } catch (e) {
      debugPrint('Error loading transactions: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Add new transaction
  Future<bool> addTransaction({
    required TransactionType type,
    required double amount,
    required String description,
    String? recipientName,
    String? recipientAccount,
  }) async {
    try {
      final transaction = Transaction(
        type: type,
        amount: amount,
        description: description,
        recipientName: recipientName,
        recipientAccount: recipientAccount,
      );

      _transactions.insert(0, transaction); // Add to top

      // Keep only last N transactions
      if (_transactions.length > _maxTransactions) {
        _transactions = _transactions.take(_maxTransactions).toList();
      }

      await _saveTransactions();
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error adding transaction: $e');
      return false;
    }
  }

  /// Add transfer transaction (convenience method)
  Future<bool> addTransfer({
    required double amount,
    required String recipientName,
    required String recipientAccount,
  }) async {
    return addTransaction(
      type: TransactionType.transfer,
      amount: amount,
      description: 'Transfer ke $recipientName',
      recipientName: recipientName,
      recipientAccount: recipientAccount,
    );
  }

  /// Add top up transaction (convenience method)
  Future<bool> addTopUp({required double amount}) async {
    return addTransaction(
      type: TransactionType.topUp,
      amount: amount,
      description: 'Top Up Saldo',
    );
  }

  /// Save transactions to storage
  Future<void> _saveTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = _transactions.map((t) => t.toJson()).toList();
    await prefs.setString(_transactionsKey, jsonEncode(jsonList));
  }

  /// Clear all transactions (for testing)
  Future<void> clearAllTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_transactionsKey);
    _transactions = [];
    notifyListeners();
  }
}
