import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'dart:math' as math;
import '../main.dart';
import '../secrets.dart';

class Company {
  int? cikStr;
  String? ticker;
  String? title;
  String? description;
  FinnhubProfile? profile;

  Company({this.cikStr, required this.ticker, this.title});

  

  static Map<String, dynamic>? _companyDataCache;

  Future<FinnhubProfile?> getFinnhubProfile() async {
    if (profile != null) return profile;

    const String baseURL = 'https://finnhub.io/api/v1/stock/profile2';

    if (ticker == null) {
      throw Exception('Ticker must be provided');
    }

    String requestURL = '$baseURL?symbol=$ticker&token=$apiFinnhubKey';

    final response = await http.get(Uri.parse(requestURL));

    if (response.statusCode == 200) {
      profile = FinnhubProfile.fromJson(json.decode(response.body));
      return profile;
    } else {
      return null;
    }
  }

  static Future<void> _fetchCompanyData() async {
    final jsonString = await rootBundle.loadString('assets/data/company_tickers.json');
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
    if (description != null) {
      // Return the stored description if it's already fetched
      return description!;
    }

    if (title == null) {
      return 'No title available for the company.';
    }

    // URL encode the title
    String searchQuery = Uri.encodeComponent(title!);

    try {
      var response = await http.get(Uri.parse('https://en.wikipedia.org/api/rest_v1/page/summary/$searchQuery'));

      if (response.statusCode == 200) {
        var data = json.decode(response.body);

        // Check if the page is a disambiguation page or a redirect
        if (data['type'] == 'disambiguation' || data['type'] == 'redirect') {
          return 'Multiple entries found or redirected. Please specify the query.';
        }

        // Store the description for future use
        description = data['extract'] ?? 'No description available.';
        return description!;
      } else {
        if (response.statusCode.toString() == "404") {
          description = 'Failed to load description. HTTP Status Code: ${response.statusCode}';
        }
        // Provide more detailed error information
        return 'Failed to load description. HTTP Status Code: ${response.statusCode}';
      }
    } catch (e) {
      // Handle any exceptions that might occur during the HTTP request
      return 'An error occurred: $e';
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

class FinnhubProfile {
  String? country;
  String? currency;
  String? exchange;
  String? finnhubIndustry;
  String? ipo;
  String? logo;
  double? marketCapitalization;
  String? name;
  String? phone;
  double? shareOutstanding;
  String? ticker;
  String? weburl;

  FinnhubProfile({
    this.country,
    this.currency,
    this.exchange,
    this.finnhubIndustry,
    this.ipo,
    this.logo,
    this.marketCapitalization,
    this.name,
    this.phone,
    this.shareOutstanding,
    this.ticker,
    this.weburl,
  });

  factory FinnhubProfile.fromJson(Map<String, dynamic> json) {
    return FinnhubProfile(
      country: json['country'],
      currency: json['currency'],
      exchange: json['exchange'],
      finnhubIndustry: json['finnhubIndustry'],
      ipo: json['ipo'],
      logo: json['logo'],
      marketCapitalization: json['marketCapitalization']?.toDouble(),
      name: json['name'],
      phone: json['phone'],
      shareOutstanding: json['shareOutstanding']?.toDouble(),
      ticker: json['ticker'],
      weburl: json['weburl'],
    );
  }

  String? getLogo () => weburl != null && weburl!.isNotEmpty ? 'https://logo.clearbit.com/${Uri.parse(weburl!).host}' : null;

  Map<String, dynamic> toMap() {
    return {
      'country': country,
      'currency': currency,
      'exchange': exchange,
      'finnhubIndustry': finnhubIndustry,
      'ipo': ipo,
      'logo': logo,
      'marketCapitalization': marketCapitalization,
      'name': name,
      'phone': phone,
      'shareOutstanding': shareOutstanding,
      'ticker': ticker,
      'weburl': weburl,
    };
  }

  @override
  String toString() {
    return 'FinnhubProfile('
        'country: $country, '
        'currency: $currency, '
        'exchange: $exchange, '
        'finnhubIndustry: $finnhubIndustry, '
        'ipo: $ipo, '
        'logo: $logo, '
        'marketCapitalization: $marketCapitalization, '
        'name: $name, '
        'phone: $phone, '
        'shareOutstanding: $shareOutstanding, '
        'ticker: $ticker, '
        'weburl: $weburl'
        ')';
  }
}