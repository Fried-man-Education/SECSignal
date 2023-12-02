import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import '../classes/company.dart';
import '../pages/company.dart';
import '../prefabs/PreviewCard.dart';

class CompanySection extends StatefulWidget {
  final Future<List<Company>> companies;
  final String title;                 // Title string
  final String description;           // Description string with a default empty value

  CompanySection({
    super.key,
    required this.companies,
    required this.title,
    this.description = ''             // Default value for description
  });

  @override
  _CompanySectionState createState() => _CompanySectionState();
}

class _CompanySectionState extends State<CompanySection> {
  final ScrollController _controller = ScrollController();

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
              style: PlatformProvider.of(context)!.platform == TargetPlatform.iOS ? CupertinoTheme.of(context).textTheme.navLargeTitleTextStyle : Theme.of(context).textTheme.titleLarge,
            ),
          ),
        ),
        if (widget.description.isNotEmpty)
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Text(
                widget.description,
                style: PlatformProvider.of(context)!.platform == TargetPlatform.iOS ? CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                  color: Colors.grey
                ) : Theme.of(context).textTheme.headlineMedium!
              ),
            ),
          ),
        FutureBuilder<List<Company>>(
          future: widget.companies,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return SizedBox(height: 500, child: Center(child: PlatformCircularProgressIndicator()));
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const SizedBox(height: 500, child: Text('No companies found'));
            } else {
              return SizedBox(
                height: 500,
                child: ListView.builder(
                  controller: _controller,
                  scrollDirection: Axis.horizontal,
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    Company company = snapshot.data![index];
                    return FutureBuilder<String>(
                      future: company.getCompanyDescription(),
                      builder: (context, descriptionSnapshot) {
                        String description = descriptionSnapshot.data ?? 'Description not available';
                        return Padding(
                          padding: EdgeInsets.only(left: index == 0 ? 8.0 : 0.0),
                          child: CompanyCard(company: company, description: description)
                        );
                      },
                    );
                  },
                ),
              );
            }
          },
        ),
      ],
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
        } else if (snapshot.hasError || !snapshot.hasData || snapshot.data!.getLogo() == null) {
          return buildPlaceholder(context, false);
        } else {
          return Image.network(
            snapshot.data!.getLogo()!,
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
    if (description == "Failed to load description. HTTP Status Code: 404") {
      return Container();
    }

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