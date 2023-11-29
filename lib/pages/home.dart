import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import '../classes/company.dart';
import '../main.dart';

class Home extends StatefulWidget {
  const Home({super.key, required this.title});

  final String title;

  @override
  State<Home> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<Home> {
  // Company.randomCompany().then((value) => value.getCompanyDescription().then((value) => print(value)));

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
    return PlatformScaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            Row(
              children: [
                Expanded(
                  child: PlatformTextField(
                    cupertino: (BuildContext context, PlatformTarget platformTarget) => CupertinoTextFieldData(
                      placeholder: "Search by Name, CIK, or Ticker",
                      padding: const EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        border: Border.all(color: borderColor),
                      ),
                      prefix: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        child: Icon(
                          CupertinoIcons.search,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    material: (BuildContext context, PlatformTarget platformTarget) => MaterialTextFieldData(
                      decoration: InputDecoration(
                        hintText: "Search by Name, CIK, or Ticker",
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: borderColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Theme.of(context).primaryColor),
                        ),
                        isDense: true,
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    onChanged: (value) {},
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Text(
                    'Login',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                      fontSize: 20.0,
                    ),
                  ),
                )
              ],
            ),
            for (int i = 0; i < 2; i++) ...[
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  i == 0 ? "Favorites" : "Hot",
                  style: const TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              FutureBuilder<List<Company>>(
                future: _fetchRandomCompanies(10),
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
      height: 300,
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
                return CompanyCard(company: company, description: description);
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
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              company.getName(),
              style: const TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              description,
              style: const TextStyle(
                fontSize: 18.0,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            Expanded(
              child: SizedBox(
                width: 100,
                height: 100,
                child: Image.network(
                  "https://static.vecteezy.com/system/resources/previews/000/249/015/non_2x/vector-modern-watercolor-colorful-headers-set-template-design.jpg",
                  loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                    if (loadingProgress == null) {
                      return child;
                    } else {
                      return Center(
                        child: PlatformCircularProgressIndicator(),
                      );
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}