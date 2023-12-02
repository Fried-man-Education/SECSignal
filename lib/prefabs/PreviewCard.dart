import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class CompanyPrefab extends StatelessWidget {
  final Widget header;
  final String title;
  final Widget footer;

  const CompanyPrefab({
    super.key,
    required this.header,
    required this.title,
    required this.footer,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(10.0)),
        child: Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 300,
                child: Center(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(10.0)),
                    child: Container(
                        height: 250,
                        width: 250,
                        color: Theme.of(context).primaryColor,
                        child: header,
                    ),
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
                            title,
                            style: const TextStyle(
                              fontSize: 24.0,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center
                        ),
                      ),
                      Flexible(
                        child: footer,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}