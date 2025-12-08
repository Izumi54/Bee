import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../core/providers/contact_provider.dart';

/// Transfer Contact List Screen - Pilih kontak untuk transfer
/// Features: Search bar, Add new contact, Contact list with Provider
class TransferContactListScreen extends StatefulWidget {
  const TransferContactListScreen({super.key});

  @override
  State<TransferContactListScreen> createState() =>
      _TransferContactListScreenState();
}

class _TransferContactListScreenState extends State<TransferContactListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showAddContactDialog() {
    final nameController = TextEditingController();
    final accountController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Tambah Kontak Baru'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Lengkap',
                  hintText: 'Masukkan nama penerima',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nama tidak boleh kosong';
                  }
                  if (value.trim().length < 3) {
                    return 'Nama minimal 3 karakter';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: accountController,
                decoration: const InputDecoration(
                  labelText: 'Nomor Rekening',
                  hintText: 'Masukkan nomor rekening',
                  prefixIcon: Icon(Icons.account_balance_wallet_outlined),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nomor rekening tidak boleh kosong';
                  }
                  if (value.trim().length < 8) {
                    return 'Nomor rekening minimal 8 digit';
                  }
                  if (!RegExp(r'^[0-9]+$').hasMatch(value.trim())) {
                    return 'Nomor rekening hanya boleh angka';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                final contactProvider = context.read<ContactProvider>();
                final success = await contactProvider.addContact(
                  name: nameController.text.trim(),
                  accountNumber: accountController.text.trim(),
                );

                if (success) {
                  Navigator.pop(dialogContext);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Kontak berhasil ditambahkan!'),
                      backgroundColor: AppColors.successGreen,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Nomor rekening sudah ada dalam daftar'),
                      backgroundColor: AppColors.errorRed,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryOrange,
            ),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _selectContact(Contact contact) {
    Navigator.pushNamed(
      context,
      '/transfer-amount',
      arguments: contact.toMap(),
    );
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
              onChanged: (query) {
                context.read<ContactProvider>().searchContacts(query);
              },
              decoration: InputDecoration(
                hintText: 'Cari nama atau nomor rekening',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          context.read<ContactProvider>().clearSearch();
                        },
                      )
                    : null,
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
              onTap: _showAddContactDialog,
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
            child: Consumer<ContactProvider>(
              builder: (context, contactProvider, child) {
                if (contactProvider.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryOrange,
                    ),
                  );
                }

                final contacts = contactProvider.filteredContacts;

                if (contacts.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.person_search,
                          size: 64,
                          color: AppColors.grayMedium1,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          contactProvider.searchQuery.isNotEmpty
                              ? 'Kontak tidak ditemukan'
                              : 'Belum ada kontak',
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                        if (contactProvider.searchQuery.isEmpty) ...[
                          const SizedBox(height: 8),
                          TextButton.icon(
                            onPressed: _showAddContactDialog,
                            icon: const Icon(Icons.add),
                            label: const Text('Tambah Kontak'),
                          ),
                        ],
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: EdgeInsets.symmetric(
                    horizontal: responsive.horizontalPadding,
                  ),
                  itemCount: contacts.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final contact = contacts[index];
                    return _buildContactItem(contact);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(Contact contact) {
    final initial = contact.name.isNotEmpty
        ? contact.name[0].toUpperCase()
        : '?';

    return Dismissible(
      key: Key(contact.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: AppColors.errorRed,
        child: const Icon(Icons.delete, color: AppColors.white),
      ),
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Hapus Kontak?'),
                content: Text(
                  'Apakah Anda yakin ingin menghapus ${contact.name}?',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Batal'),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.errorRed,
                    ),
                    child: const Text('Hapus'),
                  ),
                ],
              ),
            ) ??
            false;
      },
      onDismissed: (direction) {
        context.read<ContactProvider>().deleteContact(contact.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${contact.name} dihapus'),
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () {
                // Re-add contact
                context.read<ContactProvider>().addContact(
                  name: contact.name,
                  accountNumber: contact.accountNumber,
                );
              },
            ),
          ),
        );
      },
      child: InkWell(
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
                      contact.name,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      contact.accountNumber,
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
      ),
    );
  }
}
