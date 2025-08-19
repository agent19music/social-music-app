import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class VisaCardWidget extends StatelessWidget {
  final String cardHolder;
  final String cardNumber; // e.g. "1234 5678 9012 3456"
  final String expiry; // e.g. "08/27"
  final bool masked;

  const VisaCardWidget({
    super.key,
    this.cardHolder = 'Christine Lucieta',
    this.cardNumber = '1234 5678 9012 3456',
    this.expiry = '08/27',
    this.masked = true,
  });

  String _displayNumber(String num) {
    if (!masked) return num;
    // show only last 4 digits, keep groups
    final parts = num.split(' ');
    for (var i = 0; i < parts.length - 1; i++) {
      parts[i] = '••••';
    }
    return parts.join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final cardWidth = MediaQuery.of(context).size.width * 0.88;
    final cardHeight = cardWidth * 0.62;

    return Center(
      child: Container(
        width: cardWidth,
        height: cardHeight,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFF0F4C81), // deep Visa-like blue
              Color(0xFF2A7BC7), // lighter
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: chip + contactless + logo
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Chip
                Container(
                  width: cardWidth * 0.12,
                  height: cardHeight * 0.12,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFD9B24A), Color(0xFFB5832A)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Center(
                    child: Container(
                      width: cardWidth * 0.06,
                      height: cardHeight * 0.06,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Contactless icon (simple)
                Icon(
                  Icons.wifi,
                  color: Colors.white.withOpacity(0.85),
                  size: cardHeight * 0.06,
                ),
                const Spacer(),
                // Visa-style logo (replace with Image.asset if you have one)
                _VisaLogo(height: cardHeight * 0.12),
              ],
            ),

            const Spacer(),

            // Card number
            Text(
              _displayNumber(cardNumber),
              style: GoogleFonts.sourceCodePro(
                color: Colors.white,
                fontSize: cardHeight * 0.10,
                letterSpacing: 2.4,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 12),

            // Bottom row: name + expiry
            Row(
              children: [
                // Card holder
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Card Holder',
                      style: GoogleFonts.openSans(
                        color: Colors.white.withOpacity(0.75),
                        fontSize: cardHeight * 0.08,
                      ),
                    ),
                    Text(
                      cardHolder.toUpperCase(),
                      style: GoogleFonts.rubik(
                        color: Colors.white,
                        fontSize: cardHeight * 0.07,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                // Expiry
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Expires',
                      style: GoogleFonts.openSans(
                        color: Colors.white.withOpacity(0.75),
                        fontSize: cardHeight * 0.08,
                      ),
                    ),
                    Text(
                      expiry,
                      style: GoogleFonts.rubik(
                        color: Colors.white,
                        fontSize: cardHeight * 0.07,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _VisaLogo extends StatelessWidget {
  final double height;
  const _VisaLogo({required this.height});

  @override
  Widget build(BuildContext context) {
    // Simple stylized VISA text badge. Replace with Image.asset('assets/visa.png', height: height) if available.
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        color: Colors.white.withOpacity(0.12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // small yellow accent to mimic Visa mark
          Container(
            width: height * 0.45,
            height: height * 0.45,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFF4C542),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            'VISA',
            style: GoogleFonts.rubik(
              color: Colors.white,
              fontSize: height * 0.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

/// ------------------
/// Example usage in a Scaffold
/// ------------------
class CardDemoPage extends StatelessWidget {
  const CardDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Card demo — Rono'),
        backgroundColor: const Color(0xFF0F4C81),
      ),
      body: const SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(vertical: 36),
          child: VisaCardWidget(
            cardHolder: 'Christine Lucieta',
            cardNumber: '4556 7375 8689 9855', // demo Visa-like number
            expiry: '08/27',
            masked: true,
          ),
        ),
      ),
    );
  }
}