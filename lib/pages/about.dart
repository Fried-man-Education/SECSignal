import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:secsignal/prefabs/PlatformListView.dart';
import 'package:url_launcher/url_launcher.dart';

class About extends StatefulWidget {
  const About({super.key});

  @override
  _AboutState createState() => _AboutState();
}

class _AboutState extends State<About> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        bottom: false,
        child: PlatformScaffold(
          appBar: PlatformAppBar(
            title: Text(
              "About SECSignal",
              style: isCupertino(context) ? CupertinoTheme.of(context).textTheme.textStyle : Theme.of(context).textTheme.bodyMedium!,
            ),
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
            trailingActions: [
              IconButton(
                  onPressed: () async {
                    String url = "https://github.com/Fried-man";
                    final Uri _url = Uri.parse(url);
                    if (await canLaunchUrl(_url)) {
                      await launchUrl(
                        _url,
                        mode: LaunchMode.platformDefault,
                        webOnlyWindowName: kIsWeb ? '_blank' : null,
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Could not launch $url')),
                      );
                    }
                  },
                  icon: const Icon(FontAwesomeIcons.github)
              )
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.only(top: 8, left: 8, right: 8),
            child: PlatformListView(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(40.0)),
                  child: Container(
                    width: double.infinity,
                    color: const Color(0xFF000B10),
                    child: Center(
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width / 2.5,
                        child: Image.asset(
                          'assets/icon_rounded.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        children: [
                          Text(
                            "About",
                            style: PlatformProvider.of(context)!.platform == TargetPlatform.iOS ? CupertinoTheme.of(context).textTheme.navLargeTitleTextStyle : Theme.of(context).textTheme.titleLarge,
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 40),
                            child: Text(
                                "\t\t\t\tIn today's digital age, the democratization of financial data is more crucial than ever. As a college student, I have witnessed firsthand the challenges my peers and I face when attempting to access, understand, and analyze"
                                    " the vast sea of corporate filings. Platforms like BAMSEC have dominated this space, offering invaluable tools for professionals, but often come with a hefty price tag, rendering them inaccessible to young and individual investors. "
                                    "This financial gatekeeping limits the potential for informed investment decisions and hinders educational opportunities for those striving to learn more about the financial landscape. \n\t\t\t\t\"SECSignal\" was conceived as a modern "
                                    "solution to bridge this gap. By recognizing the potential of technology and artificial intelligence, this platform aspires to deliver sophisticated insights from SEC filings in a user-friendly and cost-effective manner. "
                                    "By harnessing the power of AI-driven analysis, SECSignal aims to empower its users with concise financial intelligence, making the intricate details of corporate filings more digestible. It is more than just a tool; it is a movement "
                                    "towards financial literacy and inclusivity. In a world where information is power, SECSignal strives to ensure that power is available to all."
                            ),
                          )
                        ],
                      ),
                    )
                ),

                SizedBox(
                  height: 250,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  "Packages",
                                  style: PlatformProvider.of(context)!.platform == TargetPlatform.iOS ? CupertinoTheme.of(context).textTheme.navLargeTitleTextStyle : Theme.of(context).textTheme.titleLarge,
                                  textAlign: TextAlign.center,
                                ),
                                Expanded(
                                  child: Wrap(
                                    direction: Axis.vertical,
                                    clipBehavior: Clip.antiAliasWithSaveLayer,
                                    children: [
                                      for (String library in [
                                        'cupertino_icons',
                                        'flutter_platform_widgets',
                                        'http',
                                        'auto_size_text',
                                        'url_launcher',
                                        'intl',
                                        'font_awesome_flutter',
                                        'package_info_plus',
                                        'firebase_core',
                                        'firebase_auth',
                                        'cloud_firestore',
                                        'yahoo_finance_data_reader',
                                        'fl_chart'
                                      ])
                                        Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 40),
                                          child: RichText(
                                            text: TextSpan(
                                                style: PlatformProvider.of(context)!.platform == TargetPlatform.iOS ? CupertinoTheme.of(context).textTheme.textStyle : Theme.of(context).textTheme.bodyMedium,
                                                children: [
                                                  const TextSpan(
                                                    text: "- ",
                                                  ),
                                                  TextSpan(
                                                    text: library,
                                                    recognizer: TapGestureRecognizer()..onTap = () async {
                                                      final Uri _url = Uri.parse(
                                                          'https://pub.dev/packages/$library');
                                                      if (await canLaunchUrl(_url)) {
                                                        await launchUrl(
                                                          _url,
                                                          mode: LaunchMode.platformDefault,
                                                          webOnlyWindowName: kIsWeb ? '_blank' : null,
                                                        );
                                                      } else {
                                                        ScaffoldMessenger.of(context).showSnackBar(
                                                          SnackBar(content: Text('Could not launch $library')),
                                                        );
                                                      }
                                                    },
                                                    style: TextStyle(
                                                      color: Theme.of(context).primaryColor,
                                                      decoration: TextDecoration.underline,
                                                    ),
                                                  )
                                                ]
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  "APIs",
                                  style: PlatformProvider.of(context)!.platform == TargetPlatform.iOS
                                      ? CupertinoTheme.of(context).textTheme.navLargeTitleTextStyle
                                      : Theme.of(context).textTheme.titleLarge,
                                  textAlign: TextAlign.center,
                                ),
                                ...{
                                  "SEC Edgar" : "https://www.sec.gov/edgar",
                                  "Wikimedia REST API" : "https://en.wikipedia.org/api/rest_v1/",
                                  "Finnhub" : "https://finnhub.io",
                                  "Clearbit Logo API" : "https://clearbit.com/logo",
                                  "Yahoo Finance API" : "https://finance.yahoo.com/"
                                }.entries.map((entry) => Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 40),
                                  child: RichText(
                                    text: TextSpan(
                                      style: PlatformProvider.of(context)!.platform == TargetPlatform.iOS
                                          ? CupertinoTheme.of(context).textTheme.textStyle
                                          : Theme.of(context).textTheme.bodyMedium,
                                      children: [
                                        const TextSpan(text: "- "),
                                        TextSpan(
                                          text: entry.key,
                                          recognizer: TapGestureRecognizer()..onTap = () async {
                                            final Uri _url = Uri.parse(entry.value);
                                            if (await canLaunchUrl(_url)) {
                                              await launchUrl(
                                                _url,
                                                mode: LaunchMode.platformDefault,
                                                webOnlyWindowName: kIsWeb ? '_blank' : null,
                                              );
                                            } else {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(content: Text('Could not launch ${entry.key}')),
                                              );
                                            }
                                          },
                                          style: TextStyle(
                                            color: Theme.of(context).primaryColor,
                                            decoration: TextDecoration.underline,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                FutureBuilder<String>(
                    future: getVersion(),
                    builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                      return Text(
                        'SECSignal ${snapshot.hasData ? "${snapshot.data!} 💸" : 'unknown'}\nMade in Atlanta, GA',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      );
                    }
                ),
                SizedBox(
                  height: 20,
                )
              ],
            ),
          ),
        )
    );
  }

  Future<String> getVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    return "v${packageInfo.version}${packageInfo.buildNumber != "0" ?  " (${packageInfo.buildNumber})" : ""}";
  }
}
