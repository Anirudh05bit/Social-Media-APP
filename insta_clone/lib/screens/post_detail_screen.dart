import 'dart:io';

import 'package:flutter/material.dart';

import '../models/post_model.dart';
import 'comments_screen.dart'; // Make sure this import path is correct

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

  void _toggleLike() {
    setState(() {
      widget.post.isLiked = !widget.post.isLiked;
      widget.post.likeCount += widget.post.isLiked ? 1 : -1;
      if (widget.post.likeCount < 0) widget.post.likeCount = 0;
    });
    widget.onUpdated();
  }

  void _doubleTapLike() {
    if (!widget.post.isLiked) {
      _toggleLike();
    }
    setState(() => _showBigHeart = true);
    _heartController.forward(from: 0).whenComplete(() {
      if (mounted) setState(() => _showBigHeart = false);
    });
  }

  Future<void> _openComments() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CommentsScreen(
          post: widget.post,
          onUpdated: widget.onUpdated,
        ),
      ),
    );
    setState(() {}); // Refresh UI after returning from comments
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;

    return Scaffold(
      appBar: AppBar(
        title: Text(post.username ?? 'User'),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          // Image + double tap to like
          GestureDetector(
            onDoubleTap: _doubleTapLike,
            child: Stack(
              alignment: Alignment.center,
              children: [
                AspectRatio(
                  aspectRatio: 1,
                  child: Image.file(
                    File(post.imagePath ?? ''),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey.shade200,
                      child: const Center(
                        child: Icon(Icons.broken_image, size: 60),
                      ),
                    ),
                  ),
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

          // Action buttons row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Row(
              children: [
                IconButton(
                  onPressed: _toggleLike,
                  icon: Icon(
                    post.isLiked ? Icons.favorite : Icons.favorite_border,
                    color: post.isLiked ? Colors.red : Colors.black87,
                    size: 30,
                  ),
                ),
                IconButton(
                  onPressed: _openComments,
                  icon: const Icon(Icons.chat_bubble_outline, size: 28),
                ),
                IconButton(
                  onPressed: () {}, // share functionality
                  icon: const Icon(Icons.send_outlined, size: 28),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {}, // bookmark/save
                  icon: const Icon(Icons.bookmark_border, size: 28),
                ),
              ],
            ),
          ),

          // Likes count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              '${post.likeCount} likes',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
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
                  TextSpan(text: post.caption),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Comments teaser
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
      ),
    );
  }
} 