import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

import '../models/post_model.dart';

class UploadService {
  final _firestore = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;
  final _auth = FirebaseAuth.instance;

  final Uuid _uuid = Uuid();

  Future<void> uploadPost({
    required File image,
    required String caption,
  }) async {
    final postId = _uuid.v4();

    // ✅ Upload image
    final ref = _storage.ref().child("posts").child("$postId.jpg");
    await ref.putFile(image);
    final imageUrl = await ref.getDownloadURL();

    // ✅ Username fallback (works even in anonymous login)
    final user = _auth.currentUser;
    final username = user?.email?.split('@').first ?? "anonymous";

    final post = PostModel(
      postId: postId,
      username: username,
      imagePath: image.path,       // local preview path
      imageUrl: imageUrl,          // firebase url
      caption: caption,
      createdAt: DateTime.now(),
    );

    await _firestore.collection("posts").doc(postId).set(post.toJson());
  }
}
