import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class Company {
  int? cikStr;
  String? ticker;
  String? title;

  Company({this.cikStr, required this.ticker, this.title});

  static Map<String, dynamic>? _companyDataCache;

  static Future<void> _fetchCompanyData() async {
    final jsonString = await rootBundle.loadString('data/company_tickers.json');
    Map<String, dynamic> jsonData = json.decode(jsonString);

    _companyDataCache = {};
    jsonData.forEach((key, value) {
      String ticker = value['ticker'];
      _companyDataCache![ticker] = value;
    });
  }

  static Future<Company> fromTicker(String ticker) async {
    if (_companyDataCache == null) {
      await _fetchCompanyData();
    }

    if (_companyDataCache!.containsKey(ticker)) {
      final data = _companyDataCache![ticker];
      return Company(
        cikStr: data['cik_str'],
        ticker: ticker,
        title: data['title'],
      );
    } else {
      throw Exception('Company with ticker $ticker not found');
    }
  }

  @override
  String toString() {
    return 'Company{cikStr: $cikStr, ticker: $ticker, title: $title}';
  }
}
