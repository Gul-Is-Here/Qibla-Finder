/// Model for Zakat calculation
class ZakatCalculationModel {
  final String id;
  final DateTime date;
  final String currency;
  final double goldValue;
  final double silverValue;
  final double cashValue;
  final double investmentsValue;
  final double stocksValue;
  final double businessAssetsValue;
  final double debtsOwed; // Money owed to you
  final double debtsOwing; // Money you owe
  final double totalAssets;
  final double zakatAmount;
  final double nisabGold;
  final double nisabSilver;
  final bool meetsNisab;
  final String nisabType; // 'gold' or 'silver'

  ZakatCalculationModel({
    required this.id,
    required this.date,
    required this.currency,
    this.goldValue = 0,
    this.silverValue = 0,
    this.cashValue = 0,
    this.investmentsValue = 0,
    this.stocksValue = 0,
    this.businessAssetsValue = 0,
    this.debtsOwed = 0,
    this.debtsOwing = 0,
    required this.totalAssets,
    required this.zakatAmount,
    required this.nisabGold,
    required this.nisabSilver,
    required this.meetsNisab,
    required this.nisabType,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'date': date.toIso8601String(),
    'currency': currency,
    'goldValue': goldValue,
    'silverValue': silverValue,
    'cashValue': cashValue,
    'investmentsValue': investmentsValue,
    'stocksValue': stocksValue,
    'businessAssetsValue': businessAssetsValue,
    'debtsOwed': debtsOwed,
    'debtsOwing': debtsOwing,
    'totalAssets': totalAssets,
    'zakatAmount': zakatAmount,
    'nisabGold': nisabGold,
    'nisabSilver': nisabSilver,
    'meetsNisab': meetsNisab,
    'nisabType': nisabType,
  };

  factory ZakatCalculationModel.fromJson(Map<String, dynamic> json) {
    return ZakatCalculationModel(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      currency: json['currency'] as String,
      goldValue: (json['goldValue'] as num).toDouble(),
      silverValue: (json['silverValue'] as num).toDouble(),
      cashValue: (json['cashValue'] as num).toDouble(),
      investmentsValue: (json['investmentsValue'] as num).toDouble(),
      stocksValue: (json['stocksValue'] as num).toDouble(),
      businessAssetsValue: (json['businessAssetsValue'] as num).toDouble(),
      debtsOwed: (json['debtsOwed'] as num).toDouble(),
      debtsOwing: (json['debtsOwing'] as num).toDouble(),
      totalAssets: (json['totalAssets'] as num).toDouble(),
      zakatAmount: (json['zakatAmount'] as num).toDouble(),
      nisabGold: (json['nisabGold'] as num).toDouble(),
      nisabSilver: (json['nisabSilver'] as num).toDouble(),
      meetsNisab: json['meetsNisab'] as bool,
      nisabType: json['nisabType'] as String,
    );
  }
}

/// Currency model with symbol and conversion rate
class CurrencyModel {
  final String code;
  final String name;
  final String symbol;
  final double goldPricePerGram; // Price of gold per gram in this currency
  final double silverPricePerGram; // Price of silver per gram in this currency

  const CurrencyModel({
    required this.code,
    required this.name,
    required this.symbol,
    required this.goldPricePerGram,
    required this.silverPricePerGram,
  });
}

/// Zakat asset category
class ZakatAssetCategory {
  final String id;
  final String name;
  final String icon;
  final String description;
  final bool isDeductible;

  const ZakatAssetCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.description,
    this.isDeductible = false,
  });
}
