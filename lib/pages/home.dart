import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:auto_size_text/auto_size_text.dart';

import '../classes/company.dart';
import '../main.dart';
import '../prefabs/PlatformListView.dart';
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
                  size: MediaQuery.of(context).size.height / 32,
                  color: Theme.of(context).primaryColor,
                ),
                cupertinoIcon: Icon(
                  CupertinoIcons.search,
                  size: MediaQuery.of(context).size.height / 32,
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
                  size: MediaQuery.of(context).size.height / 32,
                  color: Theme.of(context).primaryColor,
                ),
                cupertinoIcon: Icon(
                  CupertinoIcons.info,
                  size: MediaQuery.of(context).size.height / 32,
                ),
                onPressed: () {
                  print('About');
                },
              ),
              PlatformIconButton(
                padding: const EdgeInsets.all(0),
                materialIcon: Icon(
                  Icons.person_outline, // Changed to person icon
                  size: MediaQuery.of(context).size.height / 32,
                  color: Theme.of(context).primaryColor,
                ),
                cupertinoIcon: Icon(
                  CupertinoIcons.person, // Changed to a more appropriate Cupertino icon
                  size: MediaQuery.of(context).size.height / 32,
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
                height: isLandscape ? double.infinity : 50,
                width: isLandscape ? 50 : double.infinity,
                child: Card(
                  child: isLandscape
                      ? Column(children: navBar)
                      : Row(children: navBar),
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
                      FutureBuilder<List<Company>>(
                        future: _fetchRandomCompanies(i == 0 ? 6 : 200),
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
    return SizedBox(
      width: double.infinity,
      height: 500,
      child: GestureDetector(
        onHorizontalDragUpdate: (details) {
          _controller.jumpTo(_controller.offset - details.delta.dx);
        },
        child: ListView.builder(
          controller: _controller,
          scrollDirection: Axis.horizontal,
          itemCount: companies.length,
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
    return SizedBox(
      width: 300,
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(10.0)), // Top corners rounded
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              platformPageRoute(
                context: context,
                builder: (_) => CompanyProfile(company: company),
              ),
            );
          },
          child: Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(10.0)), // Top corners rounded
                  child: SizedBox(
                    height: 300, // Fixed height for the square
                    width: 300,
                    child: Image.network(
                      "https://static.vecteezy.com/system/resources/previews/000/249/015/non_2x/vector-modern-watercolor-colorful-headers-set-template-design.jpg",
                      fit: BoxFit.cover, // Covers the box, maintaining aspect ratio, and may clip the image
                      loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                        if (loadingProgress == null) {
                          return child;
                        } else {
                          return const Center(
                            child: CircularProgressIndicator(), // Assuming you have a CircularProgressIndicator
                          );
                        }
                      },
                    ),
                  ),
                ),
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 50,
                          child: AutoSizeText(
                              company.getName(),
                              style: const TextStyle(
                                fontSize: 24.0,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center
                          ),
                        ),
                        Flexible(
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
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}