import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/responsive_helper.dart';

/// Transfer Contact List Screen - Pilih kontak untuk transfer
/// Features: Search bar, Add new contact, Contact list
/// User-friendly: Search mudah, list jelas
class TransferContactListScreen extends StatefulWidget {
  const TransferContactListScreen({super.key});

  @override
  State<TransferContactListScreen> createState() =>
      _TransferContactListScreenState();
}

class _TransferContactListScreenState extends State<TransferContactListScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, String>> _contacts = [];
  List<Map<String, String>> _filteredContacts = [];

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  void _loadContacts() {
    // Mock data contacts
    _contacts = [
      {'name': 'Budi Santoso', 'accountNumber': '1234567890'},
      {'name': 'Siti Nurhaliza', 'accountNumber': '0987654321'},
      {'name': 'Ahmad Dahlan', 'accountNumber': '1122334455'},
      {'name': 'Dewi Lestari', 'accountNumber': '5544332211'},
      {'name': 'Rina Wijaya', 'accountNumber': '6677889900'},
      {'name': 'Andi Pratama', 'accountNumber': '9988776655'},
      {'name': 'Fitri Handayani', 'accountNumber': '1231231234'},
      {'name': 'Joko Widodo', 'accountNumber': '4564564567'},
    ];
    _filteredContacts = _contacts;
  }

  void _searchContacts(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredContacts = _contacts;
      } else {
        _filteredContacts = _contacts.where((contact) {
          final name = contact['name']!.toLowerCase();
          final account = contact['accountNumber']!;
          final searchLower = query.toLowerCase();
          return name.contains(searchLower) || account.contains(searchLower);
        }).toList();
      }
    });
  }

  void _selectContact(Map<String, String> contact) {
    // Navigate to amount screen with contact data
    Navigator.pushNamed(context, '/transfer-amount', arguments: contact);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text('Pilih Penerima'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: EdgeInsets.all(responsive.horizontalPadding),
            child: TextField(
              controller: _searchController,
              onChanged: _searchContacts,
              decoration: InputDecoration(
                hintText: 'Cari nama atau nomor rekening',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: AppColors.grayLight1,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),

          // Add New Contact Button
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: responsive.horizontalPadding,
            ),
            child: InkWell(
              onTap: () {
                // TODO: Add new contact
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Fitur tambah kontak akan segera hadir'),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primaryOrange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primaryOrange.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: AppColors.primaryOrange,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.add,
                        color: AppColors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Tambah Kontak Baru',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.primaryOrange,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Contact List
          Expanded(
            child: _filteredContacts.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.person_search,
                          size: 64,
                          color: AppColors.grayMedium1,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Kontak tidak ditemukan',
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: EdgeInsets.symmetric(
                      horizontal: responsive.horizontalPadding,
                    ),
                    itemCount: _filteredContacts.length,
                    separatorBuilder: (context, index) =>
                        const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final contact = _filteredContacts[index];
                      return _buildContactItem(contact);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(Map<String, String> contact) {
    final name = contact['name']!;
    final accountNumber = contact['accountNumber']!;
    final initial = name[0].toUpperCase();

    return InkWell(
      onTap: () => _selectContact(contact),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primaryOrange.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  initial,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.primaryOrange,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Name & Account
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    accountNumber,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // Arrow
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
