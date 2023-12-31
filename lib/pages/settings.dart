import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:intl/intl.dart';
import 'package:secsignal/main.dart';
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
            title: Text(
              "Settings",
              style: isCupertino(context)
                  ? CupertinoTheme.of(context).textTheme.textStyle
                  : Theme.of(context).textTheme.bodyMedium!,
            ),
            backgroundColor: Theme.of(context).canvasColor,
            material: (_, __) => MaterialAppBarData(
              leading: IconButton(
                icon: Icon(Icons.arrow_back,
                    color: Theme.of(context).primaryColor),
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
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          "User Info",
                          style: PlatformProvider.of(context)!.platform ==
                                  TargetPlatform.iOS
                              ? CupertinoTheme.of(context)
                                  .textTheme
                                  .navLargeTitleTextStyle
                              : Theme.of(context).textTheme.titleLarge,
                          textAlign: TextAlign.center,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            "- Name: ${userDoc!.name}",
                            style: PlatformProvider.of(context)!.platform ==
                                    TargetPlatform.iOS
                                ? CupertinoTheme.of(context).textTheme.textStyle
                                : Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            "- Email: ${FirebaseAuth.instance.currentUser!.email!}",
                            style: PlatformProvider.of(context)!.platform ==
                                    TargetPlatform.iOS
                                ? CupertinoTheme.of(context).textTheme.textStyle
                                : Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            "- Account Created: ${DateFormat("MMMM d, yyyy").format(FirebaseAuth.instance.currentUser!.metadata.creationTime!)}",
                            style: PlatformProvider.of(context)!.platform ==
                                    TargetPlatform.iOS
                                ? CupertinoTheme.of(context).textTheme.textStyle
                                : Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            "- User ID: ${FirebaseAuth.instance.currentUser!.uid}",
                            style: PlatformProvider.of(context)!.platform ==
                                    TargetPlatform.iOS
                                ? CupertinoTheme.of(context).textTheme.textStyle
                                : Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
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
                                  "Account Actions",
                                  style: isCupertino(context)
                                      ? CupertinoTheme.of(context)
                                          .textTheme
                                          .navLargeTitleTextStyle
                                      : Theme.of(context).textTheme.titleLarge,
                                  textAlign: TextAlign.center,
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: PlatformElevatedButton(
                                    color: Theme.of(context).primaryColor,
                                    onPressed: () async {
                                      await FirebaseAuth.instance.signOut();
                                      userDoc = null;
                                      Navigator.pop(context, true);
                                    },
                                    child: Text(
                                      "Sign Out",
                                      style: TextStyle(
                                        color: Theme.of(context).cardColor
                                      )
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: PlatformElevatedButton(
                                    color: Theme.of(context).primaryColor,
                                    onPressed: () async {
                                      await FirebaseAuth.instance
                                          .sendPasswordResetEmail(
                                              email: FirebaseAuth
                                                  .instance.currentUser!.email!)
                                          .then((value) {
                                        showPlatformDialog<void>(
                                          context: context,
                                          builder: (_) => PlatformAlertDialog(
                                            title: Text(
                                              "Password Reset Email Sent",
                                              style: isCupertino(context)
                                                  ? CupertinoTheme.of(context)
                                                  .textTheme
                                                  .navLargeTitleTextStyle
                                                  : Theme.of(context).textTheme.titleLarge,
                                            ),
                                            actions: <Widget>[
                                              PlatformTextButton(
                                                child: Text(
                                                    'OK',
                                                  style: isMaterial(context) ? TextStyle(
                                                      color: Theme.of(context).primaryColor
                                                  ) : null,
                                                ),
                                                onPressed: () =>
                                                    Navigator.pop(context),
                                              ),
                                            ],
                                          ),
                                        );
                                      });
                                    },
                                    child: Text(
                                      "Reset Password",
                                      style: TextStyle(
                                          color: Theme.of(context).cardColor
                                      )
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: PlatformElevatedButton(
                                    color: Theme.of(context).primaryColor,
                                    onPressed: () async {
                                      try {
                                        // Get the current user
                                        User? user =
                                            FirebaseAuth.instance.currentUser;

                                        if (user != null) {
                                          // Delete the user document from Firestore
                                          await FirebaseFirestore.instance
                                              .collection('users')
                                              .doc(user.uid)
                                              .delete();

                                          // Delete the user's authentication account
                                          await user.delete();

                                          userDoc = null;

                                          showPlatformDialog<void>(
                                            context: context,
                                            builder: (_) => PlatformAlertDialog(
                                              title:
                                                  Text(
                                                    "Account Deleted",
                                                    style: isCupertino(context)
                                                        ? CupertinoTheme.of(context)
                                                        .textTheme
                                                        .navLargeTitleTextStyle
                                                        : Theme.of(context).textTheme.titleLarge,
                                                  ),
                                              actions: <Widget>[
                                                PlatformTextButton(
                                                  child: Text(
                                                    'OK',
                                                    style: isMaterial(context) ? TextStyle(
                                                        color: Theme.of(context).primaryColor
                                                    ) : null,
                                                  ),
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                    Navigator.pop(
                                                        context, true);
                                                  },
                                                ),
                                              ],
                                            ),
                                          );
                                        }
                                      } on FirebaseAuthException catch (e) {
                                        print(
                                            'Error deleting user: ${e.message}');
                                        // Handle the auth delete error here
                                      } on FirebaseException catch (e) {
                                        print(
                                            'Error deleting user document: ${e.message}');
                                        // Handle the Firestore delete error here
                                      } catch (e) {
                                        print('Unknown error: $e');
                                        // Handle any other errors here
                                      }
                                    },
                                    child: Text(
                                      "Delete Account",
                                      style: TextStyle(
                                          color: Theme.of(context).cardColor
                                      )
                                    ),
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
                                  style: PlatformProvider.of(context)!
                                              .platform ==
                                          TargetPlatform.iOS
                                      ? CupertinoTheme.of(context)
                                          .textTheme
                                          .navLargeTitleTextStyle
                                      : Theme.of(context).textTheme.titleLarge,
                                  textAlign: TextAlign.center,
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: PlatformElevatedButton(
                                    color: Theme.of(context).primaryColor,
                                    onPressed: () async {
                                      String name = userDoc!.name;
                                      await userDoc!.changeName(context);

                                      if (name != userDoc!.name) {
                                        setState(() {});
                                      }
                                    },
                                    child: Text(
                                      "Change Name",
                                      style: TextStyle(
                                          color: Theme.of(context).cardColor
                                      )
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: PlatformElevatedButton(
                                    color: Theme.of(context).primaryColor,
                                    onPressed: () async {
                                      try {
                                        await FirebaseFirestore.instance
                                            .collection('users')
                                            .doc(FirebaseAuth
                                                .instance.currentUser!.uid)
                                            .update({'bookmarked': []});

                                        // Show platform dialog after successfully clearing favorites
                                        showPlatformDialog(
                                          context: context,
                                          builder: (_) => PlatformAlertDialog(
                                            title: Text(
                                              "Favorites Cleared",
                                              style: isCupertino(context)
                                                  ? CupertinoTheme.of(context)
                                                  .textTheme
                                                  .navLargeTitleTextStyle
                                                  : Theme.of(context).textTheme.titleLarge,
                                            ),
                                            content: Text(
                                              "Your favorites have been successfully cleared.",
                                              style: isCupertino(context)
                                                  ? CupertinoTheme.of(context)
                                                  .textTheme
                                                  .textStyle
                                                  : Theme.of(context).textTheme.bodyMedium,
                                              textAlign: TextAlign.center,
                                            ),
                                            actions: <Widget>[
                                              PlatformTextButton(
                                                child: Text(
                                                  'OK',
                                                  style: isMaterial(context) ? TextStyle(
                                                      color: Theme.of(context).primaryColor
                                                  ) : null,
                                                ),
                                                onPressed: () =>
                                                    Navigator.of(context).pop(),
                                              ),
                                            ],
                                          ),
                                        );
                                      } catch (e) {
                                        // Handle the error here, if the update fails
                                        print('Error clearing favorites: $e');
                                      }
                                    },
                                    child: Text(
                                      "Clear Favorites",
                                      style: TextStyle(
                                          color: Theme.of(context).cardColor
                                      )
                                    ),
                                  ),
                                ),
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
        ));
  }
}
