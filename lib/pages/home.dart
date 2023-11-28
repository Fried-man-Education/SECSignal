import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import '../main.dart';

class Home extends StatefulWidget {
  const Home({super.key, required this.title});

  final String title;

  @override
  State<Home> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<Home> {
  List<Map<String, String>> fakeFavorites = [
    {
      "name" : "Apple",
      "logo" : "https://static.vecteezy.com/system/resources/previews/000/249/015/non_2x/vector-modern-watercolor-colorful-headers-set-template-design.jpg",
      "description" : "Tech giant known for iPhones, Macs, and a sleek ecosystem. A favorite for many seeking both functionality and style."
    },
    {
      "name" : "Mike-Is-Soft",
      "logo" : "https://static.vecteezy.com/system/resources/previews/000/249/015/non_2x/vector-modern-watercolor-colorful-headers-set-template-design.jpg",
      "description" : "Software behemoth behind Windows, Office, and Azure. Continuously innovating and expanding its tech footprint."
    },
    {
      "name" : "Sony",
      "logo" : "https://static.vecteezy.com/system/resources/previews/000/249/015/non_2x/vector-modern-watercolor-colorful-headers-set-template-design.jpg",
      "description" : "Multinational conglomerate known for PlayStation, cameras, and entertainment. A leader in both tech and content."
    },
    {
      "name" : "Netflix",
      "logo" : "https://static.vecteezy.com/system/resources/previews/000/249/015/non_2x/vector-modern-watercolor-colorful-headers-set-template-design.jpg",
      "description" : "Streaming powerhouse with a vast library of shows and movies. Home to many binge-worthy series."
    },
    {
      "name" : "Tesla",
      "logo" : "https://static.vecteezy.com/system/resources/previews/000/249/015/non_2x/vector-modern-watercolor-colorful-headers-set-template-design.jpg",
      "description" : "Electric car and clean energy innovator. Pushing the boundaries of transportation and sustainability."
    },
    {
      "name" : "TikTok",
      "logo" : "https://static.vecteezy.com/system/resources/previews/000/249/015/non_2x/vector-modern-watercolor-colorful-headers-set-template-design.jpg",
      "description" : "Social media app focused on short, catchy videos. A cultural phenomenon among the younger generation."
    },
    {
      "name" : "Spotify",
      "logo" : "https://static.vecteezy.com/system/resources/previews/000/249/015/non_2x/vector-modern-watercolor-colorful-headers-set-template-design.jpg",
      "description" : "Music streaming service with millions of songs and playlists. Tailored listening experiences for every mood."
    }
  ];

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
              CompanySection(companies: fakeFavorites),
            ]
          ],
        ),
      ),
    );
  }
}

class CompanySection extends StatelessWidget {
  CompanySection({
    super.key,
    required this.companies,
  });

  final List<Map<String, String>> companies;
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
        child: ListView(
          controller: _controller,
          scrollDirection: Axis.horizontal,
          children: [
            for (Map<String, String> company in companies)
              SizedBox(
                width: 300,
                child: Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        company["name"]!,
                        style: const TextStyle(
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        company["description"]!,
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
                            company["logo"]!,
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
              ),
          ],
        ),
      ),
    );
  }
}