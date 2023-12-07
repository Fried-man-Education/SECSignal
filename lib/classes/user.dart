import 'package:cloud_firestore/cloud_firestore.dart';
import 'company.dart';

class UserDoc {
  String uid; // Assuming you have a unique identifier for each UserDoc
  String name;
  List<Map<String, dynamic>> bookmarked;

  UserDoc({required this.uid, required this.name, required this.bookmarked});

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'bookmarked': bookmarked.map((bookmark) => {
        'timestamp': bookmark['timestamp'],
        'company': (bookmark['company'] as Company).toMapFirebase(),
      }).toList(),
    };
  }

  factory UserDoc.fromMap(Map<String, dynamic> map, String uid) {
    return UserDoc(
      uid: uid,
      name: map['name'],
      bookmarked: List<Map<String, dynamic>>.from(map['bookmarked'].map((bookmark) => {
        'timestamp': bookmark['timestamp'],
        'company': Company.fromMap(bookmark['company']),
      })),
    );
  }

  Future<void> addBookmark(Company company) async {
    var timestamp = DateTime.now().microsecondsSinceEpoch;
    bookmarked.add({
      'timestamp': timestamp,
      'company': company,
    });

    // Update the Firestore UserDoc document
    await FirebaseFirestore.instance.collection('UserDocs').doc(uid).update({
      'bookmarked': FieldValue.arrayUnion([{
        'timestamp': timestamp,
        'company': company.toMap(),
      }])
    });
  }

  Future<void> removeBookmark(Map<String, dynamic> bookmarkToRemove) async {
    bookmarked.removeWhere((bookmark) =>
    bookmark['timestamp'] == bookmarkToRemove['timestamp'] &&
        bookmark['company'].ticker == bookmarkToRemove['company'].ticker);

    // Update the Firestore UserDoc document
    await FirebaseFirestore.instance.collection('UserDocs').doc(uid).update({
      'bookmarked': FieldValue.arrayRemove([bookmarkToRemove])
    });
  }

  @override
  String toString() {
    return 'UserDoc(uid: $uid, name: $name, bookmarked: $bookmarked)';
  }
}
