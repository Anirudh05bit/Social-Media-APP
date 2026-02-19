import 'dart:io';
import 'package:flutter/material.dart';
import '../models/post_model.dart';
import 'comments_screen.dart';
import 'package:uuid/uuid.dart';
import '../models/post_model.dart';


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
      widget.post.likes += widget.post.isLiked ? 1 : -1;
      if (widget.post.likes < 0) widget.post.likes = 0;
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
    setState(() {}); // refresh counts after returning
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;

    return Scaffold(
      appBar: AppBar(
        title: Text(post.username),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          // Image + double tap heart
          GestureDetector(
            onDoubleTap: _doubleTapLike,
            child: Stack(
              alignment: Alignment.center,
              children: [
                AspectRatio(
                  aspectRatio: 1,
                  child: Image.file(
                    File(post.imagePath),
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: Colors.grey.shade200,
                      child: const Center(child: Icon(Icons.broken_image, size: 50)),
                    ),
                  ),
                ),
                if (_showBigHeart)
                  ScaleTransition(
                    scale: Tween<double>(begin: 0.6, end: 1.2).animate(
                      CurvedAnimation(parent: _heartController, curve: Curves.easeOutBack),
                    ),
                    child: Icon(
                      Icons.favorite,
                      size: 110,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
              ],
            ),
          ),

          // Actions row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                IconButton(
                  onPressed: _toggleLike,
                  icon: Icon(
                    post.isLiked ? Icons.favorite : Icons.favorite_border,
                    color: post.isLiked ? Colors.red : Colors.black,
                    size: 28,
                  ),
                ),
                IconButton(
                  onPressed: _openComments,
                  icon: const Icon(Icons.chat_bubble_outline, size: 26),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.send_outlined, size: 26),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.bookmark_border, size: 26),
                ),
              ],
            ),
          ),

          // Likes + caption
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              '${post.likes} likes',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: RichText(
              text: TextSpan(
                style: const TextStyle(color: Colors.black, fontSize: 14),
                children: [
                  TextSpan(
                    text: '${post.username} ',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: post.caption),
                ],
              ),
            ),
          ),

          const SizedBox(height: 10),

          // View comments
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GestureDetector(
              onTap: _openComments,
              child: Text(
                post.comments.isEmpty
                    ? 'Add a comment...'
                    : 'View all ${post.comments.length} comments',
                style: TextStyle(color: Colors.grey.shade700),
              ),
            ),
          ),

          const SizedBox(height: 18),
        ],
      ),
    );
  }
}
