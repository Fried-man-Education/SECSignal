import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:url_launcher/url_launcher.dart';
import '../classes/news.dart';
import 'PreviewCard.dart';

class NewsSection extends StatefulWidget {
  final String title;
  final Future<List<News>> newsFuture;

  NewsSection({super.key, required this.title, required this.newsFuture});

  @override
  _NewsSectionState createState() => _NewsSectionState();
}

class _NewsSectionState extends State<NewsSection> {
  final ScrollController _controller = ScrollController();
  List<News>? newsCache;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Text(
              widget.title,
              style: const TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        SizedBox(
          height: 500,
          child: newsCache != null
              ? buildNewsList(newsCache!)
              : FutureBuilder<List<News>>(
            future: widget.newsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(child: Text('No news available.'));
              } else {
                newsCache = snapshot.data;
                return buildNewsList(newsCache!);
              }
            },
          ),
        ),
      ],
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
            valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).cardColor),
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
    return GestureDetector(
      onTap: () async {
        final Uri _url = Uri.parse(newsItem.url);
        if (await canLaunchUrl(_url)) {
          await launchUrl(
            _url,
            mode: LaunchMode.platformDefault,
            webOnlyWindowName: kIsWeb ? '_blank' : null,
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not launch ${newsItem.url}')),
          );
        }
      },
      child: CompanyPrefab(
        header: Image.network(
          newsItem.image,
          fit: BoxFit.cover,
          loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
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
          child: Text(
            newsItem.summary,
            style: const TextStyle(fontSize: 18.0, color: Colors.grey),
            maxLines: 5,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}
