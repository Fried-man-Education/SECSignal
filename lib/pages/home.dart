import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:auto_size_text/auto_size_text.dart';

import '../classes/company.dart';
import '../prefabs/PlatformListView.dart';
import '../prefabs/PreviewCard.dart';
import 'company.dart';

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
                  print('Search');
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
                  print('About');
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
                  print('Login');
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
                    for (int i = 0; i < 4; i++) ...[
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 20),
                          child: Text(
                            ["Your Companies", "Trending This Week", "Recommended Companies For Andrew Friedman", "All Time Popular"][i],
                            style: const TextStyle(
                              fontSize: 24.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 500,
                        child: FutureBuilder<List<Company>>(
                          future: _fetchRandomCompanies(12),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return Center(child: PlatformCircularProgressIndicator());
                            } else if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            } else if (snapshot.hasData) {
                              return CompanySection(companies: snapshot.data!);
                            } else {
                              return const Text('No companies found');
                            }
                          },
                        ),
                      ),
                    ]
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

class CompanySection extends StatelessWidget {
  final List<Company> companies;

  CompanySection({super.key, required this.companies});

  final ScrollController _controller = ScrollController();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        _controller.jumpTo(_controller.offset - details.delta.dx);
      },
      child: ListView.builder(
        controller: _controller,
        scrollDirection: Axis.horizontal,
        itemCount: companies.length,
        primary: false,
        itemBuilder: (context, index) {
          Company company = companies[index];
          return FutureBuilder<String>(
            future: company.getCompanyDescription(),
            builder: (context, snapshot) {
              String description = snapshot.data ?? 'Description not available';

              // Check if the current item is the first one
              if (index == 0) {
                // Add left padding to the first item
                return Padding(
                  padding: const EdgeInsets.only(left: 8.0), // Adjust the padding value as needed
                  child: CompanyCard(company: company, description: description),
                );
              } else {
                // For other items, no additional padding is added
                return CompanyCard(company: company, description: description);
              }
            },
          );
        },
      ),
    );
  }
}

class CompanyCard extends StatelessWidget {
  final Company company;
  final String description;

  const CompanyCard({super.key, required this.company, required this.description});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          platformPageRoute(
            context: context,
            builder: (_) => CompanyProfile(company: company),
          ),
        );
      },
      child: CompanyPrefab(
        header: buildHeader(context),
        title: company.getName(),
        footer: buildFooter(),
      ),
    );
  }

  Widget buildHeader(BuildContext context) {
    return FutureBuilder<FinnhubProfile?>(
      future: company.getFinnhubProfile(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return buildPlaceholder(context, true);
        } else if (snapshot.hasError || !snapshot.hasData || snapshot.data?.weburl == null || snapshot.data!.weburl!.isEmpty) {
          return buildPlaceholder(context, false);
        } else {
          return Image.network(
            'https://logo.clearbit.com/${Uri.parse(snapshot.data!.weburl!).host}',
            fit: BoxFit.cover,
            height: 250,
            width: 250,
            loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
              if (loadingProgress == null) return child;
              return buildPlaceholder(context, true);
            },
            errorBuilder: (context, error, stackTrace) {
              return buildPlaceholder(context, false);
            },
          );
        }
      },
    );
  }

  Widget buildFooter() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: AutoSizeText(
        description,
        minFontSize: 15,
        maxFontSize: 18,
        style: const TextStyle(
          fontSize: 18.0,
          color: Colors.grey,
        ),
        textAlign: TextAlign.left,
        maxLines: 5,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget buildPlaceholder(BuildContext context, bool isLoading) {
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
            size: 100,
            color: Theme.of(context).cardColor,
          ),
          cupertinoIcon: Icon(
            CupertinoIcons.building_2_fill,
            size: 100,
            color: Theme.of(context).cardColor,
          ),
          onPressed: null,
        ),
      ),
    );
  }
}