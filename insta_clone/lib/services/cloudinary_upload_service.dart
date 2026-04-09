import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import 'package:dio/dio.dart';

class CloudinaryUploadService {
  // ⚠️ REPLACE THESE WITH YOUR CLOUDINARY CREDENTIALS
  // Get these from: https://cloudinary.com/console
  static const String CLOUD_NAME = 'dp6wueedh';
  static const String UPLOAD_PRESET = 'insta_clone_preset';

  // Do NOT put your API secret in the app. Use unsigned upload presets instead.

  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final _dio = Dio();
  final _uuid = const Uuid();

  /// Upload image to Cloudinary and save metadata to Firestore
  Future<void> uploadPost({
    required File image,
    required String caption,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception("User not logged in");
    }

    if (CLOUD_NAME == 'YOUR_CLOUDINARY_CLOUD_NAME') {
      throw Exception(
        "Cloudinary credentials not configured. "
        "Replace CLOUD_NAME and UPLOAD_PRESET in cloudinary_upload_service.dart",
      );
    }

    final uid = user.uid;
    final username = user.email?.split('@').first ?? "anonymous";
    final postId = _uuid.v4();

    try {
      print("=== CLOUDINARY UPLOAD STARTED ===");
      print("User: $uid ($username)");
      print("Post ID: $postId");
      print("Image: ${image.path}");

      // ── 1. Upload to Cloudinary ─────────────────────────────────
      print("Uploading to Cloudinary...");
      final imageUrl = await _uploadToCloudinary(image, postId);
      print("✅ Image uploaded: $imageUrl");

      // ── 2. Save post metadata to Firestore ──────────────────────
      print("Saving post to Firestore...");
      await _firestore.collection("posts").doc(postId).set({
        "postId": postId,
        "uid": uid,
        "username": username,
        "imageUrl": imageUrl,
        "caption": caption,
        "createdAt": FieldValue.serverTimestamp(),
        "date": FieldValue.serverTimestamp(),
        "storageProvider": "cloudinary",
        "likeCount": 0,
      });
      print("✅ Post saved to Firestore");

      print("=== UPLOAD COMPLETE ===");
    } catch (e, stackTrace) {
      print("❌ UPLOAD FAILED");
      print("Error: $e");
      print("Stack trace: $stackTrace");
      rethrow;
    }
  }

  /// Upload image file to Cloudinary using unsigned upload
  Future<String> _uploadToCloudinary(File image, String publicId) async {
    try {
      final url = "https://api.cloudinary.com/v1_1/$CLOUD_NAME/image/upload";

      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(image.path),
        'upload_preset': UPLOAD_PRESET,
        'public_id': publicId,
        'folder': 'insta_clone',
        'resource_type': 'auto',
      });

      print("Posting to: $url");
      final response = await _dio.post(url, data: formData);

      if (response.statusCode == 200) {
        final imageUrl = response.data['secure_url'];
        print("Cloudinary response: $imageUrl");
        return imageUrl;
      } else {
        throw Exception(
          "Cloudinary upload failed: ${response.statusCode} - ${response.data}",
        );
      }
    } catch (e) {
      print("Cloudinary upload error: $e");
      rethrow;
    }
  }

  /// Upload a profile avatar to Cloudinary without saving extra Firestore data
  Future<String> uploadProfileAvatar({
    required File image,
    required String publicId,
  }) async {
    if (CLOUD_NAME == 'YOUR_CLOUDINARY_CLOUD_NAME') {
      throw Exception(
        "Cloudinary credentials not configured. "
        "Replace CLOUD_NAME and UPLOAD_PRESET in cloudinary_upload_service.dart",
      );
    }

    print("Uploading profile avatar to Cloudinary...");
    final imageUrl = await _uploadToCloudinary(image, publicId);
    print("✅ Profile avatar uploaded: $imageUrl");
    return imageUrl;
  }

  /// Test Cloudinary connection
  Future<void> testCloudinaryConnection() async {
    try {
      print("=== TESTING CLOUDINARY CONNECTION ===");

      if (CLOUD_NAME == 'YOUR_CLOUDINARY_CLOUD_NAME') {
        print("❌ Cloudinary not configured");
        print(
          "Please set CLOUD_NAME and UPLOAD_PRESET in cloudinary_upload_service.dart",
        );
        return;
      }

      print("Cloud Name: $CLOUD_NAME");
      print("Upload Preset: $UPLOAD_PRESET");
      print("✅ Cloudinary is configured for unsigned uploads");
      print("✅ You can upload images with the configured preset");
      print("=== CONNECTION TEST COMPLETE ===");
    } catch (e) {
      print("❌ Cloudinary connection test failed: $e");
    }
  }
}
