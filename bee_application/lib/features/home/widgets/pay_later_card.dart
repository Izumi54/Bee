import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Pay Later Card Widget for Home Screen
/// Shows activation status, credit limit, and quick access
class PayLaterCard extends StatelessWidget {
  final bool isActive;
  final double creditLimit;
  final double availableLimit;
  final double usedLimit;
  final VoidCallback onTap;

  const PayLaterCard({
    super.key,
    required this.isActive,
    required this.creditLimit,
    required this.availableLimit,
    required this.usedLimit,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: isActive
              ? const LinearGradient(
                  colors: [Color(0xFF6C5CE7), Color(0xFFA29BFE)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : const LinearGradient(
                  colors: [Color(0xFF636E72), Color(0xFFB2BEC3)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: (isActive ? const Color(0xFF6C5CE7) : Colors.grey)
                  .withAlpha(77),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: isActive
            ? _buildActiveCard(currencyFormat)
            : _buildInactiveCard(),
      ),
    );
  }

  /// Build card for active Pay Later
  Widget _buildActiveCard(NumberFormat currencyFormat) {
    final usedPercentage = creditLimit > 0
        ? (usedLimit / creditLimit * 100)
        : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            const Icon(Icons.credit_card, color: Colors.white, size: 24),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Bee Pay Later',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Aktif',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Limit Info
        Text(
          'Total Limit',
          style: TextStyle(color: Colors.white.withAlpha(204), fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          currencyFormat.format(creditLimit),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),

        // Available & Used Limit
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tersedia',
                  style: TextStyle(
                    color: Colors.white.withAlpha(204),
                    fontSize: 11,
                  ),
                ),
                Text(
                  currencyFormat.format(availableLimit),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Terpakai',
                  style: TextStyle(
                    color: Colors.white.withAlpha(204),
                    fontSize: 11,
                  ),
                ),
                Text(
                  currencyFormat.format(usedLimit),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Usage Progress Bar
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: usedPercentage / 100,
                backgroundColor: Colors.white30,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${usedPercentage.toStringAsFixed(0)}% terpakai',
              style: TextStyle(
                color: Colors.white.withAlpha(204),
                fontSize: 10,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Action Button
        const Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              'Kelola',
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(width: 4),
            Icon(Icons.arrow_forward, color: Colors.white, size: 16),
          ],
        ),
      ],
    );
  }

  /// Build card for inactive Pay Later
  Widget _buildInactiveCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        const Row(
          children: [
            Icon(Icons.credit_card_outlined, color: Colors.white, size: 24),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Bee Pay Later',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Description
        Text(
          'Belanja sekarang, bayar nanti!',
          style: TextStyle(
            color: Colors.white.withAlpha(229),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Cicilan 0% untuk tenor 1-3 bulan',
          style: TextStyle(color: Colors.white.withAlpha(178), fontSize: 12),
        ),
        const SizedBox(height: 16),

        // Benefits
        const Row(
          children: [
            _BenefitItem(icon: Icons.check_circle, text: 'Limit s/d Rp 5jt'),
            SizedBox(width: 16),
            _BenefitItem(icon: Icons.flash_on, text: 'Proses cepat'),
          ],
        ),
        const SizedBox(height: 16),

        // Activate Button
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            'Aktifkan Sekarang',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF6C5CE7),
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

/// Benefit item widget
class _BenefitItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _BenefitItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white, size: 14),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(color: Colors.white.withAlpha(229), fontSize: 11),
        ),
      ],
    );
  }
}
