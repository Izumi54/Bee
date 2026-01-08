import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/pay_later_models.dart';
import '../services/firestore_service.dart';
import '../utils/credit_limit_calculator.dart';
import 'user_provider.dart';

/// Pay Later Provider
/// Manages Pay Later activation status, credit limits, and loans
class PayLaterProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  // Stream subscriptions
  StreamSubscription? _payLaterSubscription;
  StreamSubscription? _loansSubscription;

  // State
  PayLaterActivation? _activation;
  List<Loan> _activeLoans = [];
  List<Loan> _loanHistory = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  PayLaterActivation? get activation => _activation;
  List<Loan> get activeLoans => _activeLoans;
  List<Loan> get loanHistory => _loanHistory;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Convenience getters
  bool get isActive => _activation?.isActive ?? false;
  bool get hasActiveLoans => _activeLoans.isNotEmpty;
  double get creditLimit => _activation?.creditLimit ?? 0.0;
  double get availableLimit => _activation?.availableLimit ?? 0.0;
  double get usedLimit => _activation?.usedLimit ?? 0.0;
  double get usedPercentage => _activation?.usedPercentage ?? 0.0;

  /// Initialize Pay Later provider with userId
  Future<void> initialize(String userId) async {
    try {
      debugPrint('🔄 Initializing PayLaterProvider for: $userId');

      // Cancel existing subscription
      await _payLaterSubscription?.cancel();

      // Listen to realtime updates
      _payLaterSubscription = _firestoreService
          .payLaterStream(userId)
          .listen(
            (data) {
              if (data != null) {
                _activation = PayLaterActivation.fromJson(data);
                debugPrint(
                  '✅ Pay Later status updated: ${_activation?.status.name}',
                );
              } else {
                _activation = null;
                debugPrint('⚠️ Pay Later not activated');
              }
              notifyListeners();
            },
            onError: (error) {
              debugPrint('❌ Pay Later stream error: $error');
              _error = error.toString();
              notifyListeners();
            },
          );

      // Listen to loans realtime
      await _loansSubscription?.cancel();
      _loansSubscription = _firestoreService
          .loanHistoryStream(userId)
          .listen(
            (loansData) {
              _loanHistory = loansData
                  .map((data) => Loan.fromJson(data['id'] as String, data))
                  .toList();
              _activeLoans = _loanHistory
                  .where(
                    (loan) =>
                        loan.status == LoanStatus.active ||
                        loan.status == LoanStatus.pending,
                  )
                  .toList();
              debugPrint(
                '✅ Loans updated: ${_loanHistory.length} total, ${_activeLoans.length} active',
              );
              notifyListeners();
            },
            onError: (error) {
              debugPrint('❌ Loans stream error: $error');
            },
          );
    } catch (e) {
      debugPrint('❌ Initialize Pay Later error: $e');
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Check if user is eligible for Pay Later
  bool checkEligibility(UserProvider userProvider) {
    return CreditLimitCalculator.isEligible(
      isKycVerified: userProvider.currentUser?.isKycVerified ?? false,
      accountAgeDays: _calculateAccountAge(userProvider.currentUser?.createdAt),
      hasOverduePayments: false, // TODO: Implement overdue check in Phase 2
    );
  }

  /// Calculate account age in days
  int _calculateAccountAge(DateTime? createdAt) {
    if (createdAt == null) return 0;
    return DateTime.now().difference(createdAt).inDays;
  }

  /// Activate Pay Later for user
  Future<void> activate({
    required String userId,
    required UserProvider userProvider,
    int? transactionCount,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Check eligibility
      if (!checkEligibility(userProvider)) {
        throw Exception('Tidak memenuhi syarat untuk mengaktifkan Pay Later');
      }

      // Calculate credit limit
      final user = userProvider.currentUser;
      final limitResult = CreditLimitCalculator.calculate(
        isKycVerified: user?.isKycVerified ?? false,
        averageBalance: userProvider.balance,
        transactionCount: transactionCount ?? 0,
        accountAgeDays: _calculateAccountAge(user?.createdAt),
      );

      final creditLimit = limitResult['limit'] as double;

      if (creditLimit == 0) {
        throw Exception(
          limitResult['factors']['reason'] ?? 'Limit tidak tersedia',
        );
      }

      // Activate in Firestore
      await _firestoreService.activatePayLater(
        userId,
        creditLimit: creditLimit,
        kycVerified: user?.isKycVerified ?? false,
        scoringFactors: limitResult['factors'] as Map<String, dynamic>?,
      );

      debugPrint('✅ Pay Later activated with limit: Rp $creditLimit');

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      debugPrint('❌ Activate Pay Later error: $e');
      rethrow;
    }
  }

  /// Recalculate and update credit limit
  Future<void> updateCreditLimit({
    required String userId,
    required UserProvider userProvider,
    int? transactionCount,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Recalculate limit
      final user = userProvider.currentUser;
      final limitResult = CreditLimitCalculator.calculate(
        isKycVerified: user?.isKycVerified ?? false,
        averageBalance: userProvider.balance,
        transactionCount: transactionCount ?? 0,
        accountAgeDays: _calculateAccountAge(user?.createdAt),
      );

      final newLimit = limitResult['limit'] as double;

      // Update in Firestore
      await _firestoreService.updateCreditLimit(
        userId,
        newLimit,
        scoringFactors: limitResult['factors'] as Map<String, dynamic>?,
      );

      debugPrint('✅ Credit limit updated to: Rp $newLimit');

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      debugPrint('❌ Update limit error: $e');
      rethrow;
    }
  }

  /// Suspend Pay Later (for overdue or violations)
  Future<void> suspend(String userId, {String? reason}) async {
    try {
      await _firestoreService.suspendPayLater(userId, reason: reason);
      debugPrint('⚠️ Pay Later suspended');
    } catch (e) {
      debugPrint('❌ Suspend error: $e');
      rethrow;
    }
  }

  /// Reactivate suspended Pay Later
  Future<void> reactivate(String userId) async {
    try {
      await _firestoreService.reactivatePayLater(userId);
      debugPrint('✅ Pay Later reactivated');
    } catch (e) {
      debugPrint('❌ Reactivate error: $e');
      rethrow;
    }
  }

  /// Calculate installment for given amount and tenor
  Map<String, dynamic> calculateInstallment({
    required double amount,
    required int tenorMonths,
  }) {
    // Get rate for tenor
    final tenorOptions = CreditLimitCalculator.getTenorOptions();
    final tenorOption = tenorOptions.firstWhere(
      (option) => option['tenor'] == tenorMonths,
      orElse: () => tenorOptions.first,
    );

    final rate = tenorOption['rate'] as double;

    return CreditLimitCalculator.calculateInstallment(
      principal: amount,
      tenorMonths: tenorMonths,
      monthlyRate: rate,
    );
  }

  /// Get available tenor options
  List<Map<String, dynamic>> getTenorOptions() {
    return CreditLimitCalculator.getTenorOptions();
  }

  /// Check if user can borrow amount
  bool canBorrow(double amount) {
    return _activation?.canBorrow(amount) ?? false;
  }

  /// Create a new Pay Later loan
  Future<String> createLoan({
    required String userId,
    required double amount,
    required int tenorMonths,
    String? purpose,
    String? recipientId,
    String? recipientName,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Check if can borrow
      if (!canBorrow(amount)) {
        throw Exception('Tidak dapat meminjam jumlah ini');
      }

      // Calculate installment
      final calculation = calculateInstallment(
        amount: amount,
        tenorMonths: tenorMonths,
      );

      // Calculate due date (1 month from now)
      final dueDate = DateTime.now().add(Duration(days: 30 * tenorMonths));

      // Create loan data
      final loanData = {
        'amount': amount,
        'tenorMonths': tenorMonths,
        'interestRate': calculation['interestRate'],
        'totalRepayment': calculation['totalRepayment'],
        'monthlyInstallment': calculation['monthlyInstallment'],
        'status': 'active',
        'dueDate': dueDate,
        'remainingAmount': calculation['totalRepayment'],
        'purpose': purpose,
        'recipientId': recipientId,
        'recipientName': recipientName,
      };

      // Create loan in Firestore
      final loanId = await _firestoreService.createLoan(userId, loanData);

      // Update Pay Later used limit
      await _firestoreService.updatePayLaterUsage(
        userId,
        amount: amount,
        isDeduction: true,
      );

      debugPrint(
        '✅ Loan created: $loanId - Rp $amount for $tenorMonths months',
      );

      _isLoading = false;
      notifyListeners();

      return loanId;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      debugPrint('❌ Create loan error: $e');
      rethrow;
    }
  }

  @override
  void dispose() {
    _payLaterSubscription?.cancel();
    _loansSubscription?.cancel();
    super.dispose();
  }
}
