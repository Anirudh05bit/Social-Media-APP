import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../services/current_user.dart';
import '../services/cloudinary_upload_service.dart';

class CommentService {
  final _db = FirebaseFirestore.instance;
  final _uuid = Uuid();
  final _cloudinaryService = CloudinaryUploadService();

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

    try {
      // Add comment to Firestore
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

      // TODO: Update Cloudinary metadata as well
      // await _updateCloudinaryComments(postId);

    } catch (e) {
      print('Error adding comment: $e');
      rethrow;
    }
  }

  // Future<void> _updateCloudinaryComments(String postId) async {
  //   try {
  //     // Get all comments for this post
  //     final commentsSnapshot = await _db
  //         .collection('posts')
  //         .doc(postId)
  //         .collection('comments')
  //         .orderBy('createdAt')
  //         .get();

  //     final comments = commentsSnapshot.docs.map((doc) => doc.data()).toList();

  //     // Get current post data
  //     final postDoc = await _db.collection('posts').doc(postId).get();
  //     final data = postDoc.data();
  //     if (data == null) return;

  //     final caption = data['caption'] ?? '';
  //     final username = data['username'] ?? '';
  //     final uid = data['uid'] ?? '';
  //     final likeCount = data['likeCount'] ?? 0;

  //     // Update Cloudinary metadata with new comments
  //     await _cloudinaryService.updatePostMetadata(
  //       postId,
  //       caption,
  //       username,
  //       uid,
  //       likeCount,
  //       comments,
  //     );
  //   } catch (e) {
  //     print('Error updating Cloudinary comments: $e');
  //   }
  // }
}