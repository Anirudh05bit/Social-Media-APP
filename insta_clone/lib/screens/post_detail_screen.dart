import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/post_model.dart';
import '../services/like_service.dart';
import 'comments_screen.dart';
import 'package:flutter/services.dart';

class PostDetailScreen extends StatefulWidget {
  final PostModel post;
  final VoidCallback onUpdated;

  const PostDetailScreen({
    super.key,
    required this.post,
    required this.onUpdated,
  });

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _heartController;
  bool _showBigHeart = false;

  final LikeService _likeService = LikeService();

  String get _postId => widget.post.postId;

  @override
  void initState() {
    super.initState();
    _heartController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
  }

  @override
  void dispose() {
    _heartController.dispose();
    super.dispose();
  }

  Future<void> _toggleLikeFirestore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please login before liking.")),
      );
      return;
    }

    await _likeService.toggleLike(_postId);
    HapticFeedback.lightImpact();
    widget.onUpdated();
  }

  Future<void> _doubleTapLikeFirestore(bool isLiked) async {
    // Only like on double tap if not already liked
    if (!isLiked) {
      await _toggleLikeFirestore();
    }

    setState(() => _showBigHeart = true);
    _heartController.forward(from: 0).whenComplete(() {
      if (mounted) setState(() => _showBigHeart = false);
    });
  }

  Future<void> _openComments() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CommentsBottomSheet(
        post: widget.post,
        onUpdated: widget.onUpdated,
      ),
    );

    // Refresh UI after returning from comments
    setState(() {});
  }

  Widget _buildPostImage() {
    final post = widget.post;

    // ✅ Prefer Firebase imageUrl if available
    if (post.imageUrl != null && post.imageUrl!.isNotEmpty) {
      return Image.network(
        post.imageUrl!,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loading) {
          if (loading == null) return child;
          return const Center(child: CircularProgressIndicator());
        },
        errorBuilder: (context, error, stackTrace) {
          print('❌ Error loading image: $error');
          final errorMessage = error.toString();
          final isFirebaseError = errorMessage.contains('firebasestorage.googleapis.com') || 
                                 errorMessage.contains('412') ||
                                 errorMessage.contains('Precondition Failed');
          
          return Container(
            color: Colors.grey.shade200,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.broken_image, size: 60, color: Colors.grey),
                  const SizedBox(height: 8),
                  Text(
                    isFirebaseError 
                      ? 'Image storage expired - please re-upload'
                      : 'Failed to load image', 
                    style: const TextStyle(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      );
    }

    // ✅ Otherwise try local file preview
    if (post.imagePath != null && post.imagePath!.isNotEmpty) {
      return Image.file(
        File(post.imagePath!),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          color: Colors.grey.shade200,
          child: const Center(child: Icon(Icons.broken_image, size: 60)),
        ),
      );
    }

    // ✅ Fallback
    return Container(
      color: Colors.grey.shade200,
      child: const Center(child: Icon(Icons.broken_image, size: 60)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;

    return Scaffold(
      appBar: AppBar(
        title: Text(post.username ?? 'User'),
        centerTitle: true,
      ),
      body: StreamBuilder<bool>(
        stream: _likeService.isLikedStream(_postId),
        builder: (context, likedSnap) {
          final isLiked = likedSnap.data ?? false;

          return ListView(
            children: [
              // ✅ Image + double tap to like (Firestore)
              GestureDetector(
                onDoubleTap: () => _doubleTapLikeFirestore(isLiked),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    AspectRatio(
                      aspectRatio: 1,
                      child: _buildPostImage(),
                    ),
                    if (_showBigHeart)
                      ScaleTransition(
                        scale: Tween<double>(begin: 0.0, end: 1.4).animate(
                          CurvedAnimation(
                            parent: _heartController,
                            curve: Curves.easeOutBack,
                          ),
                        ),
                        child: const Icon(
                          Icons.favorite,
                          size: 120,
                          color: Colors.white70,
                        ),
                      ),
                  ],
                ),
              ),

              // ✅ Action buttons row
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: _toggleLikeFirestore,
                      icon: Icon(
                        isLiked ? Icons.favorite : Icons.favorite_border,
                        color: isLiked ? Colors.red : Colors.black87,
                        size: 30,
                      ),
                    ),
                    IconButton(
                      onPressed: _openComments,
                      icon: const Icon(Icons.chat_bubble_outline, size: 28),
                    ),
                    IconButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Share coming soon.')),
                        );
                      },
                      icon: const Icon(Icons.send_outlined, size: 28),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Save coming soon.')),
                        );
                      },
                      icon: const Icon(Icons.bookmark_border, size: 28),
                    ),
                  ],
                ),
              ),

              // ✅ Likes count (real-time from Firestore)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: StreamBuilder<int>(
                  stream: _likeService.likeCountStream(_postId),
                  builder: (context, countSnap) {
                    final likeCount = countSnap.data ?? post.likeCount;

                    return Text(
                      '$likeCount likes',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 6),

              // Username + caption
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(color: Colors.black, fontSize: 14),
                    children: [
                      TextSpan(
                        text: '${post.username ?? 'User'} ',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(text: post.caption ?? ''),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Comments teaser (still local for now)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GestureDetector(
                  onTap: _openComments,
                  child: Text(
                    post.comments.isEmpty
                        ? 'Add a comment...'
                        : 'View all ${post.comments.length} comments',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }
}