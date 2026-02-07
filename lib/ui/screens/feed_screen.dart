import 'dart:ui'; // Required for Blur
import 'package:bookproject/ui/screens/post_comments.dart';
import 'package:bookproject/ui/widgets/app_background.dart';
import 'package:bookproject/ui/widgets/app_background2.dart';
import 'package:bookproject/ui/widgets/telegram_image.dart';
import 'package:flutter/material.dart';
import '../../services/post_service.dart';
import '../../services/auth_api.dart';
import 'create_post_screen.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  List posts = [];
  bool loading = true;
  String? currentUserId;
  Set<String> followingIds = {};

  Map<String, int> currentIndex = {};
  Map<String, bool> showHeart = {};

  final Color kAccentColor = const Color(0xFF00E676);
  final Color kCardBg = const Color(0xFF121212).withOpacity(0.65);

  @override
  void initState() {
    super.initState();
    loadFeed();
  }

  Future<void> loadFeed() async {
    setState(() => loading = true);

    try {
      // 🔥 YE LINE MISSING THI
      currentUserId = await AuthApi.getUserId();

      final feed = await ApiService.getFeed();
      posts = feed;

      // 🔥 FOLLOWING LOAD
      if (currentUserId != null) {
        final following = await AuthApi.getFollowing(currentUserId!);
        followingIds =
            following.map((u) => u["_id"].toString()).toSet();
      }

    } catch (e) {
      debugPrint("Feed Error: $e");
    }

    setState(() => loading = false);
  }



  Future<void> _toggleFollow(String targetUserId) async {
    bool isCurrentlyFollowing = followingIds.contains(targetUserId);
    setState(() {
      if (isCurrentlyFollowing) followingIds.remove(targetUserId);
      else followingIds.add(targetUserId);
    });

    bool success;
    if (isCurrentlyFollowing) success = await AuthApi.unfollowUser(targetUserId);
    else success = await AuthApi.followUser(targetUserId);

    if (!success && mounted) {
      setState(() {
        if (isCurrentlyFollowing) followingIds.add(targetUserId);
        else followingIds.remove(targetUserId);
      });
    }
  }

  Future<void> _deletePost(String postId) async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF222222),
        title: const Text("Delete Post?", style: TextStyle(color: Colors.white)),
        content: const Text("Cannot be undone.", style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(child: const Text("Cancel"), onPressed: () => Navigator.pop(context, false)),
          TextButton(child: const Text("Delete", style: TextStyle(color: Colors.redAccent)), onPressed: () => Navigator.pop(context, true)),
        ],
      ),
    ) ?? false;

    if (confirm) {
      bool success = await ApiService.deletePost(postId);
      if (success) setState(() => posts.removeWhere((p) => p['_id'] == postId));
    }
  }

  Future<void> _toggleLike(Map post) async {
    final String id = post["_id"];
    if (currentUserId == null) return;
    setState(() {
      List likes = List.from(post['likes'] ?? []);
      if (likes.contains(currentUserId)) likes.remove(currentUserId);
      else likes.add(currentUserId);
      post['likes'] = likes;
    });
    await ApiService.toggleLike(id);
  }

  // --- HEADER ---
  Widget _buildHeader() {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            border: const Border(bottom: BorderSide(color: Colors.white10, width: 0.5)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Libzo", style: TextStyle(fontFamily: 'Cursive', color: kAccentColor, fontSize: 28, fontWeight: FontWeight.bold)),
              IconButton(onPressed: loadFeed, icon: const Icon(Icons.refresh_rounded, color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFollowButton(String userId, bool isFollowing) {
    return GestureDetector(
      onTap: () => _toggleFollow(userId),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: EdgeInsets.symmetric(horizontal: isFollowing ? 12 : 14, vertical: 5),
        decoration: BoxDecoration(
          color: isFollowing ? Colors.transparent : kAccentColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isFollowing ? Colors.white38 : kAccentColor),
        ),
        child: Text(
          isFollowing ? "Following" : "Follow",
          style: TextStyle(color: isFollowing ? Colors.white : Colors.black, fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  // --- POST CARD ---
  Widget _buildPostCard(Map post) {
    final String id = post["_id"] ?? "";
    final Map userObj = post['userId'] is Map ? post['userId'] : {};
    final String postOwnerId = userObj['_id'] ?? "";
    final String userName = userObj['username'] ?? userObj['name'] ?? "User";
    final String postText = post['text'] ?? "";
    final List images = post["images"] ?? [];
    final int commentCount = post['commentCount'] ?? 0; // 🔥 Fetch Comment Count

    bool isLiked = (post['likes'] ?? []).contains(currentUserId);
    bool isFollowing = followingIds.contains(postOwnerId);
    bool isMyPost = currentUserId == postOwnerId;

    return GestureDetector(
      onDoubleTap: () async {
        setState(() => showHeart[id] = true);
        await _toggleLike(post);
        Future.delayed(const Duration(milliseconds: 800), () {
          if (mounted) setState(() => showHeart[id] = false);
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: kCardBg.withOpacity(0.8),
          border: const Border.symmetric(horizontal: BorderSide(color: Colors.white10, width: 0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. HEADER
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: kAccentColor.withOpacity(0.5))),
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.grey[800],
                      child: Text(userName.isNotEmpty ? userName[0].toUpperCase() : "?", style: const TextStyle(color: Colors.white)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(child: Text(userName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15))),
                            if (!isMyPost) ...[
                              const Padding(padding: EdgeInsets.symmetric(horizontal: 6), child: Icon(Icons.circle, size: 3, color: Colors.grey)),
                              _buildFollowButton(postOwnerId, isFollowing),
                            ]
                          ],
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_horiz, color: Colors.white70),
                    color: const Color(0xFF2C2C2C),
                    onSelected: (val) { if (val == 'delete') _deletePost(id); },
                    itemBuilder: (context) => [
                      if (isMyPost) const PopupMenuItem(value: 'delete', child: Text("Delete", style: TextStyle(color: Colors.redAccent))),
                      const PopupMenuItem(value: 'profile', child: Text("View Profile", style: TextStyle(color: Colors.white))),
                    ],
                  ),
                ],
              ),
            ),

            // 2. TEXT CONTENT (Above Image)
            if (postText.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
                child: ExpandableText(
                  text: postText,
                  accentColor: kAccentColor,
                ),
              ),

            // 3. IMAGE CAROUSEL
            if (images.isNotEmpty)
              _buildImageCarousel(images, id, post),

            // 4. ACTION BAR (Icons)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => _toggleLike(post),
                    child: Icon(isLiked ? Icons.favorite : Icons.favorite_border_rounded, color: isLiked ? kAccentColor : Colors.white, size: 28),
                  ),
                  const SizedBox(width: 20),
                  GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CommentsScreen(postId: id))),
                    child: const Icon(Icons.chat_bubble_outline_rounded, color: Colors.white, size: 26),
                  ),
                  const SizedBox(width: 20),
                  const Icon(Icons.send_rounded, color: Colors.white, size: 26),
                  const Spacer(),
                  const Icon(Icons.bookmark_border_rounded, color: Colors.white, size: 28),
                ],
              ),
            ),

            // 5. LIKES COUNT
            if ((post['likes']?.length ?? 0) > 0)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Text("${post['likes']?.length} likes", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
              ),

            // 6. 🔥 COMMENTS COUNT (Instagram Style)
            if (commentCount > 0)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                child: GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CommentsScreen(postId: id))),
                  child: Text(
                    "View all $commentCount comments",
                    style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14),
                  ),
                ),
              ),

            const SizedBox(height: 15),
          ],
        ),
      ),
    );
  }

  Widget _buildImageCarousel(List images, String id, Map post) {
    return LayoutBuilder(builder: (context, constraints) {
      final img = images[currentIndex[id] ?? 0];
      final double originalW = (img["width"] ?? 1).toDouble();
      final double originalH = (img["height"] ?? 1).toDouble();
      double finalH = (constraints.maxWidth * (originalH / originalW)).clamp(250.0, 550.0);

      return GestureDetector(
        onDoubleTap: () async {
          setState(() => showHeart[id] = true);
          await _toggleLike(post);
          Future.delayed(const Duration(milliseconds: 800), () {
            if (mounted) setState(() => showHeart[id] = false);
          });
        },
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            SizedBox(
              height: finalH,
              width: double.infinity,
              child: PageView(
                onPageChanged: (i) => setState(() => currentIndex[id] = i),
                children: images.map<Widget>((img) => TelegramImage(fileId: img["file_id"], fit: BoxFit.cover)).toList(),
              ),
            ),
            if (showHeart[id] == true)
              const Center(child: Icon(Icons.favorite, size: 100, color: Colors.white70)),

            if (images.length > 1)
              Positioned(
                bottom: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(images.length, (i) {
                      bool active = (currentIndex[id] ?? 0) == i;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 2.5),
                        width: active ? 8 : 6,
                        height: active ? 8 : 6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: active ? kAccentColor : Colors.white54,
                        ),
                      );
                    }),
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      floatingActionButton: FloatingActionButton(
        backgroundColor: kAccentColor,
        child: const Icon(Icons.add, color: Colors.black, size: 30),
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (_) => const CreatePostScreen()));
          loadFeed();
        },
      ),
      body: AppBackground(
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: loading
                    ? Center(child: CircularProgressIndicator(color: kAccentColor))
                    : RefreshIndicator(
                  onRefresh: loadFeed,
                  color: kAccentColor,
                  backgroundColor: Colors.grey[900],
                  child: ListView.builder(
                    itemCount: posts.length,
                    itemBuilder: (context, index) => _buildPostCard(posts[index]),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ExpandableText extends StatefulWidget {
  final String text;
  final Color accentColor;

  const ExpandableText({super.key, required this.text, required this.accentColor});

  @override
  State<ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText> {
  bool isExpanded = false;
  static const int maxLines = 3;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final span = TextSpan(text: widget.text, style: const TextStyle(fontSize: 15, color: Colors.white, height: 1.4));
        final tp = TextPainter(text: span, maxLines: maxLines, textDirection: TextDirection.ltr);
        tp.layout(maxWidth: constraints.maxWidth);

        if (!tp.didExceedMaxLines) {
          return Text(widget.text, style: const TextStyle(fontSize: 15, color: Colors.white, height: 1.4));
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: Text(
                widget.text,
                maxLines: isExpanded ? null : maxLines,
                overflow: isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 15, color: Colors.white, height: 1.4),
              ),
            ),
            GestureDetector(
              onTap: () => setState(() => isExpanded = !isExpanded),
              child: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  isExpanded ? "Show less" : "Read more",
                  style: TextStyle(color: widget.accentColor, fontWeight: FontWeight.w600, fontSize: 14),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}