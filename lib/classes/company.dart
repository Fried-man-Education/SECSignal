import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;

import '../main.dart';
import '../secrets.dart';

class Company {
  int? cikStr;
  String? ticker;
  String? title;
  String? description;
  FinnhubProfile? profile;

  Company({this.cikStr, required this.ticker, this.title, this.description, this.profile});

  

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

  Map<String, dynamic> toMap() {
    return {
      'cikStr': cikStr,
      'ticker': ticker,
      'title': title,
      'description': description,
      'profile': profile?.toMap(), // Assuming FinnhubProfile has a toMap method
    };
  }

  Map<String, dynamic> toMapFirebase() {
    return {
      'cikStr': cikStr,
      'ticker': ticker,
      'title': title,
    };
  }

  factory Company.fromMap(Map<String, dynamic> map) {
    return Company(
      cikStr: map['cikStr'] as int?,
      ticker: map['ticker'] as String?,
      title: map['title'] as String?,
      description: map['description'] as String?,
      profile: map['profile'] != null ? FinnhubProfile.fromJson(map['profile']) : null,
    );
  }

  // Override == operator
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Company &&
        other.ticker == ticker &&
        other.title == title &&
        other.cikStr == cikStr;
  }

  // Override hashCode
  @override
  int get hashCode => Object.hash(ticker, title, cikStr);

  // Method to search companies by string
  static Future<List<Company>> searchCompanies(String query) async {
    if (query.isEmpty) return [];

    if (_companyDataCache == null || _companyDataCache!.isEmpty) {
      await _fetchCompanyData();
    }

    // Updated helper function to check if all characters of 'small' are in 'large' with correct frequency
    bool _isSubset(String small, String large) {
      var countMap = Map<String, int>();

      for (var char in large.split('')) {
        countMap[char] = (countMap[char] ?? 0) + 1;
      }

      for (var char in small.split('')) {
        if (!countMap.containsKey(char) || countMap[char] == 0) {
          return false;
        }
        countMap[char] = countMap[char]! - 1;
      }

      return true;
    }

    // Convert the query to lowercase
    String lowerQuery = query.toLowerCase();

    Set<Company> matches = {};
    _companyDataCache!.forEach((key, value) {
      // Convert each field to lowercase
      String lowerTicker = value['ticker']?.toLowerCase() ?? '';
      String lowerTitle = value['title']?.toLowerCase() ?? '';
      String lowerCikStr = value['cik_str'].toString().toLowerCase();

      // Check if the query is a subset of any field
      if (_isSubset(lowerQuery, lowerTicker) || _isSubset(lowerQuery, lowerTitle) || _isSubset(lowerQuery, lowerCikStr)) {
        matches.add(Company(
          cikStr: value['cik_str'],
          ticker: value['ticker'],
          title: value['title'],
        ));
      }
    });

    // Updated function to calculate similarity score with emphasis on exact matches
    double _similarityScore(String query, String s) {
      if (s == query) return double.maxFinite; // Maximum score for exact matches

      int score = 0;
      int lastIndex = -1;
      for (var char in query.split('')) {
        int index = s.indexOf(char, lastIndex + 1);
        if (index != -1) {
          score += (s.length - index); // Higher score for characters closer to start
          lastIndex = index;
        }
      }
      return score / s.length; // Normalize by string length
    }

    // Calculate and sort by total score
    var matchesList = matches.toList();
    matchesList.sort((a, b) {
      double scoreA = _similarityScore(lowerQuery, a.ticker?.toLowerCase() ?? '') +
          _similarityScore(lowerQuery, a.title?.toLowerCase() ?? '') +
          _similarityScore(lowerQuery, a.cikStr.toString());
      double scoreB = _similarityScore(lowerQuery, b.ticker?.toLowerCase() ?? '') +
          _similarityScore(lowerQuery, b.title?.toLowerCase() ?? '') +
          _similarityScore(lowerQuery, b.cikStr.toString());
      return scoreB.compareTo(scoreA);
    });

    return matchesList;
  }

  static Future<List<Company>> searchCompaniesByTickers(List<String> tickers) async {
    if (tickers.isEmpty) return [];

    if (_companyDataCache == null || _companyDataCache!.isEmpty) {
      await _fetchCompanyData();
    }

    Set<Company> matches = {};

    // Iterate over each ticker in the list
    for (var ticker in tickers) {
      // Convert the ticker to lowercase for case-insensitive comparison
      String lowerTicker = ticker.toLowerCase();

      // Search for exact matches in the ticker field
      _companyDataCache!.forEach((key, value) {
        String lowerCacheTicker = value['ticker']?.toLowerCase() ?? '';
        if (lowerCacheTicker == lowerTicker) {
          matches.add(Company(
            cikStr: value['cik_str'],
            ticker: value['ticker'],
            title: value['title'],
          ));
        }
      });
    }

    return matches.toList();
  }

  @override
  String toString() {
    return 'Company{cikStr: $cikStr, ticker: $ticker, title: $title}';
  }

  Future<List<Company>> fetchPeerCompanies() async {
    List<String> companySymbols = [];
    final response = await http.get(
      Uri.parse('https://finnhub.io/api/v1/stock/peers?symbol=$ticker&token=$apiFinnhubKey'),
    );

    if (response.statusCode == 200) {
      companySymbols = List<String>.from(json.decode(response.body));
      companySymbols.removeWhere((temp) => temp == ticker);
    } else {
      throw Exception('Failed to load company peers');
    }

    List<Company> output = [];
    companySymbols.forEach((ticker) async {
      try {
        Company company = await Company.fromTicker(ticker);
        output.add(company);
      } catch (e) {
        print('Error fetching company with ticker $ticker: $e');
        // Handle the exception or log it
      }
    });
    return output;
  }

  static Future<List<Company>> fetchRandomCompanies(int count) async {
    List<Company> companies = [];
    for (int i = 0; i < count; i++) {
      Company company = await Company.randomCompany();
      companies.add(company);
    }
    return companies;
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