import 'package:flutter/material.dart';
import 'upload_post_screen.dart';
import '../services/feed_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  void _onTabSelected(int index) {
    setState(() => _index = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFFFF9500),  // vibrant orange
              const Color(0xFFFFAB76),  // warm peach
              const Color(0xFFFFDAC1),  // soft coral
            ].map((c) => c.withOpacity(0.08)).toList(),  // softer background opacity
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Color(0xFFFF9500), Color(0xFFFFAB76), Color(0xFFFF6B6B)],
            ).createShader(bounds),
            child: const Text(
              'Pixta',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const Spacer(),
          _buildAppBarIcon(Icons.favorite_border, () {}),
          const SizedBox(width: 12),
          _buildAppBarIcon(Icons.send_outlined, () {}),
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
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, size: 24, color: Colors.grey.shade800),
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

  Widget _buildFeedScreen() {
  return StreamBuilder(
    stream: FeedService().getFeed(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }

      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
        return const Center(
          child: Text(
            "No posts yet",
            style: TextStyle(fontSize: 18),
          ),
        );
      }

      return ListView.builder(
        physics: const BouncingScrollPhysics(),
        itemCount: snapshot.data!.docs.length,
        itemBuilder: (context, index) {
          final data = snapshot.data!.docs[index];

          return _buildRealPostCard(
            imageUrl: data['imageUrl'],
            caption: data['caption'],
          );
        },
      );
    },
  );
}


  Widget _buildStylishPostCard(int index) {
    final colors = [
      [const Color(0xFFFF9500), const Color(0xFFFFAB76)],     // orange-peach
      [const Color(0xFFFF6B6B), const Color(0xFFFFDAC1)],     // coral-soft
      [const Color(0xFF34D399), const Color(0xFF6EE7B7)],     // mint-green happy
      [const Color(0xFF60A5FA), const Color(0xFF93C5FD)],     // fresh blue
      [const Color(0xFFFBBF24), const Color(0xFFFCD34D)],     // sunny yellow
    ];

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: colors[index % colors.length][0].withOpacity(0.18),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: colors[index % colors.length],
                    ),
                  ),
                  child: const Icon(Icons.person, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'User ${index + 1}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      '${index + 1} hours ago',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Icon(Icons.more_vert, color: Colors.grey.shade700),
              ],
            ),
          ),
          Container(
            height: 320,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: colors[index % colors.length],
              ),
            ),
            child: Center(
              child: Icon(
                Icons.photo_library,
                size: 80,
                color: Colors.white.withOpacity(0.6),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _buildActionButton(Icons.favorite_border, '${(index + 1) * 42}'),
                    const SizedBox(width: 16),
                    _buildActionButton(Icons.chat_bubble_outline, '${(index + 1) * 8}'),
                    const SizedBox(width: 16),
                    _buildActionButton(Icons.send_outlined, '${(index + 1) * 3}'),
                    const Spacer(),
                    Icon(Icons.bookmark_border, color: Colors.grey.shade800),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Amazing post content here! 🎨✨',
                  style: TextStyle(
                    color: Colors.grey.shade800,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String count) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey.shade800, size: 26),
        const SizedBox(width: 6),
        Text(
          count,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
  Widget _buildRealPostCard({
  required String imageUrl,
  required String caption,
}) {
  return Container(
    margin: const EdgeInsets.only(bottom: 24),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.06),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          leading: const CircleAvatar(
            child: Icon(Icons.person),
          ),
          title: const Text("User"),
          subtitle: const Text("Just now"),
          trailing: const Icon(Icons.more_vert),
        ),

        AspectRatio(
          aspectRatio: 1,
          child: Image.network(
            imageUrl,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loading) {
              if (loading == null) return child;
              return const Center(child: CircularProgressIndicator());
            },
          ),
        ),

        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            caption,
            style: const TextStyle(fontSize: 15),
          ),
        ),
      ],
    ),
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
              return Transform.scale(
                scale: 0.8 + (0.2 * value),
                child: child,
              );
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
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Share your moments with the world',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileScreen() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFFFF9500), Color(0xFFFFAB76), Color(0xFFFF6B6B)],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF9500).withOpacity(0.35),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
              ],
            ),
            child: const Icon(Icons.person, size: 60, color: Colors.white),
          ),
          const SizedBox(height: 20),
          const Text(
            'Your Name',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '@username • Digital Creator',
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatCard('Posts', '127'),
              _buildStatCard('Followers', '2.5K'),
              _buildStatCard('Following', '312'),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 40),
            height: 50,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF9500), Color(0xFFFFAB76)],
              ),
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF9500).withOpacity(0.35),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Center(
              child: Text(
                'Edit Profile',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          _buildProfileGrid(),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(2),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemCount: 12,
      itemBuilder: (context, index) {
        final colors = [
          [const Color(0xFFFF9500), const Color(0xFFFFAB76)],
          [const Color(0xFFFF6B6B), const Color(0xFFFFDAC1)],
          [const Color(0xFF34D399), const Color(0xFF6EE7B7)],
          [const Color(0xFFFBBF24), const Color(0xFFFCD34D)],
        ];

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: colors[index % colors.length],
            ),
          ),
          child: Center(
            child: Icon(
              Icons.image,
              color: Colors.white.withOpacity(0.75),
              size: 40,
            ),
          ),
        );
      },
    );
  }

  Widget _buildStylishBottomNav() {
    return Container(
      margin: const EdgeInsets.all(20),
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(35),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 30,
            offset: const Offset(0, 10),
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
    );
  }

  Widget _buildNavItem(int index, IconData activeIcon, IconData inactiveIcon) {
    final isSelected = _index == index;

    return GestureDetector(
      onTap: () => _onTabSelected(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 24 : 16,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFFFF9500), Color(0xFFFFAB76)],
                )
              : null,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(
          isSelected ? activeIcon : inactiveIcon,
          color: isSelected ? Colors.white : Colors.grey.shade600,
          size: 28,
        ),
      ),
    );
  }

  Widget _buildStylishFAB() {
    return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const UploadPostScreen(),
        ),
      );
    },
    child: Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [Color(0xFFFF9500), Color(0xFFFFAB76), Color(0xFFFF6B6B)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF9500).withOpacity(0.45),
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