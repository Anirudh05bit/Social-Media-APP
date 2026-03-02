import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/current_user.dart';

class LikeService {
  final _db = FirebaseFirestore.instance;

  Stream<bool> isLikedStream(String postId) {
    final uid = CurrentUser.uid();
    return _db
        .collection('posts')
        .doc(postId)
        .collection('likes')
        .doc(uid)
        .snapshots()
        .map((doc) => doc.exists);
  }

  Stream<int> likeCountStream(String postId) {
    return _db.collection('posts').doc(postId).snapshots().map((doc) {
      final data = doc.data();
      if (data == null) return 0;
      return (data['likeCount'] ?? 0) as int;
    });
  }

  Future<void> toggleLike(String postId) async {
    final uid = CurrentUser.uid();
    final postRef = _db.collection('posts').doc(postId);
    final likeRef = postRef.collection('likes').doc(uid);

    await _db.runTransaction((tx) async {
      final likeSnap = await tx.get(likeRef);
      final postSnap = await tx.get(postRef);

      final currentCount = ((postSnap.data()?['likeCount'] ?? 0) as int);

      if (likeSnap.exists) {
        tx.delete(likeRef);
        tx.update(postRef, {'likeCount': (currentCount - 1).clamp(0, 1 << 30)});
      } else {
        tx.set(likeRef, {'createdAt': FieldValue.serverTimestamp()});
        tx.update(postRef, {'likeCount': currentCount + 1});
      }
    });
  }
}