import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// ✅ Create new user document
  Future<void> createUser({
    required String uid,
    required String username,
    required String email,
  }) async {
    await _db.collection("users").doc(uid).set({
      "uid": uid,
      "username": username,
      "email": email,
      "bio": "",
      "photoUrl": "",
      "followersCount": 0,
      "followingCount": 0,
      "postCount": 0,
      "createdAt": FieldValue.serverTimestamp(),
    });
  }

  /// ✅ Real-time user stream (for ProfileScreen)
  Stream<DocumentSnapshot<Map<String, dynamic>>> userStream(String uid) {
    return _db.collection("users").doc(uid).snapshots();
  }

  /// ✅ Update profile (bio / photo)
  Future<void> updateProfile({
    required String uid,
    String? bio,
    String? photoUrl,
  }) async {
    Map<String, dynamic> data = {};

    if (bio != null) data["bio"] = bio;
    if (photoUrl != null) data["photoUrl"] = photoUrl;

    await _db.collection("users").doc(uid).update(data);
  }

  /// ✅ Increment post count when user uploads post
  Future<void> incrementPostCount(String uid) async {
    await _db.collection("users").doc(uid).update({
      "postCount": FieldValue.increment(1),
    });
  }

  /// ✅ Decrement post count (if deleting post later)
  Future<void> decrementPostCount(String uid) async {
    await _db.collection("users").doc(uid).update({
      "postCount": FieldValue.increment(-1),
    });
  }

  /// ✅ Followers increment
  Future<void> incrementFollowers(String uid) async {
    await _db.collection("users").doc(uid).update({
      "followersCount": FieldValue.increment(1),
    });
  }

  /// ✅ Following increment
  Future<void> incrementFollowing(String uid) async {
    await _db.collection("users").doc(uid).update({
      "followingCount": FieldValue.increment(1),
    });
  }

  /// ✅ Followers decrement
  Future<void> decrementFollowers(String uid) async {
    await _db.collection("users").doc(uid).update({
      "followersCount": FieldValue.increment(-1),
    });
  }

  /// ✅ Following decrement
  Future<void> decrementFollowing(String uid) async {
    await _db.collection("users").doc(uid).update({
      "followingCount": FieldValue.increment(-1),
    });
  }
}