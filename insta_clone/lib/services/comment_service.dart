import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../services/current_user.dart';

class CommentService {
  final _db = FirebaseFirestore.instance;
  final _uuid = Uuid();

  Stream<QuerySnapshot<Map<String, dynamic>>> commentsStream(String postId) {
    return _db
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .orderBy('createdAt', descending: false)
        .snapshots();
  }

  Future<void> addComment({
    required String postId,
    required String text,
  }) async {
    final uid = CurrentUser.uid();
    final username = CurrentUser.usernameFallback();
    final commentId = _uuid.v4();

    await _db
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .doc(commentId)
        .set({
      'commentId': commentId,
      'uid': uid,
      'username': username,
      'text': text.trim(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}