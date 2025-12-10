import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../services/services.dart';

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
  final String? senderId;
  final String? receiverId;
  final DateTime createdAt;

  Transaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.description,
    this.recipientName,
    this.recipientAccount,
    this.senderId,
    this.receiverId,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Is this an incoming transaction (positive balance)
  bool get isIncoming =>
      type == TransactionType.receive || type == TransactionType.topUp;

  /// Convert to JSON (for Firestore)
  Map<String, dynamic> toJson() => {
    'type': type.name, // Use name instead of index for Firestore
    'amount': amount,
    'description': description,
    'recipientName': recipientName,
    'recipientAccount': recipientAccount,
    'senderId': senderId,
    'receiverId': receiverId,
    'createdAt': createdAt.toIso8601String(),
  };

  /// Create from Firestore document
  factory Transaction.fromJson(String id, Map<String, dynamic> json) {
    // Parse type from string name
    TransactionType type;
    try {
      type = TransactionType.values.byName(json['type'] ?? 'transfer');
    } catch (e) {
      // Fallback for old numeric format
      type = TransactionType.values[json['type'] ?? 0];
    }

    // Handle Timestamp from Firestore
    DateTime createdAt;
    if (json['createdAt'] is Timestamp) {
      createdAt = (json['createdAt'] as Timestamp).toDate();
    } else if (json['createdAt'] is String) {
      createdAt = DateTime.parse(json['createdAt']);
    } else {
      createdAt = DateTime.now();
    }

    return Transaction(
      id: id,
      type: type,
      amount: (json['amount'] ?? 0).toDouble(),
      description: json['description'] ?? '',
      recipientName: json['recipientName'],
      recipientAccount: json['recipientAccount'],
      senderId: json['senderId'],
      receiverId: json['receiverId'],
      createdAt: createdAt,
    );
  }
}

/// Transaction Provider - Firebase Firestore with realtime updates
class TransactionProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<Transaction> _transactions = [];
  bool _isLoading = true;
  String? _userId;

  StreamSubscription? _transactionSubscription;

  // Getters
  List<Transaction> get transactions => _transactions;
  bool get isLoading => _isLoading;

  /// Get recent transactions (for home screen)
  List<Transaction> get recentTransactions => _transactions.take(5).toList();

  /// Initialize provider - listen to Firestore transactions
  Future<void> initialize(String userId) async {
    _userId = userId;
    _isLoading = true;
    notifyListeners();

    try {
      // Cancel previous subscription
      await _transactionSubscription?.cancel();

      // Listen to transactions stream (realtime updates!)
      _transactionSubscription = _firestoreService
          .transactionsStream(userId)
          .listen(
            (transactionMaps) {
              _transactions = transactionMaps
                  .map((map) => Transaction.fromJson(map['id'], map))
                  .toList();
              _isLoading = false;
              notifyListeners();
            },
            onError: (error) {
              debugPrint('❌ Transaction stream error: $error');
              _isLoading = false;
              notifyListeners();
            },
          );
    } catch (e) {
      debugPrint('❌ Initialize transactions error: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Add transfer transaction (outgoing)
  Future<bool> addTransfer({
    required double amount,
    required String recipientName,
    required String recipientAccount,
  }) async {
    if (_userId == null) {
      debugPrint('❌ User ID is null');
      return false;
    }

    try {
      await _firestoreService.addTransaction({
        'senderId': _userId,
        'type': TransactionType.transfer.name,
        'amount': amount,
        'description': 'Transfer ke $recipientName',
        'recipientName': recipientName,
        'recipientAccount': recipientAccount,
      });

      debugPrint('✅ Transfer transaction added');
      return true;
    } catch (e) {
      debugPrint('❌ Add transfer error: $e');
      return false;
    }
  }

  /// Add top up transaction
  Future<bool> addTopUp({required double amount}) async {
    if (_userId == null) {
      debugPrint('❌ User ID is null');
      return false;
    }

    try {
      await _firestoreService.addTransaction({
        'senderId': _userId,
        'type': TransactionType.topUp.name,
        'amount': amount,
        'description': 'Top Up Saldo',
      });

      debugPrint('✅ Top up transaction added');
      return true;
    } catch (e) {
      debugPrint('❌ Add top up error: $e');
      return false;
    }
  }

  /// Add payment transaction (for QRIS)
  Future<bool> addPayment({
    required double amount,
    required String merchantName,
  }) async {
    if (_userId == null) {
      debugPrint('❌ User ID is null');
      return false;
    }

    try {
      await _firestoreService.addTransaction({
        'senderId': _userId,
        'type': TransactionType.payment.name,
        'amount': amount,
        'description': 'Pembayaran ke $merchantName',
        'recipientName': merchantName,
      });

      debugPrint('✅ Payment transaction added');
      return true;
    } catch (e) {
      debugPrint('❌ Add payment error: $e');
      return false;
    }
  }

  /// Transfer money to another user (atomic operation)
  /// This updates both sender and receiver balances + creates transactions
  Future<bool> transferToUser({
    required String receiverUserId,
    required double amount,
    required String recipientName,
    required String recipientAccount,
  }) async {
    if (_userId == null) {
      debugPrint('❌ User ID is null');
      return false;
    }

    try {
      await _firestoreService.transferMoney(
        senderId: _userId!,
        receiverId: receiverUserId,
        amount: amount,
        transactionData: {
          'amount': amount,
          'description': 'Transfer ke $recipientName',
          'recipientName': recipientName,
          'recipientAccount': recipientAccount,
        },
      );

      debugPrint('✅ Transfer to user completed');
      return true;
    } catch (e) {
      debugPrint('❌ Transfer to user error: $e');
      return false;
    }
  }

  /// Clear all transactions (for testing)
  Future<void> clearAllTransactions() async {
    // We don't delete from Firestore, just clear local list
    _transactions = [];
    notifyListeners();
  }

  @override
  void dispose() {
    _transactionSubscription?.cancel();
    super.dispose();
  }
}
