import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../services/services.dart';

/// Contact Model
class Contact {
  final String id;
  final String name;
  final String accountNumber;
  final DateTime createdAt;

  Contact({
    required this.id,
    required this.name,
    required this.accountNumber,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Convert to JSON (for Firestore)
  Map<String, dynamic> toJson() => {
    'name': name,
    'accountNumber': accountNumber,
    'createdAt': createdAt.toIso8601String(),
  };

  /// Create from Firestore document
  factory Contact.fromJson(String id, Map<String, dynamic> json) {
    // Handle Timestamp from Firestore
    DateTime createdAt;
    if (json['createdAt'] is Timestamp) {
      createdAt = (json['createdAt'] as Timestamp).toDate();
    } else if (json['createdAt'] is String) {
      createdAt = DateTime.parse(json['createdAt']);
    } else {
      createdAt = DateTime.now();
    }

    return Contact(
      id: id,
      name: json['name'] ?? '',
      accountNumber: json['accountNumber'] ?? '',
      createdAt: createdAt,
    );
  }

  /// Convert to Map<String, String> for backward compatibility
  Map<String, String> toMap() => {'name': name, 'accountNumber': accountNumber};
}

/// Contact Provider - Firebase Firestore with realtime updates
class ContactProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<Contact> _contacts = [];
  List<Contact> _filteredContacts = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String? _userId;

  StreamSubscription? _contactSubscription;

  // Getters
  List<Contact> get contacts => _contacts;
  List<Contact> get filteredContacts => _filteredContacts;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;

  /// Initialize provider - listen to Firestore contacts
  Future<void> initialize(String userId) async {
    _userId = userId;
    _isLoading = true;
    notifyListeners();

    try {
      // Cancel previous subscription
      await _contactSubscription?.cancel();

      // Listen to contacts stream (realtime updates!)
      _contactSubscription = _firestoreService
          .contactsStream(userId)
          .listen(
            (contactMaps) {
              _contacts = contactMaps
                  .map((map) => Contact.fromJson(map['id'], map))
                  .toList();
              _applySearchFilter();
              _isLoading = false;
              notifyListeners();
            },
            onError: (error) {
              debugPrint('❌ Contact stream error: $error');
              _isLoading = false;
              notifyListeners();
            },
          );
    } catch (e) {
      debugPrint('❌ Initialize contacts error: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Add new contact to Firestore
  Future<bool> addContact({
    required String name,
    required String accountNumber,
  }) async {
    if (_userId == null) {
      debugPrint('❌ User ID is null');
      return false;
    }

    // Validate
    if (name.trim().isEmpty || accountNumber.trim().isEmpty) {
      return false;
    }

    // Check duplicate account number
    final exists = _contacts.any(
      (c) => c.accountNumber == accountNumber.trim(),
    );
    if (exists) {
      return false;
    }

    try {
      await _firestoreService.addContact(_userId!, {
        'name': name.trim(),
        'accountNumber': accountNumber.trim(),
      });

      debugPrint('✅ Contact added');
      return true;
      // Contact will be added to list automatically via stream
    } catch (e) {
      debugPrint('❌ Add contact error: $e');
      return false;
    }
  }

  /// Delete contact from Firestore
  Future<bool> deleteContact(String contactId) async {
    if (_userId == null) {
      debugPrint('❌ User ID is null');
      return false;
    }

    try {
      await _firestoreService.deleteContact(_userId!, contactId);
      debugPrint('✅ Contact deleted');
      return true;
      // Contact will be removed from list automatically via stream
    } catch (e) {
      debugPrint('❌ Delete contact error: $e');
      return false;
    }
  }

  /// Search contacts with debounce-friendly approach
  void searchContacts(String query) {
    _searchQuery = query;
    _applySearchFilter();
    notifyListeners();
  }

  /// Apply search filter based on current query
  void _applySearchFilter() {
    if (_searchQuery.isEmpty) {
      _filteredContacts = List.from(_contacts);
    } else {
      final queryLower = _searchQuery.toLowerCase();
      _filteredContacts = _contacts.where((contact) {
        final nameLower = contact.name.toLowerCase();
        final accountLower = contact.accountNumber.toLowerCase();
        return nameLower.contains(queryLower) ||
            accountLower.contains(queryLower);
      }).toList();
    }
  }

  /// Clear search
  void clearSearch() {
    _searchQuery = '';
    _filteredContacts = List.from(_contacts);
    notifyListeners();
  }

  /// Get contact by ID
  Contact? getContactById(String id) {
    try {
      return _contacts.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Clear all contacts (local only, doesn't delete from Firestore)
  Future<void> clearAllContacts() async {
    _contacts = [];
    _filteredContacts = [];
    notifyListeners();
  }

  @override
  void dispose() {
    _contactSubscription?.cancel();
    super.dispose();
  }
}
