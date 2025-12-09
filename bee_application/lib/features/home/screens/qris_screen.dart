import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../core/providers/providers.dart';
import '../../../shared/widgets/widgets.dart';

/// QRIS Screen - Demo Mode
/// Features: Scan QR (simulated) and Show My QR
class QrisScreen extends StatefulWidget {
  const QrisScreen({super.key});

  @override
  State<QrisScreen> createState() => _QrisScreenState();
}

class _QrisScreenState extends State<QrisScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text('QRIS'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primaryOrange,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primaryOrange,
          tabs: const [
            Tab(text: 'Scan QR', icon: Icon(Icons.qr_code_scanner)),
            Tab(text: 'QR Saya', icon: Icon(Icons.qr_code)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [_ScanQrTab(), _ShowQrTab()],
      ),
    );
  }
}

/// Tab untuk Scan QR (Demo Mode)
class _ScanQrTab extends StatefulWidget {
  const _ScanQrTab();

  @override
  State<_ScanQrTab> createState() => _ScanQrTabState();
}

class _ScanQrTabState extends State<_ScanQrTab> {
  bool _isScanning = false;
  bool _showPaymentForm = false;
  String _merchantName = '';

  void _simulateScan() {
    setState(() => _isScanning = true);

    // Simulate scanning delay
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isScanning = false;
          _showPaymentForm = true;
          _merchantName = _getRandomMerchant();
        });
      }
    });
  }

  String _getRandomMerchant() {
    final merchants = [
      'Warung Makan Bu Siti',
      'Toko Kelontong Pak Ahmad',
      'Kopi Kenangan',
      'Indomaret',
      'Alfamart',
      'Mixue Ice Cream',
      'Bakso Pak Kumis',
    ];
    merchants.shuffle();
    return merchants.first;
  }

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;

    if (_showPaymentForm) {
      return _PaymentForm(
        merchantName: _merchantName,
        onCancel: () {
          setState(() {
            _showPaymentForm = false;
            _merchantName = '';
          });
        },
      );
    }

    return Padding(
      padding: EdgeInsets.all(responsive.horizontalPadding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Simulated Camera View
          Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              color: AppColors.grayLight1,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primaryOrange, width: 3),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Crosshair corners
                ..._buildCorners(),

                // Content
                if (_isScanning)
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(
                        color: AppColors.primaryOrange,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Memindai QR Code...',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  )
                else
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.qr_code_scanner,
                        size: 80,
                        color: AppColors.grayMedium1,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '(Demo Mode)',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Instructions
          Text(
            'Arahkan kamera ke QR Code',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'Pastikan QR Code berada dalam bingkai',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 32),

          // Demo Scan Button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryOrange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                const Icon(Icons.info_outline, color: AppColors.primaryOrange),
                const SizedBox(height: 8),
                Text(
                  'Mode Demo',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryOrange,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tekan tombol di bawah untuk simulasi scan',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          CustomButton(
            text: _isScanning ? 'Memindai...' : 'Simulasi Scan QR',
            onPressed: _isScanning ? null : _simulateScan,
            isLoading: _isScanning,
            icon: Icons.qr_code_scanner,
          ),
        ],
      ),
    );
  }

  List<Widget> _buildCorners() {
    const cornerSize = 30.0;
    const cornerWidth = 4.0;
    const color = AppColors.primaryOrange;

    return [
      // Top left
      Positioned(
        top: 10,
        left: 10,
        child: Container(
          width: cornerSize,
          height: cornerSize,
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(color: color, width: cornerWidth),
              left: BorderSide(color: color, width: cornerWidth),
            ),
          ),
        ),
      ),
      // Top right
      Positioned(
        top: 10,
        right: 10,
        child: Container(
          width: cornerSize,
          height: cornerSize,
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(color: color, width: cornerWidth),
              right: BorderSide(color: color, width: cornerWidth),
            ),
          ),
        ),
      ),
      // Bottom left
      Positioned(
        bottom: 10,
        left: 10,
        child: Container(
          width: cornerSize,
          height: cornerSize,
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: color, width: cornerWidth),
              left: BorderSide(color: color, width: cornerWidth),
            ),
          ),
        ),
      ),
      // Bottom right
      Positioned(
        bottom: 10,
        right: 10,
        child: Container(
          width: cornerSize,
          height: cornerSize,
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: color, width: cornerWidth),
              right: BorderSide(color: color, width: cornerWidth),
            ),
          ),
        ),
      ),
    ];
  }
}

/// Payment Form after scanning
class _PaymentForm extends StatefulWidget {
  final String merchantName;
  final VoidCallback onCancel;

  const _PaymentForm({required this.merchantName, required this.onCancel});

  @override
  State<_PaymentForm> createState() => _PaymentFormState();
}

class _PaymentFormState extends State<_PaymentForm> {
  final TextEditingController _amountController = TextEditingController();
  bool _isProcessing = false;

  final currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  int get _amount {
    final text = _amountController.text.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(text) ?? 0;
  }

  Future<void> _processPayment() async {
    final amount = _amount;
    if (amount < 1000) {
      _showMessage('Minimal pembayaran Rp 1.000', isError: true);
      return;
    }

    final userProvider = context.read<UserProvider>();
    if (userProvider.balance < amount) {
      _showMessage('Saldo tidak mencukupi', isError: true);
      return;
    }

    setState(() => _isProcessing = true);

    try {
      // Deduct balance
      await userProvider.deductBalance(amount.toDouble());

      // Add transaction
      final transactionProvider = context.read<TransactionProvider>();
      await transactionProvider.addPayment(
        amount: amount.toDouble(),
        merchantName: widget.merchantName,
      );

      await Future.delayed(const Duration(milliseconds: 500));

      setState(() => _isProcessing = false);

      if (mounted) {
        _showSuccessDialog(amount);
      }
    } catch (e) {
      setState(() => _isProcessing = false);
      _showMessage('Pembayaran gagal', isError: true);
    }
  }

  void _showSuccessDialog(int amount) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.successGreen.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                size: 40,
                color: AppColors.successGreen,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Pembayaran Berhasil!',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              widget.merchantName,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),
            Text(
              currencyFormat.format(amount),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.successGreen,
              ),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Back to home
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryOrange,
              ),
              child: const Text('Kembali ke Beranda'),
            ),
          ),
        ],
      ),
    );
  }

  void _showMessage(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.errorRed : AppColors.successGreen,
      ),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;

    return SingleChildScrollView(
      padding: EdgeInsets.all(responsive.horizontalPadding),
      child: Column(
        children: [
          const SizedBox(height: 24),

          // Success scan indicator
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.successGreen.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle,
              size: 48,
              color: AppColors.successGreen,
            ),
          ),
          const SizedBox(height: 16),

          Text(
            'QR Code Terdeteksi',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 32),

          // Merchant Info
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.grayLight1,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.primaryOrange.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.store,
                    size: 28,
                    color: AppColors.primaryOrange,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  widget.merchantName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  'Merchant QRIS',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Amount Input
          Text(
            'Masukkan Nominal',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
            decoration: InputDecoration(
              prefixText: 'Rp ',
              hintText: '0',
              filled: true,
              fillColor: AppColors.grayLight1,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(20),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 16),

          // Current balance
          Consumer<UserProvider>(
            builder: (context, userProvider, child) {
              return Text(
                'Saldo: ${currencyFormat.format(userProvider.balance)}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              );
            },
          ),
          const SizedBox(height: 32),

          // Buttons
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: 'Batal',
                  onPressed: widget.onCancel,
                  isOutlined: true,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: CustomButton(
                  text: 'Bayar',
                  onPressed: (_amount < 1000 || _isProcessing)
                      ? null
                      : _processPayment,
                  isLoading: _isProcessing,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Tab untuk Show My QR
class _ShowQrTab extends StatelessWidget {
  const _ShowQrTab();

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;

    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final user = userProvider.currentUser;
        final name = user?.fullName ?? 'User';
        final phone = user?.phone ?? '0000000000';

        return SingleChildScrollView(
          padding: EdgeInsets.all(responsive.horizontalPadding),
          child: Column(
            children: [
              const SizedBox(height: 24),

              // QR Code Display (Simulated)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Simulated QR Code
                    Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        color: AppColors.grayLight1,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Grid pattern to simulate QR
                          GridView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 10,
                                  crossAxisSpacing: 2,
                                  mainAxisSpacing: 2,
                                ),
                            itemCount: 100,
                            padding: const EdgeInsets.all(16),
                            itemBuilder: (context, index) {
                              // Generate deterministic pattern based on phone number
                              final hash = (phone.hashCode + index) % 3;
                              return Container(
                                decoration: BoxDecoration(
                                  color: hash == 0
                                      ? AppColors.textPrimary
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              );
                            },
                          ),
                          // Bee logo in center
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Center(
                              child: Text('🐝', style: TextStyle(fontSize: 24)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // User info
                    Text(
                      name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'ID: $phone',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Instructions
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primaryOrange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: AppColors.primaryOrange,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Tunjukkan QR ini untuk menerima pembayaran dari orang lain',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Demo Mode Badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.grayLight1,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.science,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Demo Mode - QR Simulasi',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
