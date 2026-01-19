import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import '../../models/zakat_model.dart';
import '../../services/zakat/zakat_service.dart';

class ZakatController extends GetxController {
  final ZakatService _service = ZakatService();

  // Selected currency
  var selectedCurrency = 'USD'.obs;

  // Asset values
  var goldValue = 0.0.obs;
  var silverValue = 0.0.obs;
  var cashValue = 0.0.obs;
  var investmentsValue = 0.0.obs;
  var stocksValue = 0.0.obs;
  var businessAssetsValue = 0.0.obs;
  var debtsOwed = 0.0.obs; // Money owed to you
  var debtsOwing = 0.0.obs; // Money you owe

  // Gold/Silver weight input mode
  var goldInputMode = 'value'.obs; // 'value' or 'weight'
  var silverInputMode = 'value'.obs;
  var goldWeight = 0.0.obs;
  var silverWeight = 0.0.obs;

  // Nisab type selection
  var nisabType = 'silver'.obs; // 'gold' or 'silver'

  // Calculation result
  var calculation = Rxn<ZakatCalculationModel>();
  var calculationHistory = <ZakatCalculationModel>[].obs;

  // UI state
  var isLoading = false.obs;
  var showResult = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadHistory();
  }

  /// Get all supported currencies
  List<CurrencyModel> get currencies => _service.supportedCurrencies;

  /// Get current currency
  CurrencyModel get currentCurrency => _service.getCurrency(selectedCurrency.value);

  /// Get asset categories
  List<ZakatAssetCategory> get assetCategories => _service.getAssetCategories();

  /// Get FAQs
  List<Map<String, String>> get faqs => _service.getZakatFAQs();

  /// Calculate Nisab thresholds
  double get nisabGold => _service.calculateNisabGold(selectedCurrency.value);
  double get nisabSilver => _service.calculateNisabSilver(selectedCurrency.value);
  double get currentNisab => nisabType.value == 'gold' ? nisabGold : nisabSilver;

  /// Get total assets
  double get totalAssets {
    final gold = goldInputMode.value == 'weight'
        ? _service.goldWeightToValue(goldWeight.value, selectedCurrency.value)
        : goldValue.value;
    final silver = silverInputMode.value == 'weight'
        ? _service.silverWeightToValue(silverWeight.value, selectedCurrency.value)
        : silverValue.value;

    return gold +
        silver +
        cashValue.value +
        investmentsValue.value +
        stocksValue.value +
        businessAssetsValue.value +
        debtsOwed.value -
        debtsOwing.value;
  }

  /// Calculate Zakat
  void calculateZakat() {
    isLoading.value = true;

    // Convert weight to value if needed
    final gold = goldInputMode.value == 'weight'
        ? _service.goldWeightToValue(goldWeight.value, selectedCurrency.value)
        : goldValue.value;
    final silver = silverInputMode.value == 'weight'
        ? _service.silverWeightToValue(silverWeight.value, selectedCurrency.value)
        : silverValue.value;

    calculation.value = _service.calculateZakat(
      currency: selectedCurrency.value,
      goldValue: gold,
      silverValue: silver,
      cashValue: cashValue.value,
      investmentsValue: investmentsValue.value,
      stocksValue: stocksValue.value,
      businessAssetsValue: businessAssetsValue.value,
      debtsOwed: debtsOwed.value,
      debtsOwing: debtsOwing.value,
      nisabType: nisabType.value,
    );

    showResult.value = true;
    isLoading.value = false;
  }

  /// Save current calculation to history
  Future<void> saveCalculation() async {
    if (calculation.value == null) return;
    await _service.saveCalculation(calculation.value!);
    loadHistory();
    Get.snackbar(
      '✅ Saved',
      'Zakat calculation saved to history',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  /// Load calculation history
  void loadHistory() {
    calculationHistory.value = _service.getCalculationHistory();
  }

  /// Delete a calculation from history
  Future<void> deleteCalculation(String id) async {
    await _service.deleteCalculation(id);
    loadHistory();
  }

  /// Clear all history
  Future<void> clearHistory() async {
    await _service.clearHistory();
    loadHistory();
  }

  /// Reset calculator
  void resetCalculator() {
    goldValue.value = 0;
    silverValue.value = 0;
    cashValue.value = 0;
    investmentsValue.value = 0;
    stocksValue.value = 0;
    businessAssetsValue.value = 0;
    debtsOwed.value = 0;
    debtsOwing.value = 0;
    goldWeight.value = 0;
    silverWeight.value = 0;
    calculation.value = null;
    showResult.value = false;
  }

  /// Share calculation result
  void shareCalculation() {
    if (calculation.value == null) return;

    final calc = calculation.value!;
    final currency = _service.getCurrency(calc.currency);

    final text =
        '''
🕌 Zakat Calculation

📅 Date: ${_formatDate(calc.date)}
💱 Currency: ${currency.name} (${currency.symbol})

📊 Assets Breakdown:
${calc.goldValue > 0 ? '🥇 Gold: ${currency.symbol}${_formatNumber(calc.goldValue)}\n' : ''}${calc.silverValue > 0 ? '🥈 Silver: ${currency.symbol}${_formatNumber(calc.silverValue)}\n' : ''}${calc.cashValue > 0 ? '💵 Cash: ${currency.symbol}${_formatNumber(calc.cashValue)}\n' : ''}${calc.investmentsValue > 0 ? '📈 Investments: ${currency.symbol}${_formatNumber(calc.investmentsValue)}\n' : ''}${calc.stocksValue > 0 ? '📊 Stocks: ${currency.symbol}${_formatNumber(calc.stocksValue)}\n' : ''}${calc.businessAssetsValue > 0 ? '🏢 Business: ${currency.symbol}${_formatNumber(calc.businessAssetsValue)}\n' : ''}${calc.debtsOwed > 0 ? '📥 Receivables: ${currency.symbol}${_formatNumber(calc.debtsOwed)}\n' : ''}${calc.debtsOwing > 0 ? '📤 Liabilities: -${currency.symbol}${_formatNumber(calc.debtsOwing)}\n' : ''}
💰 Total Assets: ${currency.symbol}${_formatNumber(calc.totalAssets)}

📋 Nisab (${calc.nisabType == 'gold' ? 'Gold' : 'Silver'}): ${currency.symbol}${_formatNumber(calc.nisabType == 'gold' ? calc.nisabGold : calc.nisabSilver)}

${calc.meetsNisab ? '✅ Zakat is Due!\n\n🤲 Zakat Amount (2.5%): ${currency.symbol}${_formatNumber(calc.zakatAmount)}' : '❌ Wealth below Nisab threshold.\nZakat is not obligatory.'}

Calculated using Qibla Finder App 🧭
''';

    SharePlus.instance.share(ShareParams(text: text));
  }

  /// Load a historical calculation
  void loadFromHistory(ZakatCalculationModel calc) {
    selectedCurrency.value = calc.currency;
    goldValue.value = calc.goldValue;
    silverValue.value = calc.silverValue;
    cashValue.value = calc.cashValue;
    investmentsValue.value = calc.investmentsValue;
    stocksValue.value = calc.stocksValue;
    businessAssetsValue.value = calc.businessAssetsValue;
    debtsOwed.value = calc.debtsOwed;
    debtsOwing.value = calc.debtsOwing;
    nisabType.value = calc.nisabType;
    calculation.value = calc;
    showResult.value = true;
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatNumber(double number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(2)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(2)}K';
    }
    return number.toStringAsFixed(2);
  }
}
