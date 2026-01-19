import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/zakat_controller/zakat_controller.dart';
import '../../models/zakat_model.dart';

class ZakatCalculatorScreen extends StatelessWidget {
  ZakatCalculatorScreen({super.key});

  final controller = Get.put(ZakatController());

  // Theme colors
  static const Color primaryPurple = Color(0xFF8F66FF);
  static const Color goldAccent = Color(0xFFD4AF37);
  static const Color greenSuccess = Color(0xFF4CAF50);
  static const Color lightBg = Color(0xFFF8F9FA);
  static const Color cardBg = Colors.white;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBg,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildNisabInfoCard(),
                  const SizedBox(height: 16),
                  _buildCurrencySelector(),
                  const SizedBox(height: 16),
                  _buildNisabTypeSelector(),
                  const SizedBox(height: 16),
                  _buildAssetsCard(),
                  const SizedBox(height: 16),
                  _buildCalculateButton(),
                  const SizedBox(height: 16),
                  Obx(() => controller.showResult.value ? _buildResultCard() : const SizedBox()),
                  const SizedBox(height: 16),
                  _buildHistorySection(),
                  const SizedBox(height: 16),
                  _buildFAQSection(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 140,
      floating: false,
      pinned: true,
      backgroundColor: primaryPurple,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Get.back(),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.white),
          onPressed: () => controller.resetCalculator(),
        ),
        IconButton(
          icon: const Icon(Icons.info_outline, color: Colors.white),
          onPressed: () => _showInfoDialog(),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          'Zakat Calculator 💰',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 18,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [primaryPurple, primaryPurple.withOpacity(0.8)],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -20,
                top: 20,
                child: Icon(
                  Icons.account_balance_wallet,
                  size: 120,
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNisabInfoCard() {
    return Obx(() {
      final currency = controller.currentCurrency;
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [goldAccent.withOpacity(0.2), primaryPurple.withOpacity(0.1)],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: goldAccent.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Row(
              children: [
                const Text('📊', style: TextStyle(fontSize: 24)),
                const SizedBox(width: 8),
                Text(
                  'Nisab Thresholds',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildNisabItem(
                    '🥇 Gold',
                    '${currency.symbol}${_formatNumber(controller.nisabGold)}',
                    '87.48g',
                    controller.nisabType.value == 'gold',
                  ),
                ),
                Container(
                  height: 50,
                  width: 1,
                  color: Colors.grey[300],
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                ),
                Expanded(
                  child: _buildNisabItem(
                    '🥈 Silver',
                    '${currency.symbol}${_formatNumber(controller.nisabSilver)}',
                    '612.36g',
                    controller.nisabType.value == 'silver',
                  ),
                ),
              ],
            ),
          ],
        ),
      ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0);
    });
  }

  Widget _buildNisabItem(String label, String value, String weight, bool isSelected) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isSelected ? primaryPurple.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isSelected ? primaryPurple : Colors.transparent, width: 2),
      ),
      child: Column(
        children: [
          Text(label, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600])),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isSelected ? primaryPurple : Colors.grey[800],
            ),
          ),
          Text(weight, style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey[500])),
        ],
      ),
    );
  }

  Widget _buildCurrencySelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '💱 Select Currency',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 12),
          Obx(
            () => DropdownButtonFormField<String>(
              initialValue: controller.selectedCurrency.value,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              items: controller.currencies.map((currency) {
                return DropdownMenuItem(
                  value: currency.code,
                  child: Text(
                    '${currency.symbol} ${currency.name} (${currency.code})',
                    style: GoogleFonts.poppins(fontSize: 14),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) controller.selectedCurrency.value = value;
              },
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 100.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildNisabTypeSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '📋 Nisab Threshold',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Silver is recommended (lower threshold)',
            style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey[500]),
          ),
          const SizedBox(height: 12),
          Obx(
            () => Row(
              children: [
                Expanded(child: _buildNisabOption('silver', '🥈 Silver Nisab')),
                const SizedBox(width: 12),
                Expanded(child: _buildNisabOption('gold', '🥇 Gold Nisab')),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 150.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildNisabOption(String value, String label) {
    final isSelected = controller.nisabType.value == value;
    return GestureDetector(
      onTap: () => controller.nisabType.value = value,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? primaryPurple : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? primaryPurple : Colors.grey[300]!),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : Colors.grey[700],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAssetsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '💼 Your Assets',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 16),
          _buildGoldInput(),
          const SizedBox(height: 12),
          _buildSilverInput(),
          const SizedBox(height: 12),
          _buildAssetInput('💵 Cash & Bank Savings', controller.cashValue, 'cash'),
          const SizedBox(height: 12),
          _buildAssetInput('📈 Investments', controller.investmentsValue, 'investments'),
          const SizedBox(height: 12),
          _buildAssetInput('📊 Stocks & Shares', controller.stocksValue, 'stocks'),
          const SizedBox(height: 12),
          _buildAssetInput('🏢 Business Assets', controller.businessAssetsValue, 'business'),
          const SizedBox(height: 12),
          _buildAssetInput('📥 Money Owed to You', controller.debtsOwed, 'receivables'),
          const SizedBox(height: 12),
          _buildAssetInput(
            '📤 Debts You Owe (Deductible)',
            controller.debtsOwing,
            'liabilities',
            isDeductible: true,
          ),
          const SizedBox(height: 16),
          Obx(
            () => Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: primaryPurple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Zakatable Assets',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: primaryPurple,
                    ),
                  ),
                  Text(
                    '${controller.currentCurrency.symbol}${_formatNumber(controller.totalAssets)}',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: primaryPurple,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 200.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildGoldInput() {
    return Obx(() {
      final isWeight = controller.goldInputMode.value == 'weight';
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('🥇 Gold', style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[700])),
              _buildInputModeToggle(
                isWeight: isWeight,
                onToggle: () {
                  controller.goldInputMode.value = isWeight ? 'value' : 'weight';
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (isWeight)
            _buildWeightInput(controller.goldWeight, 'Gold weight in grams')
          else
            _buildValueInput(controller.goldValue, 'Gold value'),
        ],
      );
    });
  }

  Widget _buildSilverInput() {
    return Obx(() {
      final isWeight = controller.silverInputMode.value == 'weight';
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('🥈 Silver', style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[700])),
              _buildInputModeToggle(
                isWeight: isWeight,
                onToggle: () {
                  controller.silverInputMode.value = isWeight ? 'value' : 'weight';
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (isWeight)
            _buildWeightInput(controller.silverWeight, 'Silver weight in grams')
          else
            _buildValueInput(controller.silverValue, 'Silver value'),
        ],
      );
    });
  }

  Widget _buildInputModeToggle({required bool isWeight, required VoidCallback onToggle}) {
    return GestureDetector(
      onTap: onToggle,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(isWeight ? Icons.scale : Icons.attach_money, size: 14, color: primaryPurple),
            const SizedBox(width: 4),
            Text(
              isWeight ? 'Grams' : 'Value',
              style: GoogleFonts.poppins(fontSize: 11, color: primaryPurple),
            ),
            const SizedBox(width: 4),
            Icon(Icons.swap_horiz, size: 12, color: Colors.grey[500]),
          ],
        ),
      ),
    );
  }

  Widget _buildWeightInput(RxDouble value, String hint) {
    return TextFormField(
      initialValue: value.value > 0 ? value.value.toString() : '',
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[400]),
        suffixText: 'g',
        suffixStyle: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[600]),
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      style: GoogleFonts.poppins(fontSize: 14),
      onChanged: (text) {
        value.value = double.tryParse(text) ?? 0;
      },
    );
  }

  Widget _buildValueInput(RxDouble value, String hint) {
    return Obx(
      () => TextFormField(
        key: ValueKey('${hint}_${controller.selectedCurrency.value}'),
        initialValue: value.value > 0 ? value.value.toString() : '',
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[400]),
          prefixText: '${controller.currentCurrency.symbol} ',
          prefixStyle: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[700]),
          filled: true,
          fillColor: Colors.grey[50],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        style: GoogleFonts.poppins(fontSize: 14),
        onChanged: (text) {
          value.value = double.tryParse(text) ?? 0;
        },
      ),
    );
  }

  Widget _buildAssetInput(String label, RxDouble value, String id, {bool isDeductible = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: isDeductible ? Colors.red[700] : Colors.grey[700],
                ),
              ),
            ),
            if (isDeductible)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '- DEDUCT',
                  style: GoogleFonts.poppins(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: Colors.red[700],
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        _buildValueInput(value, 'Enter amount'),
      ],
    );
  }

  Widget _buildCalculateButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => controller.calculateZakat(),
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryPurple,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.calculate, size: 20),
            const SizedBox(width: 8),
            Text(
              'Calculate Zakat',
              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 300.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildResultCard() {
    return Obx(() {
      final calc = controller.calculation.value;
      if (calc == null) return const SizedBox();

      final currency = controller.currentCurrency;
      final meetsNisab = calc.meetsNisab;

      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: meetsNisab ? greenSuccess.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: meetsNisab ? greenSuccess : Colors.orange, width: 2),
        ),
        child: Column(
          children: [
            Icon(
              meetsNisab ? Icons.check_circle : Icons.info,
              size: 48,
              color: meetsNisab ? greenSuccess : Colors.orange,
            ),
            const SizedBox(height: 12),
            Text(
              meetsNisab ? 'Zakat is Due! 🤲' : 'Below Nisab Threshold',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: meetsNisab ? greenSuccess : Colors.orange[800],
              ),
            ),
            const SizedBox(height: 8),
            if (meetsNisab) ...[
              Text(
                'Your Zakat Amount (2.5%)',
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 4),
              Text(
                '${currency.symbol}${_formatNumber(calc.zakatAmount)}',
                style: GoogleFonts.poppins(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: greenSuccess,
                ),
              ),
            ] else ...[
              Text(
                'Your wealth is below the Nisab threshold.',
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Nisab (${calc.nisabType == 'gold' ? 'Gold' : 'Silver'}): ${currency.symbol}${_formatNumber(calc.nisabType == 'gold' ? calc.nisabGold : calc.nisabSilver)}',
                style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[700]),
              ),
              Text(
                'Your Assets: ${currency.symbol}${_formatNumber(calc.totalAssets)}',
                style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[700]),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => controller.shareCalculation(),
                    icon: const Icon(Icons.share, size: 18),
                    label: Text('Share', style: GoogleFonts.poppins(fontSize: 13)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: primaryPurple,
                      side: const BorderSide(color: primaryPurple),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => controller.saveCalculation(),
                    icon: const Icon(Icons.save, size: 18),
                    label: Text('Save', style: GoogleFonts.poppins(fontSize: 13)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryPurple,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ).animate().fadeIn(duration: 400.ms).scale(begin: const Offset(0.95, 0.95));
    });
  }

  Widget _buildHistorySection() {
    return Obx(() {
      final history = controller.calculationHistory;
      if (history.isEmpty) return const SizedBox();

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '📜 History',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                TextButton(
                  onPressed: () => _showClearHistoryDialog(),
                  child: Text(
                    'Clear All',
                    style: GoogleFonts.poppins(fontSize: 12, color: Colors.red),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...history.take(5).map((calc) => _buildHistoryItem(calc)),
          ],
        ),
      ).animate().fadeIn(duration: 400.ms, delay: 400.ms).slideY(begin: 0.1, end: 0);
    });
  }

  Widget _buildHistoryItem(ZakatCalculationModel calc) {
    final currency = controller.currencies.firstWhere(
      (c) => c.code == calc.currency,
      orElse: () => controller.currencies.first,
    );

    return GestureDetector(
      onTap: () => controller.loadFromHistory(calc),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: calc.meetsNisab
                    ? greenSuccess.withOpacity(0.1)
                    : Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                calc.meetsNisab ? Icons.check : Icons.remove,
                size: 16,
                color: calc.meetsNisab ? greenSuccess : Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${calc.date.day}/${calc.date.month}/${calc.date.year}',
                    style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
                  ),
                  Text(
                    calc.meetsNisab
                        ? 'Zakat: ${currency.symbol}${_formatNumber(calc.zakatAmount)}'
                        : 'Below Nisab',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.delete_outline, size: 18, color: Colors.grey[400]),
              onPressed: () => controller.deleteCalculation(calc.id),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '❓ Frequently Asked Questions',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 12),
          ...controller.faqs.map((faq) => _buildFAQItem(faq)),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 500.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildFAQItem(Map<String, String> faq) {
    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      title: Text(
        faq['question'] ?? '',
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.grey[800],
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            faq['answer'] ?? '',
            style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[600], height: 1.5),
          ),
        ),
      ],
    );
  }

  void _showInfoDialog() {
    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            const Text('💰', style: TextStyle(fontSize: 24)),
            const SizedBox(width: 8),
            Text('About Zakat', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Zakat is one of the Five Pillars of Islam, making it a fundamental act of worship.',
                style: GoogleFonts.poppins(fontSize: 14),
              ),
              const SizedBox(height: 12),
              Text(
                '📋 Key Points:',
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 8),
              _buildInfoPoint('2.5% of zakatable wealth'),
              _buildInfoPoint('Due after one lunar year (Hawl)'),
              _buildInfoPoint('Must meet Nisab threshold'),
              _buildInfoPoint('Purifies wealth and soul'),
              const SizedBox(height: 12),
              Text(
                '⚠️ Note: Gold/Silver prices are approximate. Consult local scholars for accurate rates.',
                style: GoogleFonts.poppins(fontSize: 12, color: Colors.orange[800]),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Got it', style: GoogleFonts.poppins(color: primaryPurple)),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• ', style: GoogleFonts.poppins(fontSize: 14, color: primaryPurple)),
          Expanded(child: Text(text, style: GoogleFonts.poppins(fontSize: 13))),
        ],
      ),
    );
  }

  void _showClearHistoryDialog() {
    Get.dialog(
      AlertDialog(
        title: Text('Clear History?', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Text(
          'This will delete all your saved Zakat calculations.',
          style: GoogleFonts.poppins(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel', style: GoogleFonts.poppins(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              controller.clearHistory();
              Get.back();
            },
            child: Text('Clear', style: GoogleFonts.poppins(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  String _formatNumber(double number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(2)}M';
    } else if (number >= 1000) {
      return number
          .toStringAsFixed(0)
          .replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
    }
    return number.toStringAsFixed(2);
  }
}
