import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'dart:math' as math;
import '../main.dart';
import '../secrets.dart';

class News {
  final String? category;  // Made optional
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
}

enum MarketNewsCategory { general, forex, crypto, merger }

extension MarketNewsCategoryExtension on MarketNewsCategory {
  String get value {
    return this.toString().split('.').last;
  }
}

class NewsService {
  static const String baseUrl = 'https://finnhub.io/api/v1';

  Future<List<News>> getMarketNews([MarketNewsCategory category = MarketNewsCategory.general]) async {
    final response = await http.get(
      Uri.parse('$baseUrl/news?category=${category.value}&token=$apiFinnhubKey'),
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => News.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load market news');
    }
  }

  Future<List<News>> getCompanyNews(String symbol, String from, String to) async {
    final response = await http.get(
      Uri.parse('$baseUrl/company-news?symbol=$symbol&from=$from&to=$to&token=$apiFinnhubKey'),
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => News.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load company news');
    }
  }
}
