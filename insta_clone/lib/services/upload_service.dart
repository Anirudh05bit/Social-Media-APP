import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

import '../models/post_model.dart';
import 'user_service.dart';

class UploadService {
  Future<void> testFirebaseConnection() async {
    try {
      print("=== TESTING FIREBASE CONNECTION ===");

      // Test Firestore connection
      final firestore = FirebaseFirestore.instance;
      final testDoc = await firestore
          .collection("test")
          .doc("connection")
          .get();
      print("Firestore connection: OK");

      // Test Storage connection
      final storage = FirebaseStorage.instance;
      final ref = storage.ref().child("test.txt");
      print("Storage reference created: ${ref.fullPath}");

      // Test auth
      final auth = FirebaseAuth.instance;
      final user = auth.currentUser;
      print("Current user: ${user?.email ?? 'Not logged in'}");
      print("User authenticated: ${user != null}");

      print("=== FIREBASE CONNECTION TEST COMPLETE ===");
    } catch (e) {
      print("❌ FIREBASE CONNECTION TEST FAILED: $e");
    }
  }

  Future<void> uploadPost({
    required File image,
    required String caption,
  }) async {
    final _auth = FirebaseAuth.instance;
    final _firestore = FirebaseFirestore.instance;
    final _storage = FirebaseStorage.instance;
    final _uuid = const Uuid();

    final user = _auth.currentUser;
    if (user == null) {
      throw Exception("User not logged in");
    }

    final uid = user.uid;
    final username = user.email?.split('@').first ?? "anonymous";
    final postId = _uuid.v4();

    try {
      print("=== POST UPLOAD STARTED ===");
      print("User: $uid ($username)");
      print("Post ID: $postId");
      print("Image path: ${image.path}");
      print("Image exists: ${await image.exists()}");
      print("Image size: ${await image.length()} bytes");

      // Check if user is authenticated
      print("Current user authenticated: ${user != null}");
      print("User email: ${user.email}");
      print("User email verified: ${user.emailVerified}");

      // ── 1. Upload image to Storage ────────────────────────────────
      final ref = _storage.ref().child("posts/$postId.jpg");

      print("Uploading to: ${ref.fullPath}");

      final uploadTask = ref.putFile(image);

      // Listen to progress
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress =
            (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
        print('Upload progress: ${progress.toStringAsFixed(1)}%');
      });

      final snapshot = await uploadTask.whenComplete(() {
        print("Image upload task completed");
      });

      print("Upload state: ${snapshot.state}");
      print("Upload total bytes: ${snapshot.totalBytes}");
      print("Upload transferred bytes: ${snapshot.bytesTransferred}");

      if (snapshot.state != TaskState.success) {
        throw Exception("Upload failed - state: ${snapshot.state}");
      }

      final imageUrl = await ref.getDownloadURL();
      print("Image URL obtained: $imageUrl");

      // ── 2. Save post to Firestore ─────────────────────────────────
      print("Saving post document...");
      final postData = {
        "postId": postId,
        "uid": uid,
        "username": username,
        "imageUrl": imageUrl,
        "caption": caption,
        "createdAt": FieldValue.serverTimestamp(),
        "likeCount": 0,
      };
      print("Post data to save: $postData");

      await _firestore.collection("posts").doc(postId).set(postData);
      print("Post document saved successfully");

      // ── 3. Update user post count ─────────────────────────────────
      print("Incrementing user post count...");
      await UserService().incrementPostCount(uid);
      print("User post count updated");

      print("=== POST UPLOAD FINISHED SUCCESSFULLY ===");
    } catch (e, stackTrace) {
      print("❌ POST UPLOAD FAILED");
      print("Error: $e");
      print("Error type: ${e.runtimeType}");
      print("Stack trace: $stackTrace");

      // You can also throw it again if the UI needs to catch it
      // or handle it here (show dialog/snackbar in the screen)
      rethrow; // ← keeps the error visible to the calling screen
    }
  }
}
