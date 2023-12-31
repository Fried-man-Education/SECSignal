import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import 'company.dart';

class UserDoc {
  String uid; // Assuming you have a unique identifier for each UserDoc
  String name;
  List<Map<String, dynamic>> bookmarked;

  UserDoc({required this.uid, required this.name, required this.bookmarked});

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'bookmarked': bookmarked
          .map((bookmark) => {
                'timestamp': bookmark['timestamp'],
                'company': (bookmark['company'] as Company).toMapFirebase(),
              })
          .toList(),
    };
  }

  factory UserDoc.fromMap(Map<String, dynamic> map, String uid) {
    return UserDoc(
      uid: uid,
      name: map['name'],
      bookmarked:
          List<Map<String, dynamic>>.from(map['bookmarked'].map((bookmark) => {
                'timestamp': bookmark['timestamp'],
                'company': Company.fromMap(bookmark['company']),
              })),
    );
  }

  static Future<UserDoc?> fromFirebase() async {
    User? firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser == null) {
      return null;
    }

    DocumentSnapshot docSnap = await FirebaseFirestore.instance
        .collection('users')
        .doc(firebaseUser.uid)
        .get();

    if (!docSnap.exists) {
      return null;
    }

    return UserDoc.fromMap(
        docSnap.data() as Map<String, dynamic>, firebaseUser.uid);
  }

  Future<void> addBookmark(Company company) async {
    if (isCompanyBookmarked(company)) {
      return;
    }

    var timestamp = DateTime.now().microsecondsSinceEpoch;
    bookmarked.add({
      'timestamp': timestamp,
      'company': company,
    });

    // Update the Firestore UserDoc document
    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'bookmarked': FieldValue.arrayUnion([
        {
          'timestamp': timestamp,
          'company': company.toMapFirebase(),
        }
      ])
    });
  }

  Future<void> removeBookmark(Company companyToRemove) async {
    // Find the bookmark that matches the company's cikStr
    var bookmarkToRemove = bookmarked.firstWhere(
      (bookmark) =>
          (bookmark['company'] as Company).cikStr == companyToRemove.cikStr,
    );

    if (bookmarkToRemove != null) {
      // Remove the bookmark from the local list
      bookmarked.remove(bookmarkToRemove);

      // Update the Firestore UserDoc document
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'bookmarked': FieldValue.arrayRemove([
          {
            'timestamp': bookmarkToRemove['timestamp'],
            'company': (bookmarkToRemove['company'] as Company).toMapFirebase(),
          }
        ])
      });
    } else {
      print('Bookmark not found');
    }
  }

  Future<void> changeName(BuildContext context) async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // Display a dialog to input the new name
      String? newName = await showPlatformDialog<String>(
        context: context,
        builder: (BuildContext context) {
          String userInput = '';
          TextEditingController textEditingController = TextEditingController();
          bool showError = false;

          return StatefulBuilder(
            builder: (context, setState) {
              return PlatformAlertDialog(
                title: Text(
                  "Enter Your New Name",
                  style: isCupertino(context)
                      ? CupertinoTheme.of(context)
                      .textTheme
                      .navLargeTitleTextStyle
                      : Theme.of(context)
                      .textTheme
                      .titleLarge,
                ),
                content: TextField(
                  controller: textEditingController,
                  onChanged: (value) {
                    userInput = value;
                    if (showError && value.isNotEmpty) {
                      setState(() {
                        showError = false;
                      });
                    }
                  },
                  cursorColor: Theme.of(context)
                      .primaryColor,
                  decoration: InputDecoration(
                    hintText: "New Name",
                    errorText: showError ? "Please fill in the field" : null,
                    errorBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.red, width: 1),
                    ),
                    focusedErrorBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.red, width: 2),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                          color: Theme.of(context)
                              .primaryColor),
                    ),
                  ),
                ),
                actions: <Widget>[
                  PlatformTextButton(
                    child: const Text('OK'),
                    material: (_, __) => MaterialTextButtonData(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                          Theme.of(context).primaryColor, // Background color set to the theme's primary color
                        ),
                        foregroundColor: MaterialStateProperty.all<Color>(
                          Theme.of(context).scaffoldBackgroundColor, // Text color set to white
                        ),
                      ),
                    ),
                    onPressed: () {
                      if (userInput.isNotEmpty) {
                        Navigator.of(context).pop(userInput);
                      } else {
                        setState(() {
                          showError = true;
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

      // Update the user's name in Firestore
      if (newName != null && newName.isNotEmpty && newName != name) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
          'name': newName,
        }).then((_) {
          name = newName;
          print("User name updated to $newName");
        }).catchError((error) {
          print("Failed to update user's name: $error");
          // Handle errors here
        });
      }
    } else {
      print('No user logged in');
      // Handle no user logged in error here
    }
  }

  bool isCompanyBookmarked(Company company) {
    for (var bookmark in bookmarked) {
      Company bookmarkedCompany = bookmark['company'];
      if (bookmarkedCompany.cikStr == company.cikStr) {
        return true;
      }
    }
    return false;
  }

  List<String> getSortedTickers() {
    // Sort the bookmarked list by timestamp in descending order (most recent first)
    List<Map<String, dynamic>> sortedBookmarks = List.from(bookmarked);
    sortedBookmarks.sort((a, b) => b['timestamp'].compareTo(a['timestamp']));

    // Extract and return the list of tickers from the Company objects
    return sortedBookmarks
        .map((bookmark) => (bookmark['company'] as Company).ticker)
        .whereType<String>()
        .toList();
  }

  Future<List<Company>> getRecommendations() async {
    var random = math.Random();
    List<String> triedTickers =
        []; // To keep track of which companies have been tried
    Set<String?> favoritedTickers = bookmarked
        .map((bookmark) => (bookmark['company'] as Company).ticker)
        .toSet();

    // Shuffle the bookmarked list to randomize the order
    List<Map<String, dynamic>> shuffledBookmarks = List.from(bookmarked)
      ..shuffle(random);

    for (var bookmark in shuffledBookmarks) {
      Company company = bookmark['company'];
      if (!triedTickers.contains(company.ticker)) {
        triedTickers.add(company.ticker!);
        var peerCompanies = await company.fetchPeerCompanies();
        // Filter out favorited companies
        var filteredPeerCompanies = peerCompanies
            .where((peer) => !favoritedTickers.contains(peer.ticker))
            .toList();
        if (filteredPeerCompanies.isNotEmpty) {
          return filteredPeerCompanies;
        }
      }
    }

    // If no recommendations are found from bookmarked companies, fetch random companies
    return await Company.fetchRandomCompanies(5);
  }

  @override
  String toString() {
    return 'UserDoc(uid: $uid, name: $name, bookmarked: $bookmarked)';
  }
}
