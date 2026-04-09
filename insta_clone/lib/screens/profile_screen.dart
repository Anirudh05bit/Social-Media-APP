import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/follow_service.dart';
import '../services/user_service.dart';

class ProfileScreen extends StatelessWidget {
  final String uid;
  const ProfileScreen({super.key, required this.uid});

  bool get _isMe => FirebaseAuth.instance.currentUser?.uid == uid;

  @override
  Widget build(BuildContext context) {
    final userService = UserService();
    final followService = FollowService();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        centerTitle: true,
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: userService.userStream(uid),
        builder: (context, userSnap) {
          if (userSnap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!userSnap.hasData || userSnap.data?.data() == null) {
            return const Center(child: Text("User not found"));
          }

          final user = userSnap.data!.data()!;
          final username = (user['username'] ?? 'user').toString();
          final bio = (user['bio'] ?? '').toString();
          final photoUrl = (user['photoUrl'] ?? '').toString();

          final followers = (user['followersCount'] ?? 0) as int;
          final following = (user['followingCount'] ?? 0) as int;
          final postCount = (user['postCount'] ?? 0) as int;

          return Column(
            children: [
              // ===== Header =====
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 38,
                      backgroundColor: Colors.grey.shade300,
                      backgroundImage:
                          photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
                      child: photoUrl.isEmpty
                          ? const Icon(Icons.person, size: 42, color: Colors.black54)
                          : null,
                    ),
                    const SizedBox(width: 18),

                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _StatBlock(label: "Posts", value: postCount),
                          _StatBlock(label: "Followers", value: followers),
                          _StatBlock(label: "Following", value: following),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Username + bio
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    username,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
              if (bio.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(bio),
                  ),
                ),

              // Buttons row
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: _isMe
                          ? OutlinedButton(
                              onPressed: () {
                                // Later: open edit profile screen
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Edit Profile screen coming next 😄"),
                                  ),
                                );
                              },
                              child: const Text("Edit Profile"),
                            )
                          : StreamBuilder<bool>(
                              stream: followService.isFollowingStream(uid),
                              builder: (context, followSnap) {
                                final isFollowing = followSnap.data ?? false;

                                return ElevatedButton(
                                  onPressed: () async {
                                    await followService.toggleFollow(uid);
                                  },
                                  child: Text(isFollowing ? "Unfollow" : "Follow"),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              // ===== Posts Grid =====
              Expanded(
                child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: FirebaseFirestore.instance
                      .collection('posts')
                      .where('uid', isEqualTo: uid) // IMPORTANT
                      .orderBy('createdAt', descending: true)
                      .snapshots(),
                  builder: (context, postSnap) {
                    if (postSnap.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!postSnap.hasData || postSnap.data!.docs.isEmpty) {
                      return const Center(child: Text("No posts yet"));
                    }

                    final posts = postSnap.data!.docs.where((doc) {
                      final imageUrl = (doc.data()?['imageUrl'] ?? '').toString();
                      return imageUrl.isNotEmpty && !imageUrl.contains('firebasestorage.googleapis.com');
                    }).toList();

                    if (posts.isEmpty) {
                      return const Center(child: Text("No Cloudinary posts yet"));
                    }

                    return GridView.builder(
                      padding: const EdgeInsets.all(2),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 2,
                        mainAxisSpacing: 2,
                      ),
                      itemCount: posts.length,
                      itemBuilder: (context, i) {
                        final p = posts[i].data();
                        final imageUrl = (p['imageUrl'] ?? '').toString();

                        return Container(
                          color: Colors.grey.shade200,
                          child: imageUrl.isEmpty
                              ? const Center(child: Icon(Icons.broken_image))
                              : Image.network(
                                  imageUrl,
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
                                    
                                    return Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.broken_image, size: 40, color: Colors.grey),
                                          const SizedBox(height: 8),
                                          Text(
                                            isFirebaseError 
                                              ? 'Image storage expired - please re-upload'
                                              : 'Failed to load image', 
                                            style: const TextStyle(color: Colors.grey, fontSize: 12),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StatBlock extends StatelessWidget {
  final String label;
  final int value;

  const _StatBlock({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 3),
        Text(label, style: TextStyle(color: Colors.grey.shade700)),
      ],
    );
  }
}