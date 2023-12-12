import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../secrets.dart';

class News {
  final String? category; // Made optional
  final int datetime;
  final String headline;
  final int id;
  final String image;
  final String related;
  final String source;
  final String summary;
  final String url;

  // Company-specific attributes
  final String? symbol;
  final String? from;
  final String? to;

  News({
    this.category,
    required this.datetime,
    required this.headline,
    required this.id,
    required this.image,
    required this.related,
    required this.source,
    required this.summary,
    required this.url,
    this.symbol,
    this.from,
    this.to,
  });

  factory News.fromJson(Map<String, dynamic> json) {
    return News(
      category: json['category'],
      datetime: json['datetime'],
      headline: json['headline'],
      id: json['id'],
      image: json['image'],
      related: json['related'],
      source: json['source'],
      summary: json['summary'],
      url: json['url'],
      symbol: json['symbol'],
      from: json['from'],
      to: json['to'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'category': category,
      'datetime': datetime,
      'headline': headline,
      'id': id,
      'image': image,
      'related': related,
      'source': source,
      'summary': summary,
      'url': url,
      'symbol': symbol,
      'from': from,
      'to': to,
    };
  }
}

enum MarketNewsCategory { general, forex, crypto, merger }

extension MarketNewsCategoryExtension on MarketNewsCategory {
  String get value {
    return this.toString().split('.').last;
  }
}

class NewsService {
  static const String baseUrl = 'https://finnhub.io/api/v1';
  final Map<String, List<News>> _newsCache = {};

  Future<List<News>> getMarketNews(
      [MarketNewsCategory category = MarketNewsCategory.general]) async {
    final String cacheKey = 'market-${category.value}';

    if (_newsCache.containsKey(cacheKey)) {
      return _newsCache[cacheKey]!;
    }

    final response = await http.get(
      Uri.parse(
          '$baseUrl/news?category=${category.value}&token=$apiFinnhubKey'),
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      List<News> newsList = data.map((json) => News.fromJson(json)).toList();
      _newsCache[cacheKey] = newsList;
      return newsList;
    } else {
      throw Exception('Failed to load market news');
    }
  }

  Future<List<News>> getCompanyNews(
      {required String symbol,
      required DateTime from,
      required DateTime to}) async {
    final String formattedFromDate = DateFormat('yyyy-MM-dd').format(from);
    final String formattedToDate = DateFormat('yyyy-MM-dd').format(to);
    final String cacheKey = '$symbol-$formattedFromDate-$formattedToDate';

    // Return cached data if available
    if (_newsCache.containsKey(cacheKey)) {
      return _newsCache[cacheKey]!;
    }

    // Fetch data if not in cache
    final response = await http.get(
      Uri.parse(
          '$baseUrl/company-news?symbol=$symbol&from=$formattedFromDate&to=$formattedToDate&token=$apiFinnhubKey'),
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      List<News> newsList = data.map((json) => News.fromJson(json)).toList();

      // Cache the data
      _newsCache[cacheKey] = newsList;

      return newsList;
    } else {
      throw Exception('Failed to load company news');
    }
  }
}
