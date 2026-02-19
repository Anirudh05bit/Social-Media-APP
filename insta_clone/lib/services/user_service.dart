import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  final _db = FirebaseFirestore.instance;

  Future<void> createUser({
    required String uid,
    required String username,
    required String email,
  }) async {
    await _db.collection("users").doc(uid).set({
      "username": username,
      "email": email,
      "createdAt": FieldValue.serverTimestamp(),
    });
  }
}
