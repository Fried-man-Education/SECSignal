import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import '../classes/company.dart';
import '../main.dart';
import 'company.dart';

class CompanySearch extends StatefulWidget {
  @override
  _CompanySearchState createState() => _CompanySearchState();
}

class _CompanySearchState extends State<CompanySearch> {
  Timer? _debounce;
  List<Company> searchResults = [];

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void onSearchChanged(String query) {
    // Cancel any existing timers
    _debounce?.cancel();

    // Set a new timer
    _debounce =
        Timer(Duration(milliseconds: query.isNotEmpty ? 500 : 0), () async {
      var results = await Company.searchCompanies(query);
      if (mounted) {
        // Check if the widget is still in the tree
        setState(() {
          searchResults = results;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: SafeArea(
          bottom: false,
          child: PlatformScaffold(
            appBar: PlatformAppBar(
              title: Text(
                "Search Company",
                style: isCupertino(context)
                    ? CupertinoTheme.of(context).textTheme.textStyle
                    : Theme.of(context).textTheme.bodyMedium!,
              ),
              backgroundColor: Theme.of(context).canvasColor,
              material: (_, __) => MaterialAppBarData(
                leading: IconButton(
                  icon: Icon(Icons.arrow_back,
                      color: Theme.of(context).primaryColor),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
              cupertino: (_, __) => CupertinoNavigationBarData(
                leading: CupertinoNavigationBarBackButton(
                  color: Theme.of(context).primaryColor,
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
            ),
            body: Padding(
              padding: const EdgeInsets.only(top: 8, left: 8, right: 8),
              child: Column(
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: PlatformTextField(
                        cupertino: (_, __) => CupertinoTextFieldData(
                          placeholder: "Search by Name, CIK, or Ticker",
                          padding: const EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            border: Border.all(color: borderColor),
                          ),
                          prefix: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8.0),
                            child:
                                Icon(CupertinoIcons.search, color: Colors.grey),
                          ),
                        ),
                        material: (_, __) => MaterialTextFieldData(
                          decoration: InputDecoration(
                            hintText: "Search by Name, CIK, or Ticker",
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: borderColor),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context).primaryColor),
                            ),
                            isDense: true,
                            prefixIcon:
                                const Icon(Icons.search, color: Colors.grey),
                          ),
                        ),
                        onChanged: onSearchChanged,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: searchResults.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              platformPageRoute(
                                context: context,
                                builder: (_) => CompanyProfile(
                                    company: searchResults[index]),
                              ),
                            );
                          },
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "${searchResults[index].title} (${searchResults[index].ticker})",
                                    style: PlatformProvider.of(context)!
                                                .platform ==
                                            TargetPlatform.iOS
                                        ? CupertinoTheme.of(context)
                                            .textTheme
                                            .navLargeTitleTextStyle
                                        : Theme.of(context)
                                            .textTheme
                                            .titleLarge,
                                  ),
                                  Text(
                                    "Central Index Key (CIK): ${searchResults[index].cikStr}",
                                  ),
                                ],
                              ), // Customize as per your Company class
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          )),
    );
  }
}
