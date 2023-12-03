import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:secsignal/prefabs/PlatformListView.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        bottom: false,
        child: PlatformScaffold(
          appBar: PlatformAppBar(
            title: const Text("Settings"),
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
          body: Padding(
            padding: const EdgeInsets.only(top: 8, left: 8, right: 8),
            child: PlatformListView(
              children: [
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
                                  "Account Actions",
                                  style: PlatformProvider.of(context)!.platform == TargetPlatform.iOS ? CupertinoTheme.of(context).textTheme.navLargeTitleTextStyle : Theme.of(context).textTheme.titleLarge,
                                  textAlign: TextAlign.center,
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: PlatformElevatedButton(
                                    onPressed: () async {
                                      await FirebaseAuth.instance.signOut();
                                      Navigator.pop(context, true);
                                    },
                                    child: Text("Sign Out"),
                                  ),
                                ),
                                for (String label in ["Reset Email", "Delete Account"])
                                  Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: PlatformElevatedButton(
                                      onPressed: () {
                                        print("placeholder");
                                      },
                                      child: Text(label),
                                    ),
                                  )
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
                                  "User Data",
                                  style: PlatformProvider.of(context)!.platform == TargetPlatform.iOS
                                      ? CupertinoTheme.of(context).textTheme.navLargeTitleTextStyle
                                      : Theme.of(context).textTheme.titleLarge,
                                  textAlign: TextAlign.center,
                                ),
                                for (String label in ["Change Name", "Clear Favorites"])
                                  Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: PlatformElevatedButton(
                                      onPressed: () {
                                        print("placeholder");
                                      },
                                      child: Text(label),
                                    ),
                                  )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        )
    );
  }
}
