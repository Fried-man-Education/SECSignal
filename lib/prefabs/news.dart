import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:url_launcher/url_launcher.dart';

import '../classes/news.dart';
import '../main.dart';
import 'PreviewCard.dart';

class NewsSection extends StatefulWidget {
  final String title;
  final String description;
  final Future<List<News>> newsFuture;

  NewsSection({
    super.key,
    required this.newsFuture,
    required this.title,
    this.description = '',
  });

  @override
  _NewsSectionState createState() => _NewsSectionState();
}

class _NewsSectionState extends State<NewsSection> {
  Future<List<News>>? _cachedNewsFuture;
  final ScrollController _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    _cachedNewsFuture = widget.newsFuture;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<News>>(
      future: _cachedNewsFuture,
      builder: (context, snapshot) {
        // Header and SizedBox are outside the data check, so they are always displayed
        List<Widget> children = [
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Text(
                widget.title,
                style:
                    isCupertino(context)
                        ? CupertinoTheme.of(context)
                            .textTheme
                            .navLargeTitleTextStyle
                        : Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ),
        ];

        // Append the description and news list to the children when data is available
        if (widget.description.isNotEmpty) {
          children.add(
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Text(
                  widget.description,
                  style: isCupertino(context)
                      ? CupertinoTheme.of(context)
                      .textTheme
                      .textStyle
                      .copyWith(color: Colors.grey)
                      : Theme.of(context).textTheme.headlineMedium!,
                ),
              ),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          children.add(SizedBox(
              height: 500,
              child: Center(child: PlatformCircularProgressIndicator(
                material: (_, __) =>
                    MaterialProgressIndicatorData(
                      valueColor:
                      AlwaysStoppedAnimation<Color>(
                          Theme.of(context).primaryColor),
                    ),
              ))));
        } else if (snapshot.hasError) {
          children.add(SizedBox(
              height: 500,
              child: Center(child: Text('Error: ${snapshot.error}'))));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          // Only return Container when there is no data
          return Container();
        } else {
          children.add(
            SizedBox(
              height: 500,
              child: buildNewsList(snapshot.data!),
            ),
          );
        }

        return Column(children: children);
      },
    );
  }

  Widget buildNewsList(List<News> newsItems) {
    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        _controller.jumpTo(_controller.offset - details.delta.dx);
      },
      child: ListView.builder(
        controller: _controller,
        scrollDirection: Axis.horizontal,
        itemCount: newsItems.length,
        primary: false,
        itemBuilder: (context, index) {
          News newsItem = newsItems[index];
          return Padding(
            padding: EdgeInsets.only(left: index == 0 ? 8.0 : 0.0),
            child: NewsCard(newsItem: newsItem),
          );
        },
      ),
    );
  }
}

class NewsCard extends StatelessWidget {
  final News newsItem;

  const NewsCard({super.key, required this.newsItem});

  Widget buildPlaceholder(BuildContext context, bool isLoading) {
    return Container(
      height: 250,
      width: 250,
      color: Theme.of(context).primaryColor,
      child: Center(
        child: isLoading
            ? PlatformCircularProgressIndicator(
                material: (_, __) => MaterialProgressIndicatorData(
                  valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).cardColor),
                ),
                cupertino: (_, __) => CupertinoProgressIndicatorData(
                  color: Theme.of(context).cardColor,
                ),
              )
            : PlatformIconButton(
                materialIcon: Icon(
                  Icons.article_outlined, // News-related icon
                  size: 150,
                  color: Theme.of(context).cardColor,
                ),
                cupertinoIcon: Icon(
                  CupertinoIcons.news, // News-related icon for Cupertino
                  size: 150,
                  color: Theme.of(context).cardColor,
                ),
                onPressed: null,
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    void showNewsDetailsPopup(News newsItem) {
      showPlatformDialog(
        context: context,
        builder: (BuildContext context) {
          return PlatformAlertDialog(
            title: Text(
              newsItem.headline,
              style: PlatformProvider.of(context)!.platform ==
                      TargetPlatform.iOS
                  ? CupertinoTheme.of(context).textTheme.navLargeTitleTextStyle
                  : Theme.of(context).textTheme.titleLarge,
            ),
            content: SizedBox(
              width: MediaQuery.of(context).size.width / 25,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius:
                          const BorderRadius.all(Radius.circular(10.0)),
                      child: Image.network(
                        newsItem.image,
                        fit: BoxFit.cover,
                        loadingBuilder: (BuildContext context, Widget child,
                            ImageChunkEvent? loadingProgress) {
                          if (loadingProgress == null) return child;
                          return buildPlaceholder(context, true);
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return buildPlaceholder(context, false);
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        formatDate(DateTime.fromMillisecondsSinceEpoch(
                            newsItem.datetime * 1000)),
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ),
                    Text(
                      newsItem.summary,
                      style: const TextStyle(fontStyle: FontStyle.italic),
                    ),
                    Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Wrap(
                          spacing: 8.0,
                          // Horizontal space between the containers
                          runSpacing: 8.0,
                          // Vertical space between the containers
                          children: newsItem
                              .toMap()
                              .entries
                              .where((entry) =>
                                  entry.value != null &&
                                  entry.value != '' &&
                                  entry.value != 'N/A' &&
                                  entry.key != "url" &&
                                  entry.key != "image" &&
                                  entry.key != "headline" &&
                                  entry.key != "summary" &&
                                  entry.key != "datetime" &&
                                  entry.key != "id")
                              .map((entry) {
                            dynamic value = entry.value;
                            return ConstrainedBox(
                              constraints: BoxConstraints(minWidth: 100),
                              // Set a minimal width for the container
                              child: Container(
                                margin: EdgeInsets.all(4.0),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 8.0, vertical: 4.0),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor,
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                child: Text(
                                  '$value',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).dialogBackgroundColor,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ))
                  ],
                ),
              ),
            ),
            actions: <Widget>[
              PlatformTextButton(
                child: Text(
                    'Close',
                  style: isMaterial(context) ? TextStyle(
                    color: Theme.of(context).primaryColor
                  ) : null,
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              PlatformTextButton(
                child: Text(
                  'Open Article',
                  style: isMaterial(context) ? TextStyle(
                      color: Theme.of(context).primaryColor
                  ) : null,
                ),
                onPressed: () async {
                  final Uri _url = Uri.parse(newsItem.url);
                  if (await canLaunchUrl(_url)) {
                    await launchUrl(
                      _url,
                      mode: LaunchMode.platformDefault,
                      webOnlyWindowName: kIsWeb ? '_blank' : null,
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('Could not launch ${newsItem.url}')),
                    );
                  }
                },
              ),
            ],
          );
        },
      );
    }

    return GestureDetector(
      onTap: () => showNewsDetailsPopup(newsItem),
      child: PreviewCard(
        header: Image.network(
          newsItem.image,
          fit: BoxFit.cover,
          loadingBuilder: (BuildContext context, Widget child,
              ImageChunkEvent? loadingProgress) {
            if (loadingProgress == null) return child;
            return buildPlaceholder(context, true);
          },
          errorBuilder: (context, error, stackTrace) {
            return buildPlaceholder(context, false);
          },
        ),
        title: newsItem.headline,
        footer: Padding(
          padding: const EdgeInsets.all(8.0),
          child: AutoSizeText(
            newsItem.summary,
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
      ),
    );
  }
}
