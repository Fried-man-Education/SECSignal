import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:auto_size_text/auto_size_text.dart';

import '../classes/company.dart';
import '../classes/news.dart';
import '../prefabs/PlatformListView.dart';
import '../prefabs/news.dart';

class CompanyProfile extends StatefulWidget {
  const CompanyProfile({super.key, required this.company});

  final Company company;

  @override
  State<CompanyProfile> createState() => _CompanyProfile();
}

class _CompanyProfile extends State<CompanyProfile> {

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
        body: Column(
          children: [
            Expanded(
              child: PlatformListView(
                children: <Widget>[
                  FutureBuilder<String>(
                    future: widget.company.getCompanyDescription(),
                    builder: (context, snapshot) {
                      String description = snapshot.data ?? 'Description not available';

                      return Text(description);
                    },
                  ),
                  NewsSection(
                      title: "${widget.company.getName()} News",
                      newsFuture: NewsService().getCompanyNews(
                          symbol: widget.company.ticker!,
                          from: DateTime(today.year - 1, today.month, today.day),
                          to: today
                      )
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