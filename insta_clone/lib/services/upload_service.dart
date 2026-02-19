import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import '../models/post_model.dart';
import 'package:uuid/uuid.dart';
import '../models/post_model.dart';

class UploadService {
  final _firestore = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;

  Future<void> uploadPost({
    required File image,
    required String caption,
  }) async {
    final postId = const Uuid().v4();

    // Upload image
    final ref =
        _storage.ref().child("posts").child("$postId.jpg");

    await ref.putFile(image);

    final imageUrl = await ref.getDownloadURL();

    final post = PostModel(
      postId: postId,
      imageUrl: imageUrl,
      caption: caption,
      date: DateTime.now(),
    );

    await _firestore
        .collection("posts")
        .doc(postId)
        .set(post.toJson());
  }
}
