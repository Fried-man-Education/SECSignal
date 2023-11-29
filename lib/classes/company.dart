import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'dart:math' as math;
import '../main.dart';

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

  static Future<Company> randomCompany() async {
    if (_companyDataCache == null || _companyDataCache!.isEmpty) {
      await _fetchCompanyData();
    }

    var random = math.Random();
    var tickers = _companyDataCache!.keys.toList();
    var randomTicker = tickers[random.nextInt(tickers.length)];
    var data = _companyDataCache![randomTicker];

    return Company(
      cikStr: data['cik_str'],
      ticker: data['ticker'],
      title: data['title'],
    );
  }

  Future<String> getCompanyDescription() async {
    if (title == null) {
      return 'No title available for the company.';
    }

    // Modify the title to improve search accuracy. This is a basic example and can be refined.
    String searchQuery = "$title";
    print(searchQuery);

    var response = await http.get(Uri.parse('https://en.wikipedia.org/api/rest_v1/page/summary/$searchQuery'));

    if (response.statusCode == 200) {
      var data = json.decode(response.body);

      // Check if the page is a disambiguation page
      if (data['type'] == 'disambiguation') {
        return 'Multiple entries found. Please specify the query.';
      }

      return data['extract'] ?? 'No description available.';
    } else {
      return 'Failed to load description.';
    }
  }

  String getName() {
    if (title == null) return '';
    // Check if the title is in all uppercase
    if (title!.toUpperCase() == title) {
      return toTitleCase(title!);
    } else {
      return title!;
    }
  }

  @override
  String toString() {
    return 'Company{cikStr: $cikStr, ticker: $ticker, title: $title}';
  }
}