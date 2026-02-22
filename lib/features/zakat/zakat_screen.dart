import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app/theme/app_theme.dart';

class ZakatScreen extends StatefulWidget {
  const ZakatScreen({super.key});

  @override
  State<ZakatScreen> createState() => _ZakatScreenState();
}

class _ZakatScreenState extends State<ZakatScreen> {
  final _goldC = TextEditingController();
  final _silverC = TextEditingController();
  final _cashC = TextEditingController();
  final _businessC = TextEditingController();
  double? _zakatAmount;
  bool _eligible = false;

  // Nisab thresholds (approximate)
  static const double _nisabGoldGrams = 87.48; // grams of gold
  static const double _goldPricePerGram = 9500; // PKR approx
  static const double _nisabPKR = _nisabGoldGrams * _goldPricePerGram; // ~830,000 PKR
  static const double _zakatRate = 0.025;

  void _calculate() {
    double gold = double.tryParse(_goldC.text) ?? 0;
    double silver = double.tryParse(_silverC.text) ?? 0;
    double cash = double.tryParse(_cashC.text) ?? 0;
    double business = double.tryParse(_businessC.text) ?? 0;

    // Convert gold grams to PKR
    double goldValue = gold * _goldPricePerGram;
    // Convert silver (per gram = ~120 PKR approx)
    double silverValue = silver * 120;

    double total = goldValue + silverValue + cash + business;
    setState(() {
      _eligible = total >= _nisabPKR;
      _zakatAmount = _eligible ? total * _zakatRate : 0;
    });
  }

  @override
  void dispose() {
    _goldC.dispose();
    _silverC.dispose();
    _cashC.dispose();
    _businessC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Zakat Calculator')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: AppColors.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Nisab (Gold): ${_nisabGoldGrams}g ≈ PKR ${_nisabPKR.toStringAsFixed(0)}\nZakat Rate: 2.5%',
                      style: const TextStyle(
                          color: AppColors.primary, fontSize: 13, height: 1.5),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(),
            const SizedBox(height: 20),
            Text('Your Assets', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            _buildField('Gold (grams)', _goldC, 'e.g. 100'),
            _buildField('Silver (grams)', _silverC, 'e.g. 500'),
            _buildField('Cash & Savings (PKR)', _cashC, 'e.g. 500000'),
            _buildField('Business Assets (PKR)', _businessC, 'e.g. 200000'),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _calculate,
                child: const Text('Calculate Zakat'),
              ),
            ),
            if (_zakatAmount != null) ...[
              const SizedBox(height: 24),
              _buildResult(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, String hint) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
        ),
      ),
    );
  }

  Widget _buildResult() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _eligible
              ? [AppColors.primary, AppColors.primaryDark]
              : [Colors.orange.shade700, Colors.orange.shade900],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(
            _eligible ? 'Zakat is Due' : 'Below Nisab',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          if (_eligible) ...[
            Text(
              'PKR ${_zakatAmount!.toStringAsFixed(2)}',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 40,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Pay this amount in the way of Allah',
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ] else ...[
            Text(
              'Your wealth does not meet the Nisab threshold.',
              style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    ).animate().fadeIn().scale(begin: const Offset(0.9, 0.9), end: const Offset(1.0, 1.0));
  }
}
