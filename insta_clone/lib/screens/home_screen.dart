import 'dart:ui';
import 'package:flutter/material.dart';
import 'upload_post_screen.dart';
import '../services/feed_service.dart';
import '../services/like_service.dart';
import '../services/comment_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'edit_profile_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/focus_mode_service.dart';
import 'focus_mode_screen.dart';
import 'comments_screen.dart';
import '../models/post_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  Future<void> _showFocusDialog() async {
    final service = FocusModeService();

    showModalBottomSheet(
      context: context,
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Start Focus Mode",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                ListTile(
                  title: const Text("15 minutes"),
                  onTap: () async {
                    Navigator.pop(context);
                    await service.enableForMinutes(15);
                    if (!mounted) return;
                    await Navigator.push(context, MaterialPageRoute(builder: (_) => const FocusModeScreen()));
                    setState(() {});
                  },
                ),
                ListTile(
                  title: const Text("30 minutes"),
                  onTap: () async {
                    Navigator.pop(context);
                    await service.enableForMinutes(30);
                    if (!mounted) return;
                    await Navigator.push(context, MaterialPageRoute(builder: (_) => const FocusModeScreen()));
                    setState(() {});
                  },
                ),
                ListTile(
                  title: const Text("60 minutes"),
                  onTap: () async {
                    Navigator.pop(context);
                    await service.enableForMinutes(60);
                    if (!mounted) return;
                    await Navigator.push(context, MaterialPageRoute(builder: (_) => const FocusModeScreen()));
                    setState(() {});
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _onTabSelected(int index) {
    setState(() => _index = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.fromARGB(255, 0, 0, 0),
              Color.fromARGB(255, 0, 0, 0),
              Color(0xFFB2002D),
              Color(0xFFFF6A00),
            ],
            stops: [0.0, 0.35, 0.68, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildStylishAppBar(),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.1),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    );
                  },
                  child: _buildCurrentScreen(),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildStylishBottomNav(),
      floatingActionButton: _index == 1 ? _buildStylishFAB() : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildStylishAppBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.18)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          const Text(
            'Pixta',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
          const Spacer(),
          _buildAppBarIcon(Icons.self_improvement, () async {
            await _showFocusDialog();
          }),

        ],
      ),
    );
  }

  Widget _buildAppBarIcon(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.14)),
        ),
        child: Icon(icon, size: 24, color: Colors.white),
      ),
    );
  }

  Widget _buildCurrentScreen() {
    return Container(
      key: ValueKey<int>(_index),
      margin: const EdgeInsets.all(16),
      child: _index == 0
          ? _buildFeedScreen()
          : _index == 1
              ? _buildUploadScreen()
              : _buildProfileScreen(),
    );
  }

  // ── FEED ─────────────────────────────────────────────────────
  Widget _buildFeedScreen() {
    return StreamBuilder(
      stream: FeedService().getFeed(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Colors.white));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text("No posts yet", style: TextStyle(fontSize: 18, color: Colors.white)),
          );
        }
        final posts = snapshot.data!.docs.where((doc) {
          final imageUrl = (doc['imageUrl'] ?? '').toString();
          return imageUrl.isNotEmpty &&
              !imageUrl.contains('firebasestorage.googleapis.com');
        }).toList();

        if (posts.isEmpty) {
          return const Center(
            child: Text("No Cloudinary posts yet", style: TextStyle(fontSize: 18, color: Colors.white)),
          );
        }

        return ListView.builder(
          physics: const BouncingScrollPhysics(),
          itemCount: posts.length,
          itemBuilder: (context, index) {
            final d = posts[index].data() as Map<String, dynamic>;
            // ✅ Use _PostCard with real postId for live likes & comments
            return _PostCard(
              postId: (d['postId'] ?? posts[index].id).toString(),
              imageUrl: (d['imageUrl'] ?? '').toString(),
              caption: (d['caption'] ?? '').toString(),
              username: (d['username'] ?? 'user').toString(),
            );
          },
        );
      },
    );
  }

  Widget _buildUploadScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 600),
            curve: Curves.elasticOut,
            builder: (context, value, child) {
              return Transform.scale(scale: 0.8 + (0.2 * value), child: child);
            },
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF9500), Color(0xFFFFAB76), Color(0xFFFF6B6B)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF9500).withOpacity(0.35),
                    blurRadius: 40,
                    offset: const Offset(0, 20),
                  ),
                ],
              ),
              child: const Icon(Icons.add_photo_alternate, size: 80, color: Colors.white),
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'Create New Post',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: -0.5),
          ),
          const SizedBox(height: 12),
          Text(
            'Share your moments with the world',
            style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.6)),
          ),
        ],
      ),
    );
  }

  // ── PROFILE ───────────────────────────────────────────────────
  Widget _buildProfileScreen() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return const Center(child: Text("User not logged in", style: TextStyle(color: Colors.white)));
    }

    return FutureBuilder(
      future: FirebaseFirestore.instance.collection('users').doc(uid).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Colors.white));
        }
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Center(child: Text("No profile data found", style: TextStyle(color: Colors.white)));
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;
        final username = data['username'] ?? 'Your Name';
        final bio = data['bio'] ?? '';
        final photoUrl = data['photoUrl'];

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // Profile image with gradient ring
              Container(
                padding: const EdgeInsets.all(3),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xFF833AB4), Color(0xFFFD1D1D), Color(0xFFFCB045)],
                  ),
                ),
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF1A1A2E)),
                  child: CircleAvatar(
                    radius: 56,
                    backgroundColor: Colors.white12,
                    backgroundImage: photoUrl != null && photoUrl != "" ? NetworkImage(photoUrl) : null,
                    child: photoUrl == null || photoUrl == ""
                        ? const Icon(Icons.person, size: 56, color: Colors.white54)
                        : null,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              Text(
                username,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
              ),

              const SizedBox(height: 8),

              if (bio.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    bio,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.65)),
                  ),
                ),

              const SizedBox(height: 20),

              // Stats row
              _buildStatsRow(uid),

              const SizedBox(height: 20),

              // Edit Profile button
              InkWell(
                borderRadius: BorderRadius.circular(25),
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                  );
                  setState(() {});
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 40),
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF833AB4), Color(0xFFFD1D1D), Color(0xFFFCB045)],
                    ),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF833AB4).withOpacity(0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      'Edit Profile',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              _buildProfileGrid(uid),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatsRow(String uid) {
    return FutureBuilder(
      future: FirebaseFirestore.instance.collection('users').doc(uid).get(),
      builder: (_, uSnap) {
        final d = uSnap.data?.data() as Map<String, dynamic>? ?? {};
        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('posts').where('uid', isEqualTo: uid).snapshots(),
          builder: (_, snap) {
            final postCount = snap.data?.docs.length ?? 0;
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _statBox('Posts', postCount.toString()),
                _statBox('Followers', (d['followersCount'] ?? 0).toString()),
                _statBox('Following', (d['followingCount'] ?? 0).toString()),
              ],
            );
          },
        );
      },
    );
  }

  Widget _statBox(String label, String value) => Expanded(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 6),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.12)),
          ),
          child: Column(children: [
            Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.6))),
          ]),
        ),
      );

  Widget _buildProfileGrid(String uid) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('posts')
          .where('uid', isEqualTo: uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: CircularProgressIndicator(color: Colors.white)),
          );
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Text('No posts yet', style: TextStyle(color: Colors.white.withOpacity(0.5))),
          );
        }
        final posts = snapshot.data!.docs.where((doc) {
          final imageUrl = (doc.data()['imageUrl'] ?? '').toString();
          return imageUrl.isNotEmpty && !imageUrl.contains('firebasestorage.googleapis.com');
        }).toList();

        if (posts.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Text('No posts yet.\nTap + to upload!',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white.withOpacity(0.5))),
          );
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(2),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 2,
            mainAxisSpacing: 2,
          ),
          itemCount: posts.length,
          itemBuilder: (context, index) {
            final postData = posts[index].data();
            final imageUrl = (postData['imageUrl'] ?? '').toString();
            return ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: imageUrl.isEmpty
                  ? Container(color: Colors.white12, child: const Icon(Icons.broken_image, color: Colors.white38))
                  : Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      loadingBuilder: (_, child, loading) =>
                          loading == null ? child : const Center(child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
                      errorBuilder: (_, __, ___) =>
                          Container(color: Colors.white12, child: const Icon(Icons.broken_image, color: Colors.white38)),
                    ),
            );
          },
        );
      },
    );
  }

  Widget _buildStylishBottomNav() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(35),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.10),
              borderRadius: BorderRadius.circular(35),
              border: Border.all(color: Colors.white.withOpacity(0.16)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 28,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildNavItem(0, Icons.home_rounded, Icons.home_outlined),
                _buildNavItem(1, Icons.add_box_rounded, Icons.add_box_outlined),
                _buildNavItem(2, Icons.person_rounded, Icons.person_outline_rounded),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData activeIcon, IconData inactiveIcon) {
    final isSelected = _index == index;
    return GestureDetector(
      onTap: () => _onTabSelected(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(horizontal: isSelected ? 24 : 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(colors: [Color(0xFF833AB4), Color(0xFFFD1D1D)])
              : null,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(
          isSelected ? activeIcon : inactiveIcon,
          color: isSelected ? Colors.white : Colors.white38,
          size: 28,
        ),
      ),
    );
  }

  Widget _buildStylishFAB() {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const UploadPostScreen())),
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [Color(0xFF833AB4), Color(0xFFFD1D1D), Color(0xFFFCB045)],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF833AB4).withOpacity(0.5),
              blurRadius: 25,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: const Icon(Icons.camera_alt, color: Colors.white, size: 32),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════
// ✅ _PostCard — fully interactive with LIVE likes & comments
// ══════════════════════════════════════════════════════════════════
class _PostCard extends StatefulWidget {
  final String postId;
  final String imageUrl;
  final String caption;
  final String username;

  const _PostCard({
    required this.postId,
    required this.imageUrl,
    required this.caption,
    required this.username,
  });

  @override
  State<_PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<_PostCard> {
  final _likeService = LikeService();
  final _commentService = CommentService();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: const Color(0xFF101325),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.25), blurRadius: 24, offset: const Offset(0, 12)),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        // ── Header ────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
          child: Row(children: [
            Container(
              width: 42, height: 42,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(colors: [Color(0xFF833AB4), Color(0xFFFD1D1D)]),
              ),
              child: const Icon(Icons.person, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 12),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(widget.username, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white)),
              Text('Just now', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
            ]),
            const Spacer(),
            Icon(Icons.more_horiz, color: Colors.white.withOpacity(0.5)),
          ]),
        ),

        // ── Image ─────────────────────────────────────────────────
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: AspectRatio(
            aspectRatio: 1,
            child: widget.imageUrl.isEmpty
                ? Container(color: Colors.white12, child: const Icon(Icons.image, color: Colors.white38, size: 50))
                : Image.network(
                    widget.imageUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (_, child, loading) =>
                        loading == null ? child : const Center(child: CircularProgressIndicator(color: Colors.white)),
                    errorBuilder: (_, __, ___) =>
                        Container(color: Colors.white12, child: const Icon(Icons.broken_image, color: Colors.white38)),
                  ),
          ),
        ),

        // ── Like + Comment buttons (LIVE) ─────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: StreamBuilder<bool>(
            stream: _likeService.isLikedStream(widget.postId),
            builder: (context, likedSnap) {
              final isLiked = likedSnap.data ?? false;
              return Row(children: [

                // ✅ Like button — tappable, turns red when liked
                GestureDetector(
                  onTap: () => _likeService.toggleLike(widget.postId),
                  child: Row(children: [
                    Icon(
                      isLiked ? Icons.favorite : Icons.favorite_border,
                      color: isLiked ? Colors.redAccent : Colors.white70,
                      size: 28,
                    ),
                    const SizedBox(width: 6),
                    // ✅ Live like count from Firestore
                    StreamBuilder<int>(
                      stream: _likeService.likeCountStream(widget.postId),
                      builder: (_, countSnap) => Text(
                        '${countSnap.data ?? 0}',
                        style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w600, fontSize: 15),
                      ),
                    ),
                  ]),
                ),

                const SizedBox(width: 20),

                // ✅ Comment button — shows comments in bottom sheet
                GestureDetector(
                  onTap: () {
                    final post = PostModel(
                      postId: widget.postId,
                      username: widget.username,
                      imagePath: '', // Not used
                      imageUrl: widget.imageUrl,
                      caption: widget.caption,
                      createdAt: DateTime.now(), // Placeholder
                    );
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => CommentsBottomSheet(
                        post: post,
                        onUpdated: () => setState(() {}),
                      ),
                    );
                  },
                  child: Row(children: [
                    const Icon(
                      Icons.chat_bubble_outline,
                      color: Colors.white70,
                      size: 26,
                    ),
                    const SizedBox(width: 6),
                    // ✅ Live comment count from Firestore
                    StreamBuilder<QuerySnapshot>(
                      stream: _commentService.commentsStream(widget.postId),
                      builder: (_, snap) => Text(
                        '${snap.data?.docs.length ?? 0}',
                        style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w600, fontSize: 15),
                      ),
                    ),
                  ]),
                ),

                const Spacer(),
                const Icon(Icons.bookmark_border, color: Colors.white70, size: 26),
              ]);
            },
          ),
        ),

        // ── Caption ───────────────────────────────────────────────
        if (widget.caption.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
            child: RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 14, color: Colors.white),
                children: [
                  TextSpan(text: '${widget.username} ', style: const TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: widget.caption, style: TextStyle(color: Colors.white.withOpacity(0.8))),
                ],
              ),
            ),
          )
        else
          const SizedBox(height: 10),
      ]),
    );
  }
}
