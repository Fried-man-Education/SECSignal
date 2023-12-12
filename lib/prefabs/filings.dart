import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:intl/intl.dart';
import 'package:secsignal/main.dart';
import 'package:url_launcher/url_launcher.dart';
import 'PreviewCard.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';

class FilingSection extends StatefulWidget {
  final Future<List<Map<String, dynamic>>> filings;
  final String title;
  final String description;

  FilingSection({
    super.key,
    required this.filings,
    required this.title,
    this.description = '',
  });

  @override
  _FilingSectionState createState() => _FilingSectionState();
}

class _FilingSectionState extends State<FilingSection> {
  final ScrollController _controller = ScrollController();

  late Future<List<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.filings;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FutureBuilder<List<Map<String, dynamic>>>(
          future: _future,
          builder: (context, snapshot) {
            // Initialize an empty list of widgets
            List<Widget> children = [];

            // Header and description widgets, displayed in all states except error or empty data
            if (snapshot.connectionState != ConnectionState.done || (snapshot.hasData && snapshot.data!.isNotEmpty)) {
              children.add(
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: Text(
                      widget.title,
                      style: isCupertino(context) ? CupertinoTheme.of(context).textTheme.navLargeTitleTextStyle : Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                ),
              );
              if (widget.description.isNotEmpty) {
                children.add(
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: Text(
                        widget.description,
                        style: isCupertino(context) ? CupertinoTheme.of(context).textTheme.textStyle.copyWith(color: Colors.grey) : Theme.of(context).textTheme.headlineMedium!,
                      ),
                    ),
                  ),
                );
              }
            }

            // FutureBuilder states
            if (snapshot.connectionState == ConnectionState.waiting) {
              children.add(SizedBox(height: 500, child: Center(child: PlatformCircularProgressIndicator())));
            } else if (snapshot.hasError) {
              children.add(Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Container();
            } else {
              children.add(
                SizedBox(
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
                        Map<String, dynamic> filing = snapshot.data![index];
                        return Padding(
                          padding: EdgeInsets.only(left: index == 0 ? 8.0 : 0.0),
                          child: FilingCard(filing: filing),
                        );
                      },
                    ),
                  ),
                ),
              );
            }

            return Column(children: children);
          },
        ),
      ],
    );
  }
}

class FilingCard extends StatelessWidget {
  final Map<String, dynamic> filing;

  const FilingCard({super.key, required this.filing});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final Uri _url = Uri.parse(filing["url"]);
        if (await canLaunchUrl(_url)) {
          await launchUrl(
            _url,
            mode: LaunchMode.platformDefault,
            webOnlyWindowName: kIsWeb ? '_blank' : null,
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not launch ${filing["url"]}')),
          );
        }
      },
      child: PreviewCard(
        header: buildHeader(context),
        title: filing['primaryDocDescription'].isNotEmpty ? filing['primaryDocDescription'] :  "FORM ${filing['form']}",
        footer: buildFooter(),
      ),
    );
  }

  Widget buildHeader(context) {
    // Build header with relevant filing information, e.g., filing date
    return PlatformIconButton(
      materialIcon: Icon(
        Icons.insert_drive_file, // News-related icon
        size: 150,
        color: Theme.of(context).cardColor,
      ),
      cupertinoIcon: Icon(
        CupertinoIcons.doc_text, // News-related icon for Cupertino
        size: 150,
        color: Theme.of(context).cardColor,
      ),
      onPressed: null,
    );
  }

  Widget buildFooter() {
    // Build footer with additional details or a link to the filing
    return Column(
      children: [
        Text(
          formatDate(DateTime.parse(filing["acceptanceDateTime"])),
          style: const TextStyle(
              color: Colors.grey
          ),
        ),
        const Spacer(),
        Text("${filing['accessionNumber'] ?? 'No Accession Number'}"),
      ],
    );
  }
}
