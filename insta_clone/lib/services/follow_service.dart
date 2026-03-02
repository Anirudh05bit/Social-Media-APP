import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FollowService {
  final _db = FirebaseFirestore.instance;

  Stream<bool> isFollowingStream(String targetUid) {
    final myUid = FirebaseAuth.instance.currentUser?.uid;
    if (myUid == null) return Stream.value(false);

    return _db
        .collection('users')
        .doc(myUid)
        .collection('following')
        .doc(targetUid)
        .snapshots()
        .map((d) => d.exists);
  }

  Future<void> toggleFollow(String targetUid) async {
    final myUid = FirebaseAuth.instance.currentUser?.uid;
    if (myUid == null) return;
    if (myUid == targetUid) return;

    final myFollowingRef =
        _db.collection('users').doc(myUid).collection('following').doc(targetUid);
    final targetFollowerRef =
        _db.collection('users').doc(targetUid).collection('followers').doc(myUid);

    final myUserDoc = _db.collection('users').doc(myUid);
    final targetUserDoc = _db.collection('users').doc(targetUid);

    await _db.runTransaction((tx) async {
      final followingSnap = await tx.get(myFollowingRef);
      final mySnap = await tx.get(myUserDoc);
      final targetSnap = await tx.get(targetUserDoc);

      final myFollowingCount = ((mySnap.data()?['followingCount'] ?? 0) as int);
      final targetFollowersCount =
          ((targetSnap.data()?['followersCount'] ?? 0) as int);

      if (followingSnap.exists) {
        // Unfollow
        tx.delete(myFollowingRef);
        tx.delete(targetFollowerRef);

        tx.update(myUserDoc, {
          'followingCount': (myFollowingCount - 1).clamp(0, 1 << 30),
        });
        tx.update(targetUserDoc, {
          'followersCount': (targetFollowersCount - 1).clamp(0, 1 << 30),
        });
      } else {
        // Follow
        tx.set(myFollowingRef, {'createdAt': FieldValue.serverTimestamp()});
        tx.set(targetFollowerRef, {'createdAt': FieldValue.serverTimestamp()});

        tx.update(myUserDoc, {'followingCount': myFollowingCount + 1});
        tx.update(targetUserDoc, {'followersCount': targetFollowersCount + 1});
      }
    });
  }
}