import 'package:cloud_firestore/cloud_firestore.dart';

/// Pay Later Activation Status
enum PayLaterStatus { inactive, active, suspended }

/// Pay Later Activation Model
/// Represents user's Pay Later activation status and credit limit
class PayLaterActivation {
  final PayLaterStatus status;
  final bool kycVerified;
  final DateTime? activatedAt;
  final double creditLimit;
  final double availableLimit;
  final double usedLimit;
  final DateTime lastUpdated;
  final Map<String, dynamic>? scoringFactors;

  PayLaterActivation({
    required this.status,
    required this.kycVerified,
    this.activatedAt,
    required this.creditLimit,
    required this.availableLimit,
    required this.usedLimit,
    required this.lastUpdated,
    this.scoringFactors,
  });

  /// Create from Firestore document
  factory PayLaterActivation.fromJson(Map<String, dynamic> json) {
    return PayLaterActivation(
      status: _parseStatus(json['status'] as String?),
      kycVerified: json['kycVerified'] as bool? ?? false,
      activatedAt: _parseDateTime(json['activatedAt']),
      creditLimit: (json['creditLimit'] as num?)?.toDouble() ?? 0.0,
      availableLimit: (json['availableLimit'] as num?)?.toDouble() ?? 0.0,
      usedLimit: (json['usedLimit'] as num?)?.toDouble() ?? 0.0,
      lastUpdated: _parseDateTime(json['lastUpdated']) ?? DateTime.now(),
      scoringFactors: json['scoringFactors'] as Map<String, dynamic>?,
    );
  }

  /// Convert to Firestore document
  Map<String, dynamic> toJson() {
    return {
      'status': status.name,
      'kycVerified': kycVerified,
      'activatedAt': activatedAt != null
          ? Timestamp.fromDate(activatedAt!)
          : null,
      'creditLimit': creditLimit,
      'availableLimit': availableLimit,
      'usedLimit': usedLimit,
      'lastUpdated': Timestamp.fromDate(lastUpdated),
      'scoringFactors': scoringFactors,
    };
  }

  /// Helper: Parse status from string
  static PayLaterStatus _parseStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'active':
        return PayLaterStatus.active;
      case 'suspended':
        return PayLaterStatus.suspended;
      default:
        return PayLaterStatus.inactive;
    }
  }

  /// Helper: Parse DateTime from Firestore Timestamp or String
  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.parse(value);
    return null;
  }

  /// Copy with modifications
  PayLaterActivation copyWith({
    PayLaterStatus? status,
    bool? kycVerified,
    DateTime? activatedAt,
    double? creditLimit,
    double? availableLimit,
    double? usedLimit,
    DateTime? lastUpdated,
    Map<String, dynamic>? scoringFactors,
  }) {
    return PayLaterActivation(
      status: status ?? this.status,
      kycVerified: kycVerified ?? this.kycVerified,
      activatedAt: activatedAt ?? this.activatedAt,
      creditLimit: creditLimit ?? this.creditLimit,
      availableLimit: availableLimit ?? this.availableLimit,
      usedLimit: usedLimit ?? this.usedLimit,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      scoringFactors: scoringFactors ?? this.scoringFactors,
    );
  }

  /// Check if Pay Later is active and usable
  bool get isActive => status == PayLaterStatus.active;

  /// Check if user can borrow
  bool canBorrow(double amount) {
    return isActive &&
        kycVerified &&
        amount <= availableLimit &&
        amount >= 100000; // Min Rp 100k
  }

  /// Get used percentage (0-100)
  double get usedPercentage {
    if (creditLimit == 0) return 0;
    return (usedLimit / creditLimit * 100).clamp(0, 100);
  }
}

/// Loan Status
enum LoanStatus { pending, active, paid, overdue, cancelled }

/// Loan Model (for Phase 2+)
/// Represents a single Pay Later loan/borrowing
class Loan {
  final String id;
  final double amount;
  final int tenorMonths;
  final double interestRate;
  final double totalRepayment;
  final double monthlyInstallment;
  final LoanStatus status;
  final DateTime createdAt;
  final DateTime dueDate;
  final double remainingAmount;
  final String? purpose; // 'transfer', 'payment', etc.
  final String? recipientId;
  final String? recipientName;

  Loan({
    required this.id,
    required this.amount,
    required this.tenorMonths,
    required this.interestRate,
    required this.totalRepayment,
    required this.monthlyInstallment,
    required this.status,
    required this.createdAt,
    required this.dueDate,
    required this.remainingAmount,
    this.purpose,
    this.recipientId,
    this.recipientName,
  });

  /// Create from Firestore document
  factory Loan.fromJson(String id, Map<String, dynamic> json) {
    return Loan(
      id: id,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      tenorMonths: json['tenorMonths'] as int? ?? 1,
      interestRate: (json['interestRate'] as num?)?.toDouble() ?? 0.0,
      totalRepayment: (json['totalRepayment'] as num?)?.toDouble() ?? 0.0,
      monthlyInstallment:
          (json['monthlyInstallment'] as num?)?.toDouble() ?? 0.0,
      status: _parseStatus(json['status'] as String?),
      createdAt: _parseDateTime(json['createdAt']) ?? DateTime.now(),
      dueDate: _parseDateTime(json['dueDate']) ?? DateTime.now(),
      remainingAmount: (json['remainingAmount'] as num?)?.toDouble() ?? 0.0,
      purpose: json['purpose'] as String?,
      recipientId: json['recipientId'] as String?,
      recipientName: json['recipientName'] as String?,
    );
  }

  /// Convert to Firestore document
  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'tenorMonths': tenorMonths,
      'interestRate': interestRate,
      'totalRepayment': totalRepayment,
      'monthlyInstallment': monthlyInstallment,
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'dueDate': Timestamp.fromDate(dueDate),
      'remainingAmount': remainingAmount,
      'purpose': purpose,
      'recipientId': recipientId,
      'recipientName': recipientName,
    };
  }

  /// Helper: Parse status
  static LoanStatus _parseStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending':
        return LoanStatus.pending;
      case 'active':
        return LoanStatus.active;
      case 'paid':
        return LoanStatus.paid;
      case 'overdue':
        return LoanStatus.overdue;
      case 'cancelled':
        return LoanStatus.cancelled;
      default:
        return LoanStatus.pending;
    }
  }

  /// Helper: Parse DateTime
  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.parse(value);
    return null;
  }

  /// Check if loan is overdue
  bool get isOverdue {
    return status == LoanStatus.overdue ||
        (status == LoanStatus.active && DateTime.now().isAfter(dueDate));
  }

  /// Check if fully paid
  bool get isPaid => status == LoanStatus.paid && remainingAmount == 0;

  /// Get days until due (negative if overdue)
  int get daysUntilDue {
    return dueDate.difference(DateTime.now()).inDays;
  }
}

/// Installment Model (for detailed payment schedule)
class Installment {
  final int installmentNumber;
  final double amount;
  final DateTime dueDate;
  final String status; // 'pending', 'paid', 'overdue'
  final DateTime? paidAt;

  Installment({
    required this.installmentNumber,
    required this.amount,
    required this.dueDate,
    required this.status,
    this.paidAt,
  });

  factory Installment.fromJson(Map<String, dynamic> json) {
    return Installment(
      installmentNumber: json['installmentNumber'] as int? ?? 1,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      dueDate: _parseDateTime(json['dueDate']) ?? DateTime.now(),
      status: json['status'] as String? ?? 'pending',
      paidAt: _parseDateTime(json['paidAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'installmentNumber': installmentNumber,
      'amount': amount,
      'dueDate': Timestamp.fromDate(dueDate),
      'status': status,
      'paidAt': paidAt != null ? Timestamp.fromDate(paidAt!) : null,
    };
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.parse(value);
    return null;
  }

  bool get isPaid => status == 'paid';
  bool get isOverdue => status == 'overdue';
}
