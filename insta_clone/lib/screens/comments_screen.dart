import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/post_model.dart';

class CommentsScreen extends StatefulWidget {
  final PostModel post;
  final VoidCallback onUpdated;

  const CommentsScreen({
    super.key,
    required this.post,
    required this.onUpdated,
  });

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  final _controller = TextEditingController();
  final _uuid = const Uuid();

  void _addComment() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      widget.post.comments.add(
        CommentModel(
          id: _uuid.v4(),
          username: "you", // later from Firebase user
          text: text,
          createdAt: DateTime.now(),
        ),
      );
    });

    _controller.clear();
    widget.onUpdated();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final comments = widget.post.comments;

    return Scaffold(
      appBar: AppBar(title: const Text("Comments")),
      body: Column(
        children: [
          Expanded(
            child: comments.isEmpty
                ? const Center(child: Text("No comments yet"))
                : ListView.separated(
                    padding: const EdgeInsets.all(14),
                    itemCount: comments.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, i) {
                      final c = comments[i];
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const CircleAvatar(radius: 18, child: Icon(Icons.person, size: 18)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                style: const TextStyle(color: Colors.black, fontSize: 14),
                                children: [
                                  TextSpan(
                                    text: '${c.username} ',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  TextSpan(text: c.text),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: "Write a comment...",
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    onPressed: _addComment,
                    icon: const Icon(Icons.send),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
