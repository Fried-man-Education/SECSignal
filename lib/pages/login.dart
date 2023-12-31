import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import '../classes/user.dart';
import '../main.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  Map<String, TextEditingController> inputText = {
    "Email": TextEditingController(),
    "Password": TextEditingController()
  };

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: SafeArea(
          bottom: false,
          child: PlatformScaffold(
              appBar: PlatformAppBar(
                title: Text(
                  "Login",
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
                padding: const EdgeInsets.all(8.0),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SizedBox(
                                width: MediaQuery.of(context).size.width / 2,
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(20.0),
                                      child: Image.asset(
                                        "assets/icon_rounded.png",
                                        height: min(
                                            MediaQuery.of(context).size.width /
                                                2,
                                            MediaQuery.of(context).size.height /
                                                2),
                                        width: min(
                                            MediaQuery.of(context).size.width /
                                                2,
                                            MediaQuery.of(context).size.height /
                                                2),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8),
                                      child: TextField(
                                        controller: inputText["Email"],
                                        cursorColor: Theme.of(context).primaryColor,
                                        decoration: InputDecoration(
                                          border: OutlineInputBorder(),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Theme.of(context)
                                                    .primaryColor),
                                          ),
                                          prefixIcon: Icon(Icons.person),
                                          labelText: 'Email',
                                          labelStyle: TextStyle(
                                            color:
                                                Theme.of(context).primaryColor,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8),
                                      child: TextField(
                                        controller: inputText["Password"],
                                        obscureText: true,
                                        cursorColor: Theme.of(context).primaryColor,
                                        decoration: InputDecoration(
                                          border: OutlineInputBorder(),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Theme.of(context)
                                                    .primaryColor),
                                          ),
                                          prefixIcon: Icon(Icons.lock),
                                          labelText: 'Password',
                                          labelStyle: TextStyle(
                                            color:
                                                Theme.of(context).primaryColor,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: PlatformElevatedButton(
                                              color: Theme.of(context).primaryColor,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Text(
                                                  "Login",
                                                  style: TextStyle(
                                                      fontFamily:
                                                          'IBM_Plex_Sans',
                                                      fontSize:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width /
                                                              61,
                                                      color: Theme.of(context)
                                                          .cardColor),
                                                ),
                                              ),
                                              onPressed: () async {
                                                try {
                                                  for (String typeText
                                                      in inputText.keys) {
                                                    // null checks
                                                    if (inputText[typeText]!
                                                        .text
                                                        .isEmpty) {
                                                      throw CustomException(
                                                          'Fill in all fields');
                                                    }
                                                  }
                                                  await FirebaseAuth.instance
                                                      .signInWithEmailAndPassword(
                                                          email: inputText[
                                                                  'Email']!
                                                              .text,
                                                          password: inputText[
                                                                  'Password']!
                                                              .text)
                                                      .then((value) async {
                                                    user = FirebaseAuth
                                                        .instance.currentUser;
                                                    if (user != null &&
                                                        (user!.emailVerified ||
                                                            true)) {
                                                      /*userData =
                                                      (await FirebaseFirestore.instance
                                                          .collection("users").doc(
                                                          FirebaseAuth.instance
                                                              .currentUser!.uid).get())
                                                          .data()!;*/
                                                      userDoc = await UserDoc
                                                          .fromFirebase();
                                                      Navigator.pop(
                                                          context, true);
                                                      return;
                                                    }
                                                    throw CustomException(
                                                        "Email not verified");
                                                  });
                                                } on FirebaseAuthException catch (e) {
                                                  String error =
                                                      "Server error: ${e.code}";
                                                  if (e.code ==
                                                      'user-not-found') {
                                                    error =
                                                        'No user found for that email.';
                                                  } else if (e.code ==
                                                      'wrong-password') {
                                                    error =
                                                        'Wrong password provided for that user.';
                                                  }
                                                  createErrorScreen(error,
                                                      context, "Sign in");
                                                } on CustomException catch (e) {
                                                  if (e.cause ==
                                                      "Email not verified") {
                                                    showPlatformDialog<void>(
                                                      context: context,
                                                      builder: (_) =>
                                                          PlatformAlertDialog(
                                                        title: Text(
                                                          "Sign in Failure",
                                                          style: isCupertino(context)
                                                              ? CupertinoTheme.of(context)
                                                              .textTheme
                                                              .navLargeTitleTextStyle
                                                              : Theme.of(context).textTheme.titleLarge,
                                                        ),
                                                        content: Text(
                                                          "Verify account email",
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
                                                              'Resend Email',
                                                              style: isMaterial(context) ? TextStyle(
                                                                  color: Theme.of(context).primaryColor
                                                              ) : null,
                                                            ),
                                                            onPressed:
                                                                () async {
                                                              await user!
                                                                  .sendEmailVerification();
                                                            },
                                                          ),
                                                          PlatformTextButton(
                                                            child: Text(
                                                              'OK',
                                                              style: isMaterial(context) ? TextStyle(
                                                                  color: Theme.of(context).primaryColor
                                                              ) : null,
                                                            ),
                                                            onPressed: () =>
                                                                Navigator.pop(
                                                                    context),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                    return;
                                                  }
                                                  createErrorScreen(e.cause,
                                                      context, "Sign in");
                                                } catch (e) {
                                                  createErrorScreen(
                                                      e.toString(),
                                                      context,
                                                      "Sign in");
                                                }
                                              },
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: PlatformElevatedButton(
                                              color: Theme.of(context).primaryColor,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Text(
                                                  "Register",
                                                  style: TextStyle(
                                                      fontFamily:
                                                          'IBM_Plex_Sans',
                                                      fontSize:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width /
                                                              61,
                                                      color: Theme.of(context)
                                                          .cardColor),
                                                ),
                                              ),
                                              onPressed: () async {
                                                try {
                                                  for (String typeText
                                                      in inputText.keys) {
                                                    // null checks
                                                    if (inputText[typeText]!
                                                        .text
                                                        .isEmpty) {
                                                      throw CustomException(
                                                          'Fill in all fields');
                                                    }
                                                  }
                                                  // valid email check
                                                  String email =
                                                      inputText['Email']!.text;
                                                  if (!email.contains('@') ||
                                                      !email.contains('.') ||
                                                      email.indexOf('.') ==
                                                          (email.length - 1)) {
                                                    throw CustomException(
                                                        'Fill in a valid email');
                                                  }
                                                  // create account
                                                  await FirebaseAuth.instance
                                                      .createUserWithEmailAndPassword(
                                                          email: email,
                                                          password: inputText[
                                                                  'Password']!
                                                              .text)
                                                      .then((value) async {
                                                    user = FirebaseAuth
                                                        .instance.currentUser;
                                                    if (user != null) {
                                                      // After the user account is created successfully
                                                      user = FirebaseAuth
                                                          .instance.currentUser;
                                                      if (user != null) {
                                                        // Prompt for the user's name
                                                        String? userName =
                                                            await showPlatformDialog<
                                                                String>(
                                                          context: context,
                                                          builder: (BuildContext
                                                              context) {
                                                            String userInput =
                                                                '';
                                                            TextEditingController
                                                                textEditingController =
                                                                TextEditingController();
                                                            bool showError =
                                                                false; // To track whether to show error

                                                            return StatefulBuilder(
                                                              builder: (context,
                                                                  setState) {
                                                                return PlatformAlertDialog(
                                                                  title: Text(
                                                                    "Enter Your Name",
                                                                    style: isCupertino(context)
                                                                        ? CupertinoTheme.of(context)
                                                                        .textTheme
                                                                        .navLargeTitleTextStyle
                                                                        : Theme.of(context).textTheme.titleLarge,
                                                                  ),
                                                                  content:
                                                                      TextField(
                                                                    controller:
                                                                        textEditingController,
                                                                    onChanged:
                                                                        (value) {
                                                                      userInput =
                                                                          value;
                                                                      if (showError &&
                                                                          value
                                                                              .isNotEmpty) {
                                                                        setState(
                                                                            () {
                                                                          showError =
                                                                              false;
                                                                        });
                                                                      }
                                                                    },
                                                                    decoration:
                                                                        InputDecoration(
                                                                      hintText:
                                                                          "Name",
                                                                      errorText: showError
                                                                          ? "Please fill in the field"
                                                                          : null,
                                                                      errorBorder:
                                                                          const OutlineInputBorder(
                                                                        borderSide: BorderSide(
                                                                            color:
                                                                                Colors.red,
                                                                            width: 1),
                                                                      ),
                                                                      focusedErrorBorder:
                                                                          const OutlineInputBorder(
                                                                        borderSide: BorderSide(
                                                                            color:
                                                                                Colors.red,
                                                                            width: 2),
                                                                      ),
                                                                      focusedBorder: OutlineInputBorder(
                                                                        borderSide: BorderSide(
                                                                            color: Theme.of(context)
                                                                                .primaryColor),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  actions: <Widget>[
                                                                    PlatformTextButton(
                                                                      child: Text(
                                                                        'OK',
                                                                        style: isMaterial(context) ? TextStyle(
                                                                            color: Theme.of(context).primaryColor
                                                                        ) : null,
                                                                      ),
                                                                      onPressed:
                                                                          () {
                                                                        if (userInput
                                                                            .isNotEmpty) {
                                                                          Navigator.of(context)
                                                                              .pop(userInput);
                                                                        } else {
                                                                          setState(
                                                                              () {
                                                                            showError =
                                                                                true;
                                                                          });
                                                                        }
                                                                      },
                                                                    ),
                                                                  ],
                                                                );
                                                              },
                                                            );
                                                          },
                                                        );

                                                        // Set the user document with name and bookmarked
                                                        await FirebaseFirestore
                                                            .instance
                                                            .collection('users')
                                                            .doc(user!.uid)
                                                            .set({
                                                          "name": userName !=
                                                                      null &&
                                                                  userName
                                                                      .isNotEmpty
                                                              ? userName
                                                              : "User",
                                                          "bookmarked": []
                                                        });

                                                        userDoc = UserDoc(
                                                            uid: FirebaseAuth
                                                                .instance
                                                                .currentUser!
                                                                .uid,
                                                            name: userName !=
                                                                        null &&
                                                                    userName
                                                                        .isNotEmpty
                                                                ? userName
                                                                : "User",
                                                            bookmarked: []);

                                                        Navigator.pop(
                                                            context, true);

                                                        // Send email verification and sign out
                                                        /*await user!.sendEmailVerification();
                                                        await FirebaseAuth.instance.signOut();

                                                        // Show platform dialog for account creation confirmation
                                                        showPlatformDialog<void>(
                                                          context: context,
                                                          builder: (_) => PlatformAlertDialog(
                                                            title: const Text("Account Created"),
                                                            content: const Text("Verify your email before logging in."),
                                                            actions: <Widget>[
                                                              TextButton(
                                                                child: const Text('OK'),
                                                                onPressed: () => Navigator.pop(context),
                                                              ),
                                                            ],
                                                          ),
                                                        );*/
                                                      }
                                                    }
                                                  });
                                                } on FirebaseAuthException catch (e) {
                                                  if (e.code ==
                                                      'weak-password') {
                                                    createErrorScreen(
                                                        "The password provided is too weak.",
                                                        context,
                                                        "Registration");
                                                  } else if (e.code ==
                                                      'email-already-in-use') {
                                                    createErrorScreen(
                                                        "The account already exists for that email.",
                                                        context,
                                                        "Registration");
                                                  }
                                                } on CustomException catch (e) {
                                                  createErrorScreen(e.cause,
                                                      context, "Registration");
                                                } catch (e) {
                                                  createErrorScreen(
                                                      e.toString(),
                                                      context,
                                                      "Registration");
                                                }
                                              },
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    GestureDetector(
                                      onTap: () async {
                                        // valid email check
                                        String email = inputText['Email']!.text;
                                        if (!email.contains('@') ||
                                            !email.contains('.') ||
                                            email.indexOf('.') ==
                                                (email.length - 1)) {
                                          throw CustomException(
                                              'Fill in a valid email');
                                        }

                                        await FirebaseAuth.instance
                                            .sendPasswordResetEmail(
                                                email: inputText["Email"]!.text)
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
                                                TextButton(
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
                                        }).onError((error, stackTrace) {
                                          String body = "";
                                          print(error);
                                          if (error.toString() ==
                                              "[firebase_auth/missing-email] Error") {
                                            error = "No Email Provided";
                                            body = "Enter email in field.";
                                          } else if (error.toString() ==
                                              "[firebase_auth/user-not-found] There is no user record corresponding to this identifier. The user may have been deleted.") {
                                            error = "No User Found";
                                            body =
                                                "There is no user record corresponding to this identifier. The user may have been deleted.";
                                          }
                                          showPlatformDialog<void>(
                                            context: context,
                                            builder: (_) => PlatformAlertDialog(
                                              title: Text(
                                                "Error: $error",
                                                style: isCupertino(context)
                                                    ? CupertinoTheme.of(context)
                                                    .textTheme
                                                    .navLargeTitleTextStyle
                                                    : Theme.of(context).textTheme.titleLarge,
                                              ),
                                              content: Text(body.isNotEmpty
                                                  ? body
                                                  : stackTrace.toString()),
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
                                      child: const Align(
                                          alignment: Alignment.centerRight,
                                          child: Text(
                                            "Forgot password?",
                                          )),
                                    )
                                  ],
                                ))
                          ]),
                    ),
                  ),
                ),
              ))),
    );
  }
}

class CustomException implements Exception {
  String cause;

  CustomException(this.cause);
}

void createErrorScreen(error, context, sourceString) {
  showPlatformDialog<void>(
    context: context,
    builder: (_) => PlatformAlertDialog(
      title: Text(
        sourceString + " Failure",
        style: isCupertino(context)
            ? CupertinoTheme.of(context)
            .textTheme
            .navLargeTitleTextStyle
            : Theme.of(context).textTheme.titleLarge,
      ),
      content: Text(error),
      actions: <Widget>[
        PlatformTextButton(
          child: Text(
            'OK',
            style: isMaterial(context) ? TextStyle(
                color: Theme.of(context).primaryColor
            ) : null,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    ),
  );
}
