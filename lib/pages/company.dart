import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:url_launcher/url_launcher.dart';

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
                                    const Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        "About",
                                        style: TextStyle(
                                          fontSize: 24.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    AutoSizeText(
                                      description,
                                      style: const TextStyle(
                                        fontSize: 18.0,
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
                                                snapshot.data!.getLogo()!,
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
                                          const Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              "Full Description",
                                              style: TextStyle(
                                                fontSize: 24.0,
                                                fontWeight: FontWeight.bold,
                                              ),
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
                                                return RichText(
                                                  text: TextSpan(
                                                    style: const TextStyle(
                                                      fontSize: 18
                                                    ),
                                                    children: <TextSpan>[
                                                      TextSpan(text: "${entry.key}: "),
                                                      TextSpan(text: "${entry.value}", style: const TextStyle(color: Colors.grey)),
                                                    ],
                                                  ),
                                                );
                                              }).toList(),
                                            ),
                                          ),
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