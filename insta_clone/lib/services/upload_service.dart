import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

import '../models/post_model.dart';
import 'user_service.dart';

class UploadService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final Uuid _uuid = Uuid();

  Future<void> uploadPost({
    required File image,
    required String caption,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception("User not logged in");
    }

    final uid = user.uid;
    final username = user.email?.split('@').first ?? "anonymous";

    final postId = _uuid.v4();

    // ✅ Upload image to Storage
    final ref = _storage.ref().child("posts").child("$postId.jpg");
    await ref.putFile(image);
    final imageUrl = await ref.getDownloadURL();

    // ✅ Save post to Firestore (IMPORTANT STRUCTURE)
    await _firestore.collection("posts").doc(postId).set({
      "postId": postId,
      "uid": uid,                         // 🔥 REQUIRED FOR PROFILE
      "username": username,
      "imageUrl": imageUrl,
      "caption": caption,
      "createdAt": FieldValue.serverTimestamp(),  // 🔥 REQUIRED FOR ORDERING
      "likeCount": 0,                     // 🔥 REQUIRED FOR LIKES
    });

    // ✅ Increment user's post count
    await UserService().incrementPostCount(uid);
  }
}