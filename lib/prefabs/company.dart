import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import '../classes/company.dart';
import '../pages/company.dart';
import '../prefabs/PreviewCard.dart';

class CompanySection extends StatefulWidget {
  final Future<List<Company>> companies;
  final String title; // Title string
  final String description; // Description string with a default empty value
  final VoidCallback onFavoriteChanged;

  CompanySection(
      {super.key,
      required this.companies,
      required this.title,
      this.description = '',
      this.onFavoriteChanged = _defaultOnFavoriteChanged});

  static void _defaultOnFavoriteChanged() {
    // This is an empty function that does nothing
  }

  @override
  _CompanySectionState createState() => _CompanySectionState();
}

class _CompanySectionState extends State<CompanySection> {
  final ScrollController _controller = ScrollController();

  late Future<List<Company>> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.companies;
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> content = [
      Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Text(
            widget.title,
            style: PlatformProvider.of(context)!.platform == TargetPlatform.iOS
                ? CupertinoTheme.of(context).textTheme.navLargeTitleTextStyle
                : Theme.of(context).textTheme.titleLarge,
          ),
        ),
      ),
      if (widget.description.isNotEmpty)
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Text(widget.description,
                style:
                    PlatformProvider.of(context)!.platform == TargetPlatform.iOS
                        ? CupertinoTheme.of(context)
                            .textTheme
                            .textStyle
                            .copyWith(color: Colors.grey)
                        : Theme.of(context).textTheme.headlineMedium!),
          ),
        ),
    ];

    return FutureBuilder<List<Company>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.hasError) return Container();

        if (snapshot.connectionState == ConnectionState.waiting) {
          content.add(SizedBox(
              height: 500,
              child: Center(child: PlatformCircularProgressIndicator(
                material: (_, __) =>
                    MaterialProgressIndicatorData(
                      valueColor:
                      AlwaysStoppedAnimation<Color>(
                          Theme.of(context).primaryColor),
                    ),
              ))));
        }else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Container();
        }else {
          content.add(SizedBox(
            height: 500,
            child: GestureDetector(
              onHorizontalDragUpdate: (details) {
                _controller.jumpTo(_controller.offset - details.delta.dx);
              },
              child: ListView.builder(
                controller: _controller,
                scrollDirection: Axis.horizontal,
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  Company company = snapshot.data![index];
                  return Padding(
                    padding: EdgeInsets.only(left: index == 0 ? 8.0 : 0.0),
                    child: CompanyCard(
                        company: company,
                        onFavoriteChanged: widget.onFavoriteChanged),
                  );
                },
              ),
            ),
          ));
        }

        return Column(
          children: content,
        );
      },
    );
  }
}

class CompanyCard extends StatefulWidget {
  final Company company;
  final VoidCallback onFavoriteChanged;

  const CompanyCard(
      {super.key, required this.company, required this.onFavoriteChanged});

  @override
  _CompanyCardState createState() => _CompanyCardState();
}

class _CompanyCardState extends State<CompanyCard> {
  late Future<FinnhubProfile?> _profileFuture;
  late Future<String> _descriptionFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = widget.company.getFinnhubProfile();
    _descriptionFuture = widget.company.getCompanyDescription();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context)
            .push(
          platformPageRoute(
            context: context,
            builder: (_) => CompanyProfile(company: widget.company),
          ),
        )
            .then((value) {
          if (value is bool && value) {
            widget.onFavoriteChanged();
          }
        });
      },
      child: PreviewCard(
        header: buildHeader(context),
        title: widget.company.getName(),
        footer: buildFooter(),
      ),
    );
  }

  Widget buildHeader(BuildContext context) {
    return FutureBuilder<FinnhubProfile?>(
      future: _profileFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return buildPlaceholder(context, true);
        } else if (snapshot.hasError ||
            !snapshot.hasData ||
            snapshot.data!.getLogo() == null) {
          return buildPlaceholder(context, false);
        } else {
          return Image.network(
            snapshot.data!.getLogo()!,
            fit: BoxFit.cover,
            height: 250,
            width: 250,
            loadingBuilder: (BuildContext context, Widget child,
                ImageChunkEvent? loadingProgress) {
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
    return FutureBuilder<String>(
      future: _descriptionFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show a placeholder or loading indicator while waiting for the data
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: PlatformCircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          // Show an error message if something went wrong
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('Error loading description'),
          );
        } else if (!snapshot.hasData ||
            snapshot.data ==
                "Failed to load description. HTTP Status Code: 404") {
          // Handle the case where no description is available
          return Container();
        } else {
          // Display the description
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: AutoSizeText(
              snapshot.data!,
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
      },
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
                  valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).cardColor),
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
}
