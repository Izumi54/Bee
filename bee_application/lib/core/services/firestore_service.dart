import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Firestore Database Service
/// Handles all database operations for users, transactions, and contacts
class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection references
  CollectionReference get _users => _firestore.collection('users');
  CollectionReference get _transactions =>
      _firestore.collection('transactions');

  // ========== USER OPERATIONS ==========

  /// Create new user document
  Future<void> createUser(String userId, Map<String, dynamic> userData) async {
    try {
      await _users.doc(userId).set({
        ...userData,
        'createdAt': FieldValue.serverTimestamp(),
      });
      debugPrint('✅ User created: $userId');
    } catch (e) {
      debugPrint('❌ Create user error: $e');
      throw Exception('Gagal membuat profil pengguna');
    }
  }

  /// Get user document
  Future<Map<String, dynamic>?> getUser(String userId) async {
    try {
      final doc = await _users.doc(userId).get();
      if (!doc.exists) {
        debugPrint('⚠️ User not found: $userId');
        return null;
      }
      return doc.data() as Map<String, dynamic>?;
    } catch (e) {
      debugPrint('❌ Get user error: $e');
      throw Exception('Gagal mengambil data pengguna');
    }
  }

  /// Update user document
  Future<void> updateUser(String userId, Map<String, dynamic> data) async {
    try {
      await _users.doc(userId).update({
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      debugPrint('✅ User updated: $userId');
    } catch (e) {
      debugPrint('❌ Update user error: $e');
      throw Exception('Gagal update data pengguna');
    }
  }

  /// Stream user document (for realtime updates)
  Stream<Map<String, dynamic>?> userStream(String userId) {
    return _users.doc(userId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return doc.data() as Map<String, dynamic>?;
    });
  }

  // ========== BALANCE OPERATIONS ==========

  /// Update balance to specific value
  Future<void> updateBalance(String userId, double newBalance) async {
    try {
      await _users.doc(userId).update({'balance': newBalance});
      debugPrint('✅ Balance updated: $newBalance');
    } catch (e) {
      debugPrint('❌ Update balance error: $e');
      throw Exception('Gagal update saldo');
    }
  }

  /// Add amount to balance
  Future<void> addBalance(String userId, double amount) async {
    try {
      await _users.doc(userId).update({
        'balance': FieldValue.increment(amount),
      });
      debugPrint('✅ Balance added: +$amount');
    } catch (e) {
      debugPrint('❌ Add balance error: $e');
      throw Exception('Gagal menambah saldo');
    }
  }

  /// Deduct amount from balance
  Future<void> deductBalance(String userId, double amount) async {
    try {
      await _users.doc(userId).update({
        'balance': FieldValue.increment(-amount),
      });
      debugPrint('✅ Balance deducted: -$amount');
    } catch (e) {
      debugPrint('❌ Deduct balance error: $e');
      throw Exception('Gagal mengurangi saldo');
    }
  }

  // ========== TRANSACTION OPERATIONS ==========

  /// Add transaction
  Future<String> addTransaction(Map<String, dynamic> transactionData) async {
    try {
      final docRef = await _transactions.add({
        ...transactionData,
        'createdAt': FieldValue.serverTimestamp(),
      });
      debugPrint('✅ Transaction added: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      debugPrint('❌ Add transaction error: $e');
      throw Exception('Gagal menyimpan transaksi');
    }
  }

  /// Get transactions for specific user
  Stream<List<Map<String, dynamic>>> transactionsStream(String userId) {
    return _transactions
        .where('senderId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(100)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            data['id'] = doc.id;
            return data;
          }).toList();
        });
  }

  /// Get all transactions (sender or receiver)
  Stream<List<Map<String, dynamic>>> allUserTransactionsStream(String userId) {
    // Note: Firestore doesn't support OR queries directly in streams
    // We'll need to merge two queries or use a different approach
    // For now, just return sender transactions
    return transactionsStream(userId);
  }

  // ========== CONTACT OPERATIONS ==========

  /// Add contact to user's contacts sub-collection
  Future<String> addContact(
    String userId,
    Map<String, dynamic> contactData,
  ) async {
    try {
      final docRef = await _users.doc(userId).collection('contacts').add({
        ...contactData,
        'createdAt': FieldValue.serverTimestamp(),
      });
      debugPrint('✅ Contact added: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      debugPrint('❌ Add contact error: $e');
      throw Exception('Gagal menambah kontak');
    }
  }

  /// Delete contact
  Future<void> deleteContact(String userId, String contactId) async {
    try {
      await _users.doc(userId).collection('contacts').doc(contactId).delete();
      debugPrint('✅ Contact deleted: $contactId');
    } catch (e) {
      debugPrint('❌ Delete contact error: $e');
      throw Exception('Gagal menghapus kontak');
    }
  }

  /// Stream contacts for user
  Stream<List<Map<String, dynamic>>> contactsStream(String userId) {
    return _users
        .doc(userId)
        .collection('contacts')
        .orderBy('name')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return data;
          }).toList();
        });
  }

  // ========== TRANSFER OPERATION (ATOMIC) ==========

  /// Transfer money between users atomically
  /// This ensures both sender and receiver balances update together
  Future<void> transferMoney({
    required String senderId,
    required String receiverId,
    required double amount,
    required Map<String, dynamic> transactionData,
  }) async {
    try {
      // Use batch write for atomic operation
      final batch = _firestore.batch();

      // 1. Deduct sender balance
      batch.update(_users.doc(senderId), {
        'balance': FieldValue.increment(-amount),
      });

      // 2. Add receiver balance
      batch.update(_users.doc(receiverId), {
        'balance': FieldValue.increment(amount),
      });

      // 3. Add sender transaction (outgoing)
      final senderTxnRef = _transactions.doc();
      batch.set(senderTxnRef, {
        ...transactionData,
        'senderId': senderId,
        'receiverId': receiverId,
        'type': 'transfer',
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 4. Add receiver transaction (incoming)
      final receiverTxnRef = _transactions.doc();
      batch.set(receiverTxnRef, {
        ...transactionData,
        'senderId': senderId,
        'receiverId': receiverId,
        'type': 'receive',
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Commit all operations atomically
      await batch.commit();
      debugPrint('✅ Transfer completed: $senderId → $receiverId ($amount)');
    } catch (e) {
      debugPrint('❌ Transfer error: $e');
      throw Exception('Transfer gagal. Coba lagi.');
    }
  }

  // ========== UTILITY OPERATIONS ==========

  /// Find user by phone number
  Future<Map<String, dynamic>?> findUserByPhone(String phone) async {
    try {
      final querySnapshot = await _users
          .where('phone', isEqualTo: phone)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        debugPrint('⚠️ User with phone $phone not found');
        return null;
      }

      final doc = querySnapshot.docs.first;
      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      return data;
    } catch (e) {
      debugPrint('❌ Find user by phone error: $e');
      throw Exception('Gagal mencari pengguna');
    }
  }

  /// Find user by email
  Future<Map<String, dynamic>?> findUserByEmail(String email) async {
    try {
      final querySnapshot = await _users
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        debugPrint('⚠️ User with email $email not found');
        return null;
      }

      final doc = querySnapshot.docs.first;
      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      return data;
    } catch (e) {
      debugPrint('❌ Find user by email error: $e');
      throw Exception('Gagal mencari pengguna');
    }
  }
}
