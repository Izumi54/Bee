import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Contact Model
class Contact {
  final String id;
  final String name;
  final String accountNumber;
  final DateTime createdAt;

  Contact({
    String? id,
    required this.name,
    required this.accountNumber,
    DateTime? createdAt,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
       createdAt = createdAt ?? DateTime.now();

  /// Convert to JSON
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'accountNumber': accountNumber,
    'createdAt': createdAt.toIso8601String(),
  };

  /// Create from JSON
  factory Contact.fromJson(Map<String, dynamic> json) => Contact(
    id: json['id'],
    name: json['name'] ?? '',
    accountNumber: json['accountNumber'] ?? '',
    createdAt: json['createdAt'] != null
        ? DateTime.parse(json['createdAt'])
        : DateTime.now(),
  );

  /// Convert to Map<String, String> for backward compatibility
  Map<String, String> toMap() => {'name': name, 'accountNumber': accountNumber};
}

/// Contact Provider - Manages contacts state and persistence
class ContactProvider extends ChangeNotifier {
  static const String _contactsKey = 'bee_contacts';

  List<Contact> _contacts = [];
  List<Contact> _filteredContacts = [];
  bool _isLoading = true;
  String _searchQuery = '';

  // Getters
  List<Contact> get contacts => _contacts;
  List<Contact> get filteredContacts => _filteredContacts;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;

  /// Initialize provider - load contacts from storage
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final contactsJson = prefs.getString(_contactsKey);

      if (contactsJson != null) {
        final List<dynamic> decoded = jsonDecode(contactsJson);
        _contacts = decoded.map((e) => Contact.fromJson(e)).toList();
      } else {
        // Load default contacts if none exist
        _contacts = _getDefaultContacts();
        await _saveContacts();
      }

      _filteredContacts = List.from(_contacts);
    } catch (e) {
      debugPrint('Error loading contacts: $e');
      _contacts = _getDefaultContacts();
      _filteredContacts = List.from(_contacts);
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Get default contacts (mock data)
  List<Contact> _getDefaultContacts() {
    return [
      Contact(name: 'Budi Santoso', accountNumber: '1234567890'),
      Contact(name: 'Siti Nurhaliza', accountNumber: '0987654321'),
      Contact(name: 'Ahmad Dahlan', accountNumber: '1122334455'),
      Contact(name: 'Dewi Lestari', accountNumber: '5544332211'),
      Contact(name: 'Rina Wijaya', accountNumber: '6677889900'),
      Contact(name: 'Andi Pratama', accountNumber: '9988776655'),
      Contact(name: 'Fitri Handayani', accountNumber: '1231231234'),
      Contact(name: 'Joko Widodo', accountNumber: '4564564567'),
    ];
  }

  /// Add new contact
  Future<bool> addContact({
    required String name,
    required String accountNumber,
  }) async {
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
      final newContact = Contact(
        name: name.trim(),
        accountNumber: accountNumber.trim(),
      );

      _contacts.insert(0, newContact); // Add to top
      await _saveContacts();

      // Re-apply search filter
      _applySearchFilter();
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error adding contact: $e');
      return false;
    }
  }

  /// Delete contact
  Future<bool> deleteContact(String contactId) async {
    try {
      _contacts.removeWhere((c) => c.id == contactId);
      await _saveContacts();
      _applySearchFilter();
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error deleting contact: $e');
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

  /// Save contacts to storage
  Future<void> _saveContacts() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = _contacts.map((c) => c.toJson()).toList();
    await prefs.setString(_contactsKey, jsonEncode(jsonList));
  }

  /// Get contact by ID
  Contact? getContactById(String id) {
    try {
      return _contacts.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Clear all contacts (for testing)
  Future<void> clearAllContacts() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_contactsKey);
    _contacts = [];
    _filteredContacts = [];
    notifyListeners();
  }
}
