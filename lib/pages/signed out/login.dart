import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../main.dart';

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
                title: const Text("Login"),
                backgroundColor: Theme
                    .of(context)
                    .canvasColor,
                material: (_, __) =>
                    MaterialAppBarData(
                      leading: IconButton(
                        icon: Icon(Icons.arrow_back, color: Theme
                            .of(context)
                            .primaryColor),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                cupertino: (_, __) =>
                    CupertinoNavigationBarData(
                      leading: CupertinoNavigationBarBackButton(
                        color: Theme
                            .of(context)
                            .primaryColor,
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
                                width: MediaQuery
                                    .of(context)
                                    .size
                                    .width / 2,
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(20.0),
                                      child: Image.asset(
                                        "assets/icon_rounded.png",
                                        height: MediaQuery
                                            .of(context)
                                            .size
                                            .width / 2,
                                        width: MediaQuery
                                            .of(context)
                                            .size
                                            .width / 2,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8),
                                      child: TextField(
                                        controller: inputText["Email"],
                                        decoration: const InputDecoration(
                                          border: OutlineInputBorder(),
                                          prefixIcon: Icon(Icons.person),
                                          labelText: 'Email',
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8),
                                      child: TextField(
                                        controller: inputText["Password"],
                                        obscureText: true,
                                        decoration: const InputDecoration(
                                          border: OutlineInputBorder(),
                                          prefixIcon: Icon(Icons.lock),
                                          labelText: 'Password',
                                        ),
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: PlatformElevatedButton(
                                              child: Padding(
                                                padding: const EdgeInsets.all(8.0),
                                                child: Text(
                                                  "Login",
                                                  style: TextStyle(
                                                    fontFamily: 'IBM_Plex_Sans',
                                                      fontSize:
                                                      MediaQuery
                                                          .of(context)
                                                          .size
                                                          .width / 61,
                                                      color: Theme.of(context).cardColor
                                                  ),
                                                ),
                                              ),
                                              onPressed: () async {
                                                try {
                                                  for (String typeText in inputText
                                                      .keys) {
                                                    // null checks
                                                    if (inputText[typeText]!.text
                                                        .isEmpty) {
                                                      throw CustomException(
                                                          'Fill in all fields');
                                                    }
                                                  }
                                                  await FirebaseAuth.instance
                                                      .signInWithEmailAndPassword(
                                                      email: inputText['Email']!.text,
                                                      password: inputText['Password']!
                                                          .text)
                                                      .then((value) async {
                                                    user =
                                                        FirebaseAuth.instance.currentUser;
                                                    if (user != null &&
                                                        user!.emailVerified) {
                                                      /*userData =
                                                      (await FirebaseFirestore.instance
                                                          .collection("users").doc(
                                                          FirebaseAuth.instance
                                                              .currentUser!.uid).get())
                                                          .data()!;*/
                                                      return;
                                                    }
                                                    throw CustomException(
                                                        "Email not verified");
                                                  });
                                                } on FirebaseAuthException catch (e) {
                                                  String error = "Server error: ${e
                                                      .code}";
                                                  if (e.code == 'user-not-found') {
                                                    error =
                                                    'No user found for that email.';
                                                  } else if (e.code == 'wrong-password') {
                                                    error =
                                                    'Wrong password provided for that user.';
                                                  }
                                                  createErrorScreen(
                                                      error, context, "Sign in");
                                                } on CustomException catch (e) {
                                                  if (e.cause == "Email not verified") {
                                                    showPlatformDialog<void>(
                                                      context: context,
                                                      builder: (_) =>
                                                          PlatformAlertDialog(
                                                            title: const Text(
                                                                "Sign in Failure"),
                                                            content: const Text(
                                                                "Verify account email"),
                                                            actions: <Widget>[
                                                              TextButton(
                                                                child: const Text(
                                                                    'Resend Email'),
                                                                onPressed: () async {
                                                                  await user!
                                                                      .sendEmailVerification();
                                                                },
                                                              ),
                                                              TextButton(
                                                                child: const Text('OK'),
                                                                onPressed: () =>
                                                                    Navigator.pop(
                                                                        context),
                                                              ),
                                                            ],
                                                          ),
                                                    );
                                                    return;
                                                  }
                                                  createErrorScreen(
                                                      e.cause, context, "Sign in");
                                                } catch (e) {
                                                  createErrorScreen(
                                                      e.toString(), context, "Sign in");
                                                }
                                              },
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: PlatformElevatedButton(
                                              child: Padding(
                                                padding: const EdgeInsets.all(8.0),
                                                child: Text(
                                                  "Register",
                                                  style: TextStyle(
                                                      fontFamily: 'IBM_Plex_Sans',
                                                      fontSize:
                                                      MediaQuery
                                                          .of(context)
                                                          .size
                                                          .width / 61,
                                                      color: Theme.of(context).cardColor
                                                  ),
                                                ),
                                              ),
                                              onPressed: () async {
                                                try {
                                                  for (String typeText in inputText
                                                      .keys) {
                                                    // null checks
                                                    if (inputText[typeText]!.text
                                                        .isEmpty) {
                                                      throw CustomException(
                                                          'Fill in all fields');
                                                    }
                                                  }
                                                  // valid email check
                                                  String email = inputText['Email']!.text;
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
                                                      password: inputText['Password']!
                                                          .text)
                                                      .then((value) async {
                                                    user =
                                                        FirebaseAuth.instance.currentUser;
                                                    if (user != null) {
                                                      showPlatformDialog<void>(
                                                        context: context,
                                                        builder: (_) =>
                                                            PlatformAlertDialog(
                                                              title:
                                                              const Text(
                                                                  "Account Created"),
                                                              content: const Text(
                                                                  "Verify your email before logging in."),
                                                              actions: <Widget>[
                                                                TextButton(
                                                                  child: const Text('OK'),
                                                                  onPressed: () =>
                                                                      Navigator.pop(
                                                                          context),
                                                                ),
                                                              ],
                                                            ),
                                                      );
                                                      await FirebaseFirestore.instance
                                                          .collection('users').doc(
                                                          FirebaseAuth.instance
                                                              .currentUser!.uid).set(
                                                          {"saved": []});
                                                      await user!
                                                          .sendEmailVerification();
                                                      await FirebaseAuth.instance
                                                          .signOut();
                                                    }
                                                  });
                                                } on FirebaseAuthException catch (e) {
                                                  if (e.code == 'weak-password') {
                                                    createErrorScreen(
                                                        "The password provided is too weak.",
                                                        context,
                                                        "Registration");
                                                  } else
                                                  if (e.code == 'email-already-in-use') {
                                                    createErrorScreen(
                                                        "The account already exists for that email.",
                                                        context,
                                                        "Registration");
                                                  }
                                                } on CustomException catch (e) {
                                                  createErrorScreen(
                                                      e.cause, context, "Registration");
                                                } catch (e) {
                                                  createErrorScreen(
                                                      e.toString(), context,
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
                                        await FirebaseAuth.instance
                                            .sendPasswordResetEmail(
                                            email: inputText["Email"]!.text)
                                            .then((value) {
                                          showPlatformDialog<void>(
                                            context: context,
                                            builder: (_) =>
                                                PlatformAlertDialog(
                                                  title: const Text(
                                                      "Password Reset Email Sent"),
                                                  actions: <Widget>[
                                                    TextButton(
                                                      child: const Text('OK'),
                                                      onPressed: () =>
                                                          Navigator.pop(context),
                                                    ),
                                                  ],
                                                ),
                                          );
                                        })
                                            .onError((error, stackTrace) {
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
                                            builder: (_) =>
                                                PlatformAlertDialog(
                                                  title: Text("Error: $error"),
                                                  content: Text(
                                                      body.isNotEmpty ? body : stackTrace
                                                          .toString()),
                                                  actions: <Widget>[
                                                    TextButton(
                                                      child: const Text('OK'),
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
                                )
                            )
                          ]
                      ),
                    ),
                  ),
                ),
              )
          )
      ),
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
      title: Text(sourceString + " Failure"),
      content: Text(error),
      actions: <Widget>[
        TextButton(
          child: const Text('OK'),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    ),
  );
}