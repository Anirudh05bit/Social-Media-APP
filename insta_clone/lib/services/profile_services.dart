import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ProfileService {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final _storage = FirebaseStorage.instance;

  Future<Map<String, dynamic>?> getMyProfile() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;

    final doc = await _firestore.collection("users").doc(uid).get();
    return doc.data();
  }

  Future<String> _uploadAvatar(File file) async {
    final uid = _auth.currentUser!.uid;
    final ref = _storage.ref().child("profilePics").child("$uid.jpg");
    await ref.putFile(file);
    return await ref.getDownloadURL();
  }

  Future<void> updateMyProfile({
    required String username,
    required String bio,
    File? newAvatar,
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    String? photoUrl;

    // keep existing photoUrl if already present
    final existing = await _firestore.collection("users").doc(uid).get();
    photoUrl = existing.data()?["photoUrl"];

    // upload new one if provided
    if (newAvatar != null) {
      photoUrl = await _uploadAvatar(newAvatar);
    }

    await _firestore.collection("users").doc(uid).set({
      "uid": uid,
      "username": username,
      "bio": bio,
      "photoUrl": photoUrl,
      "updatedAt": FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
