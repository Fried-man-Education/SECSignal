import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:secsignal/prefabs/company.dart';
import 'package:secsignal/prefabs/filings.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yahoo_finance_data_reader/yahoo_finance_data_reader.dart' as yahoo;


import '../classes/company.dart';
import '../main.dart';
import '../prefabs/PlatformListView.dart';
import '../prefabs/news.dart';
import '../prefabs/stock.dart';
import '../secrets.dart';
import 'home.dart';

class CompanyProfile extends StatefulWidget {
  const CompanyProfile({super.key, required this.company});

  final Company company;

  @override
  State<CompanyProfile> createState() => _CompanyProfile();
}

class _CompanyProfile extends State<CompanyProfile> {
  bool isInitiallyFavorited = false;

  @override
  void initState() {
    super.initState();
    if (userDoc != null) {
      isInitiallyFavorited = userDoc!.isCompanyBookmarked(widget.company);
    }
  }

  @override
  Widget build(BuildContext context) {
    DateTime today = DateTime.now();

    return SafeArea(
      bottom: false,
      child: PlatformScaffold(
        appBar: PlatformAppBar(
          title: Text(widget.company.getName()),
          backgroundColor: Theme.of(context).canvasColor,
          material: (_, __) => MaterialAppBarData(
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Theme.of(context).primaryColor),
              onPressed: () {
                Navigator.pop(context, isInitiallyFavorited != userDoc!.isCompanyBookmarked(widget.company));
              },
            ),
          ),
          cupertino: (_, __) => CupertinoNavigationBarData(
            leading: CupertinoNavigationBarBackButton(
              color: Theme.of(context).primaryColor,
              onPressed: () {
                Navigator.pop(context, isInitiallyFavorited != userDoc!.isCompanyBookmarked(widget.company));
              },
            ),
          ),
          trailingActions: [
            if (userDoc != null)
              PlatformIconButton(
                padding: const EdgeInsets.all(0),
                materialIcon: Icon(
                  userDoc!.isCompanyBookmarked(widget.company) ? Icons.favorite : Icons.favorite_border,
                  color: Theme.of(context).primaryColor,
                ),
                cupertinoIcon: Icon(
                  userDoc!.isCompanyBookmarked(widget.company) ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
                ),
                onPressed: () async {
                  if (userDoc!.isCompanyBookmarked(widget.company)) {
                    // Remove from bookmarks
                    await userDoc!.removeBookmark(widget.company);
                  } else {
                    // Add to bookmarks
                    await userDoc!.addBookmark(widget.company);
                  }

                  setState(() {});
                },
              ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: PlatformListView(
                children: <Widget>[
                  FutureBuilder<String>(
                    future: widget.company.getCompanyDescription(),
                    builder: (context, snapshot) {
                      String description = snapshot.data ?? 'Description not available';

                      if (snapshot.data == "Failed to load description. HTTP Status Code: 404") return Container();

                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ClipRRect(
                          borderRadius: const BorderRadius.all(Radius.circular(10.0)),
                          child: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        "About",
                                        style: PlatformProvider.of(context)!.platform == TargetPlatform.iOS ? CupertinoTheme.of(context).textTheme.navLargeTitleTextStyle : Theme.of(context).textTheme.titleLarge,
                                      ),
                                    ),
                                    AutoSizeText(
                                      description,
                                      style: const TextStyle(
                                        color: Colors.grey
                                      ),
                                    ),
                                  ],
                                ),
                              )
                          ),
                        ),
                      );
                    },
                  ),
                  FutureBuilder<FinnhubProfile?>(
                    future: widget.company.getFinnhubProfile(),
                    builder: (context, snapshot) {
                      if (snapshot.data == null) {
                        return Container();
                      }

                      String formatKey(String key) {
                        switch (key) {
                          case 'finnhubIndustry':
                            return 'Industry';
                          case 'marketCapitalization':
                            return 'Market Capitalization';
                          case 'shareOutstanding':
                            return 'Share Outstanding';
                          default:
                            return key[0].toUpperCase() + key.substring(1); // Capitalize first letter
                        }
                      }

                      String formatValue(String key, dynamic value) {
                        if (key == 'iso' && value is String) {
                          // Format date
                          DateTime parsedDate = DateTime.parse(value);
                          return DateFormat('MMMM dd, yyyy').format(parsedDate);
                        } else if (key == 'phone' && value != null) {
                          // Format phone number
                          String rawNumber = double.parse(value).toInt().toString();
                          return '+${rawNumber.substring(0, 1)} (${rawNumber.substring(1, 4)}) ${rawNumber.substring(4, 7)}-${rawNumber.substring(7, 11)}';
                        }
                        return value.toString();
                      }

                      Widget buildPlaceholder(bool isLoading) {
                        return Container(
                          height: 250,
                          width: 250,
                          color: Theme.of(context).primaryColor,
                          child: Center(
                            child: isLoading
                                ? PlatformCircularProgressIndicator(
                              material: (_, __) => MaterialProgressIndicatorData(
                                valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).cardColor),
                              ),
                              cupertino: (_, __) => CupertinoProgressIndicatorData(
                                color: Theme.of(context).cardColor,
                              ),
                            )
                                : PlatformIconButton(
                              materialIcon: Icon(
                                Icons.business,
                                size: 150,
                                color: Theme.of(context).cardColor,
                              ),
                              cupertinoIcon: Icon(
                                CupertinoIcons.building_2_fill,
                                size: 150,
                                color: Theme.of(context).cardColor,
                              ),
                              onPressed: null,
                            ),
                          ),
                        );
                      }

                      return Padding(
                        padding: const EdgeInsets.all(8),
                        child: SizedBox(
                          height: 350,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.all(Radius.circular(10.0)),
                                child: Card(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        mainAxisAlignment: widget.company.profile!.weburl != null
                                            ? MainAxisAlignment.spaceBetween
                                            : MainAxisAlignment.center,
                                        children: [
                                          ClipRRect(
                                            borderRadius: const BorderRadius.all(Radius.circular(10.0)),
                                            child: Container(
                                              height: 250,
                                              width: 250,
                                              color: Theme.of(context).primaryColor,
                                              child: Image.network(
                                                snapshot.data!.getLogo() ?? "",
                                                fit: BoxFit.cover,
                                                width: double.infinity,
                                                loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                                                  if (loadingProgress == null) return child;
                                                  return buildPlaceholder(true);
                                                },
                                                errorBuilder: (context, error, stackTrace) {
                                                  return buildPlaceholder(false);
                                                },
                                              ),
                                            ),
                                          ),
                                          if (widget.company.profile!.weburl != null)
                                            Padding(
                                              padding: const EdgeInsets.only(top: 8),
                                              child: PlatformElevatedButton(
                                                onPressed: () async {
                                                  final Uri _url = Uri.parse(widget.company.profile!.weburl!);
                                                  if (await canLaunchUrl(_url)) {
                                                    await launchUrl(
                                                      _url,
                                                      mode: LaunchMode.platformDefault,
                                                      webOnlyWindowName: kIsWeb ? '_blank' : null,
                                                    );
                                                  } else {
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      SnackBar(content: Text('Could not launch ${widget.company.profile!.weburl!}')),
                                                    );
                                                  }
                                                },
                                                child: const Text("View Website"),
                                              ),
                                            )
                                        ],
                                      ),
                                    )
                                ),
                              ),
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.all(Radius.circular(10.0)),
                                  child: Card(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.stretch, // Aligns children to the start horizontally
                                        children: [
                                          Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              "Full Description",
                                              style: PlatformProvider.of(context)!.platform == TargetPlatform.iOS ? CupertinoTheme.of(context).textTheme.navLargeTitleTextStyle : Theme.of(context).textTheme.titleLarge,
                                            ),
                                          ),
                                          Expanded(
                                            child: Wrap(
                                              direction: Axis.vertical,
                                              alignment: WrapAlignment.spaceBetween,
                                              runSpacing: 4.0,
                                              children: widget.company.profile!.toMap().entries
                                                  .where((entry) => entry.key != 'logo' && entry.key != 'weburl')
                                                  .map((entry) {
                                                String formattedKey = formatKey(entry.key);
                                                String formattedValue = formatValue(entry.key, entry.value);
                                                return RichText(
                                                  text: TextSpan(
                                                    style: PlatformProvider.of(context)!.platform == TargetPlatform.iOS
                                                        ? CupertinoTheme.of(context).textTheme.textStyle
                                                        : Theme.of(context).textTheme.bodyMedium,
                                                    children: <TextSpan>[
                                                      TextSpan(text: "$formattedKey: "),
                                                      TextSpan(text: formattedValue, style: const TextStyle(color: Colors.grey)),
                                                    ],
                                                  ),
                                                );
                                              }).toList(),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                  ),
                  NewsSection(
                      title: "${widget.company.getName()} News",
                      newsFuture: newsController.getCompanyNews(
                          symbol: widget.company.ticker!,
                          from: DateTime(today.year - 1, today.month, today.day),
                          to: today
                      )
                  ),
                  FilingSection(
                    filings: () async {
                      await widget.company.fetchSECEdgarData();
                      List<Map<String, dynamic>> filteredFilings = [];
                      for (var filing in widget.company.secEdgar!.filings!) {
                        if (filing['form'] == '10-K' || filing['form'] == '10-Q') {
                          if (!filing.containsKey("url")) {
                            filing["url"] = widget.company.secEdgar!.getFilingURL(filing);
                          }
                          filteredFilings.add(filing);
                        }
                      }
                      return filteredFilings;
                    }(),
                    title: "10-K & 10-Q Filings",
                    description: "Annual and quarterly financial reports",
                  ),
                  CompanySection(
                    title: "${widget.company.getName()}'s Peers",
                    description: "A list of peers operating in the same country and sector/industry.",
                    companies: widget.company.fetchPeerCompanies()
                  ),
                  StockGraphCard(ticker: widget.company.ticker!),
                  FilingSection(
                    filings: () async {
                      await widget.company.fetchSECEdgarData();
                      for (var filing in widget.company.secEdgar!.filings!) {
                        if (!filing.containsKey("url")) {
                          filing["url"] = widget.company.secEdgar!.getFilingURL(filing);
                        }
                      }
                      return widget.company.secEdgar!.filings!;
                    }(), title: "All Filings"
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}