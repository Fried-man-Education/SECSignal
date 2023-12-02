import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:secsignal/pages/search.dart';
import 'package:secsignal/pages/signed%20out/login.dart';

import '../classes/company.dart';
import '../classes/news.dart';
import '../prefabs/PlatformListView.dart';
import '../prefabs/company.dart';
import '../prefabs/news.dart';
import 'about.dart';

NewsService newsController = NewsService();

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<Home> {
  Future<List<Company>> _fetchRandomCompanies(int count) async {
    List<Company> companies = [];
    for (int i = 0; i < count; i++) {
      Company company = await Company.randomCompany();
      companies.add(company);
    }
    return companies;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: PlatformScaffold(
        body: LayoutBuilder(
          builder: (context, constraints) {
            // Check if the width is greater than the height
            bool isLandscape = constraints.maxWidth > constraints.maxHeight;

            List<Widget> navBar = [
              PlatformIconButton(
                padding: const EdgeInsets.all(0),
                materialIcon: Icon(
                  Icons.search,
                  size: (isLandscape ? MediaQuery.of(context).size.width : MediaQuery.of(context).size.height) / 32,
                  color: Theme.of(context).primaryColor,
                ),
                cupertinoIcon: Icon(
                  CupertinoIcons.search,
                  size: (isLandscape ? MediaQuery.of(context).size.width : MediaQuery.of(context).size.height) / 32,
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    platformPageRoute(
                      context: context,
                      builder: (_) => CompanySearch(),
                    ),
                  );
                },
              ),
              const Spacer(),
              PlatformIconButton(
                padding: const EdgeInsets.all(0),
                materialIcon: Icon(
                  Icons.info_outline,
                  size: (isLandscape ? MediaQuery.of(context).size.width : MediaQuery.of(context).size.height) / 32,
                  color: Theme.of(context).primaryColor,
                ),
                cupertinoIcon: Icon(
                  CupertinoIcons.info,
                  size: (isLandscape ? MediaQuery.of(context).size.width : MediaQuery.of(context).size.height) / 32,
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    platformPageRoute(
                      context: context,
                      builder: (_) => About(),
                    ),
                  );
                },
              ),
              PlatformIconButton(
                padding: const EdgeInsets.all(0),
                materialIcon: Icon(
                  Icons.person_outline, // Changed to person icon
                  size: (isLandscape ? MediaQuery.of(context).size.width : MediaQuery.of(context).size.height) / 32,
                  color: Theme.of(context).primaryColor,
                ),
                cupertinoIcon: Icon(
                  CupertinoIcons.person, // Changed to a more appropriate Cupertino icon
                  size: (isLandscape ? MediaQuery.of(context).size.width : MediaQuery.of(context).size.height) / 32,
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    platformPageRoute(
                      context: context,
                      builder: (_) => Login(),
                    ),
                  );
                },
              ),
            ];

            Widget navBarWidget = Padding(
              padding: const EdgeInsets.all(4.0),
              child: SizedBox(
                // Flip the height and width if in landscape mode
                height: isLandscape ? double.infinity : null,
                width: isLandscape ? null : double.infinity,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: isLandscape
                        ? Column(children: navBar)
                        : Row(children: navBar),
                  )
                ),
              ),
            );

            List<Widget> bodyContent = [
              navBarWidget,
              Expanded(
                child: PlatformListView(
                  children: <Widget>[
                    if (isLandscape)
                      const SizedBox(
                        height: 8,
                      ),

                    NewsSection(
                      title: "Market News",
                      description: "What's going on in the world",
                      newsFuture: newsController.getMarketNews()
                    ),

                    CompanySection(
                      companies: Company.searchCompaniesByTickers(["FND", "AAPL", "TSLA", "TTE", "GOOGL"]),
                      title: "Your Favorite Companies",
                      description: "Companies you have bookmarked",
                    ),

                    NewsSection(
                        title: "Forex News",
                        description: "The foreign exchange market is a global decentralized or over-the-counter market for the trading of currencies",
                        newsFuture: newsController.getMarketNews(MarketNewsCategory.forex)
                    ),

                    for (int i = 0; i < 3; i++) ...[
                      CompanySection(
                        companies: _fetchRandomCompanies(5),
                        title: ["Trending This Week", "Recommended Companies For Andrew Friedman", "All Time Popular"][i],
                      )
                    ],

                    NewsSection(
                        title: "Crypto News",
                        newsFuture: newsController.getMarketNews(MarketNewsCategory.crypto)
                    ),



                    NewsSection(
                        title: "Merger News",
                        newsFuture: newsController.getMarketNews(MarketNewsCategory.merger)
                    ),
                  ],
                ),
              ),
            ];

            return isLandscape
                ? Row(children: bodyContent)
                : Column(children: bodyContent);
          },
        ),
      ),
    );
  }
}