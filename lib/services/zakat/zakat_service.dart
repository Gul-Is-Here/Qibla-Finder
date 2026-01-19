import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import '../../models/zakat_model.dart';

/// Service for Zakat calculations
class ZakatService {
  static final ZakatService _instance = ZakatService._internal();
  factory ZakatService() => _instance;
  ZakatService._internal();

  final _storage = GetStorage();
  static const String _historyKey = 'zakat_calculation_history';

  // Nisab thresholds (standard Islamic values)
  static const double nisabGoldGrams = 87.48; // 87.48 grams of gold
  static const double nisabSilverGrams = 612.36; // 612.36 grams of silver
  static const double zakatRate = 0.025; // 2.5%

  // Supported currencies with approximate gold/silver prices (USD-based)
  // Note: In production, these should be fetched from a live API
  final List<CurrencyModel> supportedCurrencies = const [
    CurrencyModel(
      code: 'USD',
      name: 'US Dollar',
      symbol: '\$',
      goldPricePerGram: 65.0,
      silverPricePerGram: 0.80,
    ),
    CurrencyModel(
      code: 'EUR',
      name: 'Euro',
      symbol: '€',
      goldPricePerGram: 60.0,
      silverPricePerGram: 0.75,
    ),
    CurrencyModel(
      code: 'GBP',
      name: 'British Pound',
      symbol: '£',
      goldPricePerGram: 52.0,
      silverPricePerGram: 0.65,
    ),
    CurrencyModel(
      code: 'PKR',
      name: 'Pakistani Rupee',
      symbol: 'Rs',
      goldPricePerGram: 18000.0,
      silverPricePerGram: 220.0,
    ),
    CurrencyModel(
      code: 'INR',
      name: 'Indian Rupee',
      symbol: '₹',
      goldPricePerGram: 5400.0,
      silverPricePerGram: 67.0,
    ),
    CurrencyModel(
      code: 'SAR',
      name: 'Saudi Riyal',
      symbol: 'ر.س',
      goldPricePerGram: 244.0,
      silverPricePerGram: 3.0,
    ),
    CurrencyModel(
      code: 'AED',
      name: 'UAE Dirham',
      symbol: 'د.إ',
      goldPricePerGram: 239.0,
      silverPricePerGram: 2.94,
    ),
    CurrencyModel(
      code: 'MYR',
      name: 'Malaysian Ringgit',
      symbol: 'RM',
      goldPricePerGram: 305.0,
      silverPricePerGram: 3.75,
    ),
    CurrencyModel(
      code: 'IDR',
      name: 'Indonesian Rupiah',
      symbol: 'Rp',
      goldPricePerGram: 1020000.0,
      silverPricePerGram: 12500.0,
    ),
    CurrencyModel(
      code: 'BDT',
      name: 'Bangladeshi Taka',
      symbol: '৳',
      goldPricePerGram: 7150.0,
      silverPricePerGram: 88.0,
    ),
    CurrencyModel(
      code: 'TRY',
      name: 'Turkish Lira',
      symbol: '₺',
      goldPricePerGram: 2100.0,
      silverPricePerGram: 26.0,
    ),
    CurrencyModel(
      code: 'EGP',
      name: 'Egyptian Pound',
      symbol: 'E£',
      goldPricePerGram: 2000.0,
      silverPricePerGram: 25.0,
    ),
  ];

  /// Get currency by code
  CurrencyModel getCurrency(String code) {
    return supportedCurrencies.firstWhere(
      (c) => c.code == code,
      orElse: () => supportedCurrencies.first,
    );
  }

  /// Calculate Nisab threshold in given currency
  double calculateNisabGold(String currencyCode) {
    final currency = getCurrency(currencyCode);
    return nisabGoldGrams * currency.goldPricePerGram;
  }

  double calculateNisabSilver(String currencyCode) {
    final currency = getCurrency(currencyCode);
    return nisabSilverGrams * currency.silverPricePerGram;
  }

  /// Calculate Zakat
  ZakatCalculationModel calculateZakat({
    required String currency,
    double goldValue = 0,
    double silverValue = 0,
    double cashValue = 0,
    double investmentsValue = 0,
    double stocksValue = 0,
    double businessAssetsValue = 0,
    double debtsOwed = 0, // Money owed to you (receivables)
    double debtsOwing = 0, // Money you owe (liabilities)
    String nisabType = 'silver', // Use silver nisab by default (lower threshold)
  }) {
    // Calculate total zakatable assets
    final totalAssets =
        goldValue +
        silverValue +
        cashValue +
        investmentsValue +
        stocksValue +
        businessAssetsValue +
        debtsOwed - // Add receivables
        debtsOwing; // Subtract liabilities

    // Get Nisab values
    final nisabGold = calculateNisabGold(currency);
    final nisabSilver = calculateNisabSilver(currency);

    // Use the selected Nisab threshold
    final nisabThreshold = nisabType == 'gold' ? nisabGold : nisabSilver;

    // Check if wealth meets Nisab
    final meetsNisab = totalAssets >= nisabThreshold;

    // Calculate Zakat (2.5% of total assets if meets Nisab)
    final zakatAmount = meetsNisab ? totalAssets * zakatRate : 0;

    return ZakatCalculationModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: DateTime.now(),
      currency: currency,
      goldValue: goldValue,
      silverValue: silverValue,
      cashValue: cashValue,
      investmentsValue: investmentsValue,
      stocksValue: stocksValue,
      businessAssetsValue: businessAssetsValue,
      debtsOwed: debtsOwed,
      debtsOwing: debtsOwing,
      totalAssets: totalAssets > 0 ? totalAssets : 0.0,
      zakatAmount: zakatAmount.toDouble(),
      nisabGold: nisabGold,
      nisabSilver: nisabSilver,
      meetsNisab: meetsNisab,
      nisabType: nisabType,
    );
  }

  /// Convert gold weight to value
  double goldWeightToValue(double grams, String currencyCode) {
    final currency = getCurrency(currencyCode);
    return grams * currency.goldPricePerGram;
  }

  /// Convert silver weight to value
  double silverWeightToValue(double grams, String currencyCode) {
    final currency = getCurrency(currencyCode);
    return grams * currency.silverPricePerGram;
  }

  /// Save calculation to history
  Future<void> saveCalculation(ZakatCalculationModel calculation) async {
    final history = getCalculationHistory();
    history.insert(0, calculation);

    // Keep only last 50 calculations
    if (history.length > 50) {
      history.removeRange(50, history.length);
    }

    final jsonList = history.map((c) => c.toJson()).toList();
    await _storage.write(_historyKey, jsonEncode(jsonList));
  }

  /// Get calculation history
  List<ZakatCalculationModel> getCalculationHistory() {
    final data = _storage.read<String>(_historyKey);
    if (data == null) return [];

    try {
      final jsonList = jsonDecode(data) as List<dynamic>;
      return jsonList
          .map((json) => ZakatCalculationModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Delete a calculation from history
  Future<void> deleteCalculation(String id) async {
    final history = getCalculationHistory();
    history.removeWhere((c) => c.id == id);

    final jsonList = history.map((c) => c.toJson()).toList();
    await _storage.write(_historyKey, jsonEncode(jsonList));
  }

  /// Clear all history
  Future<void> clearHistory() async {
    await _storage.remove(_historyKey);
  }

  /// Get asset categories
  List<ZakatAssetCategory> getAssetCategories() {
    return const [
      ZakatAssetCategory(
        id: 'gold',
        name: 'Gold',
        icon: '🥇',
        description: 'Gold jewelry, coins, bars',
      ),
      ZakatAssetCategory(
        id: 'silver',
        name: 'Silver',
        icon: '🥈',
        description: 'Silver jewelry, coins, bars',
      ),
      ZakatAssetCategory(
        id: 'cash',
        name: 'Cash & Bank',
        icon: '💵',
        description: 'Cash, savings, checking accounts',
      ),
      ZakatAssetCategory(
        id: 'investments',
        name: 'Investments',
        icon: '📈',
        description: 'Mutual funds, bonds, crypto',
      ),
      ZakatAssetCategory(
        id: 'stocks',
        name: 'Stocks',
        icon: '📊',
        description: 'Shares in companies',
      ),
      ZakatAssetCategory(
        id: 'business',
        name: 'Business Assets',
        icon: '🏢',
        description: 'Inventory, trade goods',
      ),
      ZakatAssetCategory(
        id: 'receivables',
        name: 'Money Owed to You',
        icon: '📥',
        description: 'Loans given, expected payments',
      ),
      ZakatAssetCategory(
        id: 'liabilities',
        name: 'Debts You Owe',
        icon: '📤',
        description: 'Loans, bills (deductible)',
        isDeductible: true,
      ),
    ];
  }

  /// Get Zakat FAQs
  List<Map<String, String>> getZakatFAQs() {
    return [
      {
        'question': 'What is Zakat?',
        'answer':
            'Zakat is one of the Five Pillars of Islam. It is an obligatory charity that every eligible Muslim must pay annually on their wealth. The word Zakat means "purification" and "growth".',
      },
      {
        'question': 'What is Nisab?',
        'answer':
            'Nisab is the minimum amount of wealth a Muslim must have before being obligated to pay Zakat. It is equivalent to 87.48 grams of gold or 612.36 grams of silver.',
      },
      {
        'question': 'How much Zakat should I pay?',
        'answer':
            'Zakat is calculated at 2.5% (1/40th) of your total zakatable assets that have been held for one lunar year (hawl).',
      },
      {
        'question': 'Which Nisab should I use - Gold or Silver?',
        'answer':
            'Scholars generally recommend using the silver Nisab threshold as it is lower, meaning more people would be eligible to pay Zakat and more needy would benefit.',
      },
      {
        'question': 'What assets are Zakatable?',
        'answer':
            'Zakatable assets include: Cash, gold, silver, business inventory, stocks, investments, and money owed to you. Personal items like home, car, and clothes are not zakatable.',
      },
      {
        'question': 'Can I deduct my debts?',
        'answer':
            'Yes, you can deduct immediate debts (due within the year) from your total assets before calculating Zakat. Long-term debts have different scholarly opinions.',
      },
      {
        'question': 'When should I pay Zakat?',
        'answer':
            'Zakat is due after one lunar year (hawl) has passed on your wealth above Nisab. Many Muslims choose to pay during Ramadan for extra blessings.',
      },
      {
        'question': 'Who can receive Zakat?',
        'answer':
            'Zakat can be given to eight categories mentioned in Quran 9:60: The poor, the needy, Zakat collectors, those whose hearts are to be reconciled, freeing slaves, those in debt, in the way of Allah, and travelers.',
      },
    ];
  }
}
