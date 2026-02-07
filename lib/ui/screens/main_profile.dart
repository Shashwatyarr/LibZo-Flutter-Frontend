import 'package:bookproject/ui/widgets/app_background2.dart';
import 'package:flutter/material.dart';
import '../../services/auth_api.dart';
import '../../services/profile_api.dart';
import '../widgets/telegram_image.dart';

class ProfileScreen extends StatefulWidget {
  final String? userId;

  const ProfileScreen({super.key, this.userId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool loading = true;

  Map<String, dynamic>? userProfile;
  List userPosts = [];

  String? currentUserId;
  bool isMyProfile = false;
  bool isFollowing = false;

  final Color kAccent = const Color(0xFF00E676);
  final Color kCard = const Color(0xff16181C);

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    if (!mounted) return;

    setState(() => loading = true);

    currentUserId = await AuthApi.getUserId();
    String targetId = widget.userId ?? currentUserId ?? "";

    if (targetId.isEmpty) {
      setState(() => loading = false);
      return;
    }

    try {
      isMyProfile = currentUserId == targetId;

      final profile = await ProfileApi.getUserProfile(targetId);
      final posts = await ProfileApi.getUserPosts(targetId);

      bool following = false;

      if (!isMyProfile) {
        following = await AuthApi.isFollowing(targetId);
      }

      if (mounted) {
        setState(() {
          userProfile = profile;
          userPosts = posts;
          isFollowing = following;
          loading = false;
        });
      }
    } catch (e) {
      setState(() => loading = false);
    }
  }

  Future<void> _toggleFollow() async {
    if (userProfile == null) return;

    String targetId = userProfile!['_id'];
    bool old = isFollowing;

    setState(() => isFollowing = !old);

    bool success = !old
        ? await AuthApi.followUser(targetId)
        : await AuthApi.unfollowUser(targetId);

    if (!success && mounted) {
      setState(() => isFollowing = old);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF00E676)),
        ),
      );
    }

    if (userProfile == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text("User not found",
              style: TextStyle(color: Colors.white)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          "@${userProfile?['username']}",
          style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white),
        ),
        centerTitle: true,
      ),

      body: AppBackground2(
        child: RefreshIndicator(
          onRefresh: loadProfile,
          color: kAccent,

          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ModernProfileHeader(user: userProfile!),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ActionButtons(
                    isMe: isMyProfile,
                    isFollowing: isFollowing,
                    onFollowTap: _toggleFollow,
                  ),
                ),

                const SizedBox(height: 20),

                const Divider(color: Colors.white10),

                if (userPosts.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 80),
                    child: Center(
                      child: Text(
                        "No posts yet.",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: userPosts.length,
                    itemBuilder: (c, i) =>
                        ModernPostCard(post: userPosts[i]),
                  ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ======================================================
//                    PROFILE HEADER
// ======================================================

class ModernProfileHeader extends StatelessWidget {
  final Map user;

  const ModernProfileHeader({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    String avatarText = (user['username'] ?? "U")[0].toUpperCase();

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: const Color(0xff16181C).withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.white12,
                child: Text(
                  avatarText,
                  style: const TextStyle(
                      fontSize: 32,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(width: 20),

              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _Stat(label: "Posts",
                        value: "${user['postsCount'] ?? 0}"),

                    _Stat(label: "Followers",
                        value: "${(user['followers'] ?? []).length}"),

                    _Stat(label: "Following",
                        value: "${(user['following'] ?? []).length}"),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              Text(
                user['fullName'] ?? user['username'],
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),

              const SizedBox(width: 6),

              const Icon(Icons.verified,
                  color: Color(0xFF00E676), size: 18),
            ],
          ),

          const SizedBox(height: 6),

          Text(
            user['bio'] ?? "No bio available.",
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;

  const _Stat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white)),

        Text(label,
            style: const TextStyle(color: Colors.grey)),
      ],
    );
  }
}

// ======================================================
//                  FOLLOW / EDIT BUTTON
// ======================================================

class ActionButtons extends StatelessWidget {
  final bool isMe;
  final bool isFollowing;
  final VoidCallback onFollowTap;

  const ActionButtons({
    super.key,
    required this.isMe,
    required this.isFollowing,
    required this.onFollowTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: isMe
          ? OutlinedButton.icon(
        onPressed: ()=>Navigator.pushReplacementNamed(context,"/profileanalytics"),
        icon: const Icon(Icons.bar_chart, color: Colors.white),
        label: const Text("Profile Analytics",
            style: TextStyle(color: Colors.white)),
      )
          : ElevatedButton(
        onPressed: onFollowTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: isFollowing
              ? const Color(0xff16181C)
              : const Color(0xFF00E676),
        ),
        child: Text(
          isFollowing ? "Following" : "Follow",
          style: TextStyle(
              color: isFollowing
                  ? Colors.white
                  : Colors.black),
        ),
      ),
    );
  }
}

// ======================================================
//                     POST CARD
// ======================================================

class ModernPostCard extends StatelessWidget {
  final Map post;

  const ModernPostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    final Map userObj =
    post['userId'] is Map ? post['userId'] : post;

    final String userName =
        userObj['username'] ?? "User";

    final String postText = post['text'] ?? "";
    final List images = post['images'] ?? [];

    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(14),

      decoration: BoxDecoration(
        color: const Color(0xff16181C).withOpacity(0.5),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white10),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.white12,
                child: Text(userName[0].toUpperCase()),
              ),

              const SizedBox(width: 10),

              Text(userName,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold)),

              const Spacer(),

              const Icon(Icons.more_vert, color: Colors.grey)
            ],
          ),

          if (postText.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(postText,
                style: const TextStyle(color: Colors.white)),
          ],

          if (images.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: TelegramImage(
                    fileId: images[0]['file_id'],
                    fit: BoxFit.cover),
              ),
            ),

          const SizedBox(height: 10),

          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Icon(Icons.favorite_border, color: Colors.grey),
              Icon(Icons.chat_bubble_outline,
                  color: Colors.grey),
              Icon(Icons.share, color: Colors.grey),
              Icon(Icons.bookmark_border,
                  color: Colors.grey),
            ],
          )
        ],
      ),
    );
  }
}
