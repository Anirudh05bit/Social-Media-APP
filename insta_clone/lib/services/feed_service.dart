import 'package:cloud_firestore/cloud_firestore.dart';

class FeedService {
  final _firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot> getFeed() {
    return _firestore
        .collection("posts")
        .orderBy("date", descending: true)
        .snapshots();
  }
}
