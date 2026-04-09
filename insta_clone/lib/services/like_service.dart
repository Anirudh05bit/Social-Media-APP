import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/current_user.dart';
import '../services/cloudinary_upload_service.dart';

class LikeService {
  final _cloudinaryService = CloudinaryUploadService();
  final _db = FirebaseFirestore.instance;

  // Cache for like states to avoid frequent API calls
  final Map<String, bool> _likeCache = {};
  final Map<String, int> _likeCountCache = {};
  final Map<String, StreamController<bool>> _likeControllers = {};
  final Map<String, StreamController<int>> _countControllers = {};

  Stream<bool> isLikedStream(String postId) {
    final uid = CurrentUser.uid();

    if (!_likeControllers.containsKey(postId)) {
      _likeControllers[postId] = StreamController<bool>.broadcast();
      _loadLikeState(postId, uid);
    }

    return _likeControllers[postId]!.stream;
  }

  Stream<int> likeCountStream(String postId) {
    if (!_countControllers.containsKey(postId)) {
      _countControllers[postId] = StreamController<int>.broadcast();
      _loadLikeCount(postId);
    }

    return _countControllers[postId]!.stream;
  }

  Future<void> _loadLikeState(String postId, String uid) async {
    try {
      // For now, we'll use Firestore to track likes since Cloudinary metadata updates are not real-time
      // In a production app, you'd want a backend service to handle this
      final likeRef = _db.collection('posts').doc(postId).collection('likes').doc(uid);
      final doc = await likeRef.get();
      final isLiked = doc.exists;

      _likeCache[postId] = isLiked;
      _likeControllers[postId]?.add(isLiked);
    } catch (e) {
      print('Error loading like state: $e');
      _likeControllers[postId]?.add(false);
    }
  }

  Future<void> _loadLikeCount(String postId) async {
    try {
      // Use Firestore for now, but eventually migrate to Cloudinary metadata
      final postRef = _db.collection('posts').doc(postId);
      final doc = await postRef.get();
      final count = (doc.data()?['likeCount'] ?? 0) as int;

      _likeCountCache[postId] = count;
      _countControllers[postId]?.add(count);
    } catch (e) {
      print('Error loading like count: $e');
      _countControllers[postId]?.add(0);
    }
  }

  Future<void> toggleLike(String postId) async {
    final uid = CurrentUser.uid();
    final postRef = _db.collection('posts').doc(postId);
    final likeRef = postRef.collection('likes').doc(uid);

    try {
      await _db.runTransaction((tx) async {
        final likeSnap = await tx.get(likeRef);
        final postSnap = await tx.get(postRef);

        final currentCount = ((postSnap.data()?['likeCount'] ?? 0) as int);

        if (likeSnap.exists) {
          tx.delete(likeRef);
          tx.update(postRef, {'likeCount': (currentCount - 1).clamp(0, 1 << 30)});
          _likeCache[postId] = false;
          _likeCountCache[postId] = currentCount - 1;
        } else {
          tx.set(likeRef, {'createdAt': FieldValue.serverTimestamp()});
          tx.update(postRef, {'likeCount': currentCount + 1});
          _likeCache[postId] = true;
          _likeCountCache[postId] = currentCount + 1;
        }
      });

      // Update controllers
      _likeControllers[postId]?.add(_likeCache[postId] ?? false);
      _countControllers[postId]?.add(_likeCountCache[postId] ?? 0);

      // TODO: Update Cloudinary metadata as well
      // await _updateCloudinaryMetadata(postId);

    } catch (e) {
      print('Error toggling like: $e');
      rethrow;
    }
  }

  // Future<void> _updateCloudinaryMetadata(String postId) async {
  //   try {
  //     // Get current post data from Firestore
  //     final postDoc = await _db.collection('posts').doc(postId).get();
  //     final data = postDoc.data();
  //     if (data == null) return;

  //     final caption = data['caption'] ?? '';
  //     final username = data['username'] ?? '';
  //     final uid = data['uid'] ?? '';
  //     final likeCount = data['likeCount'] ?? 0;
  //     final comments = data['comments'] ?? [];

  //     // Update Cloudinary metadata
  //     await _cloudinaryService.updatePostMetadata(
  //       postId,
  //       caption,
  //       username,
  //       uid,
  //       likeCount,
  //       List<Map<String, dynamic>>.from(comments),
  //     );
  //   } catch (e) {
  //     print('Error updating Cloudinary metadata: $e');
  //   }
  // }

  void dispose() {
    for (var controller in _likeControllers.values) {
      controller.close();
    }
    for (var controller in _countControllers.values) {
      controller.close();
    }
    _likeControllers.clear();
    _countControllers.clear();
    _likeCache.clear();
    _likeCountCache.clear();
  }
}