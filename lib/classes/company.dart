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
      int cikStr = value['cik_str'];
      _companyDataCache![ticker] = value;
      _companyDataCache![cikStr.toString()] = value;
    });
  }

  static Future<Company> fromTicker(String ticker) async {
    return fromKey(ticker);
  }

  static Future<Company> fromCikStr(String cikStr) async {
    return fromKey(int.parse(cikStr).toString());
  }

  static Future<Company> fromKey(String key) async {
    if (_companyDataCache == null) {
      await _fetchCompanyData();
    }

    if (_companyDataCache!.containsKey(key)) {
      final data = _companyDataCache![key];
      return Company(
        cikStr: data['cik_str'],
        ticker: data['ticker'],
        title: data['title'],
      );
    } else {
      throw Exception('Company with key $key not found');
    }
  }

  @override
  String toString() {
    return 'Company{cikStr: $cikStr, ticker: $ticker, title: $title}';
  }
}