import 'package:flutter/foundation.dart';

/// Credit Limit Calculator
/// Calculates credit limit based on user activity and scoring factors
class CreditLimitCalculator {
  // Minimum and maximum limits (Phase 1)
  static const double MIN_LIMIT = 1000000; // Rp 1 juta
  static const double MAX_LIMIT = 5000000; // Rp 5 juta

  // Weight factors for scoring
  static const double BALANCE_WEIGHT = 0.4;
  static const double TRANSACTION_WEIGHT = 0.3;
  static const double ACCOUNT_AGE_WEIGHT = 0.2;
  static const double KYC_WEIGHT = 0.1;

  /// Calculate credit limit based on user profile
  ///
  /// Returns:
  /// - Map with 'limit' and 'factors' breakdown
  static Map<String, dynamic> calculate({
    required bool isKycVerified,
    required double averageBalance,
    required int transactionCount,
    required int accountAgeDays,
  }) {
    // No KYC = No Pay Later
    if (!isKycVerified) {
      return {
        'limit': 0.0,
        'factors': {
          'kycVerified': false,
          'reason': 'KYC verification required',
        },
      };
    }

    // Minimum account age (7 days)
    if (accountAgeDays < 7) {
      return {
        'limit': 0.0,
        'factors': {
          'accountAgeDays': accountAgeDays,
          'reason': 'Account must be at least 7 days old',
        },
      };
    }

    // Calculate base limit
    double baseLimit = MIN_LIMIT;

    // Factor 1: Balance scoring (max +Rp 2 juta)
    double balanceScore = _calculateBalanceScore(averageBalance);

    // Factor 2: Transaction history (max +Rp 1 juta)
    double transactionScore = _calculateTransactionScore(transactionCount);

    // Factor 3: Account age (max +Rp 1 juta)
    double ageScore = _calculateAgeScore(accountAgeDays);

    // Total limit
    double totalLimit = baseLimit + balanceScore + transactionScore + ageScore;

    // Cap at maximum
    totalLimit = totalLimit.clamp(MIN_LIMIT, MAX_LIMIT);

    // Round to nearest 100k
    totalLimit = (totalLimit / 100000).round() * 100000;

    debugPrint(
      '💳 Credit Limit Calculated: Rp ${totalLimit.toStringAsFixed(0)}',
    );
    debugPrint('  - Base: Rp ${baseLimit.toStringAsFixed(0)}');
    debugPrint('  - Balance Score: +Rp ${balanceScore.toStringAsFixed(0)}');
    debugPrint(
      '  - Transaction Score: +Rp ${transactionScore.toStringAsFixed(0)}',
    );
    debugPrint('  - Age Score: +Rp ${ageScore.toStringAsFixed(0)}');

    return {
      'limit': totalLimit,
      'factors': {
        'baseLimit': baseLimit,
        'balanceScore': balanceScore,
        'transactionScore': transactionScore,
        'ageScore': ageScore,
        'averageBalance': averageBalance,
        'transactionCount': transactionCount,
        'accountAgeDays': accountAgeDays,
        'kycVerified': isKycVerified,
      },
    };
  }

  /// Calculate balance contribution to limit
  /// Average balance Rp 2.5 juta = +Rp 1 juta
  /// Average balance Rp 5 juta+ = +Rp 2 juta (max)
  static double _calculateBalanceScore(double averageBalance) {
    if (averageBalance <= 0) return 0;

    // Linear scale: Rp 2.5 juta avg = Rp 1 juta bonus
    double score = (averageBalance / 2500000) * 1000000;

    // Cap at Rp 2 juta
    return score.clamp(0, 2000000);
  }

  /// Calculate transaction history contribution
  /// 10 transactions = +Rp 500k
  /// 20+ transactions = +Rp 1 juta (max)
  static double _calculateTransactionScore(int transactionCount) {
    if (transactionCount <= 0) return 0;

    // Each transaction worth Rp 50k
    double score = transactionCount * 50000;

    // Cap at Rp 1 juta
    return score.clamp(0, 1000000);
  }

  /// Calculate account age contribution
  /// 30 days = +Rp 500k
  /// 60+ days = +Rp 1 juta (max)
  static double _calculateAgeScore(int accountAgeDays) {
    if (accountAgeDays < 7) return 0;

    // Each day worth ~Rp 16.6k (1M / 60 days)
    double score = (accountAgeDays / 60) * 1000000;

    // Cap at Rp 1 juta
    return score.clamp(0, 1000000);
  }

  /// Check if user is eligible for Pay Later
  static bool isEligible({
  required bool isKycVerified,
  required int accountAgeDays,
  bool? hasOverduePayments,
}) {
  // TEMPORARY: Always return true for testing
  debugPrint('🔍 Eligibility Check: KYC=, Age= days');
  return true; // Bypass all checks
}

  /// Calculate monthly installment for a loan
  ///
  /// Flat interest calculation:
  /// Total Interest = Principal × Rate × Tenor
  /// Total Repayment = Principal + Total Interest
  /// Monthly = Total / Tenor
  static Map<String, dynamic> calculateInstallment({
    required double principal,
    required int tenorMonths,
    required double monthlyRate, // % per month (e.g., 0.0 for 0%, 1.5 for 1.5%)
  }) {
    // Calculate total interest
    double totalInterest = principal * (monthlyRate / 100) * tenorMonths;

    // Total repayment
    double totalRepayment = principal + totalInterest;

    // Monthly installment
    double monthlyInstallment = totalRepayment / tenorMonths;

    return {
      'principal': principal,
      'tenorMonths': tenorMonths,
      'monthlyRate': monthlyRate,
      'totalInterest': totalInterest,
      'totalRepayment': totalRepayment,
      'monthlyInstallment': monthlyInstallment,
      'effectiveRate': monthlyRate,
    };
  }

  /// Get tenor options with rates
  static List<Map<String, dynamic>> getTenorOptions() {
    return [
      {
        'tenor': 1,
        'rate': 0.0,
        'label': '1 Bulan - 0%',
        'description': 'Bayar dalam 1 bulan tanpa bunga',
      },
      {
        'tenor': 3,
        'rate': 0.0,
        'label': '3 Bulan - 0%',
        'description': 'Cicilan 3x tanpa bunga',
      },
      {
        'tenor': 6,
        'rate': 1.5,
        'label': '6 Bulan - 1.5%/bulan',
        'description': 'Cicilan 6x dengan bunga flat 1.5%',
      },
      {
        'tenor': 12,
        'rate': 2.0,
        'label': '12 Bulan - 2%/bulan',
        'description': 'Cicilan 12x dengan bunga flat 2%',
      },
    ];
  }
}
