import 'package:bookproject/ui/screens/post_comments.dart';
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

  Map<String, int> currentIndex = {};
  Map<String, bool> showHeart = {};

  final Color kAccentColor = const Color(0xFF00E676);

  @override
  void initState() {
    super.initState();
    loadFeed();
  }

  Future<void> loadFeed() async {
    setState(() => loading = true);

    try {
      posts = await ApiService.getFeed();
    } catch (e) {
      debugPrint("Feed Error: $e");
    }

    setState(() => loading = false);
  }

  String timeAgo(String date) {
    DateTime time = DateTime.parse(date).toLocal();
    Duration diff = DateTime.now().difference(time);

    if (diff.inMinutes < 60) return "${diff.inMinutes}m ago";
    if (diff.inHours < 24) return "${diff.inHours}h ago";
    return "${diff.inDays}d ago";
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          Text(
            "Libzo Feed",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleLike(Map post) async {
    final String id = post["_id"];

    String? myId = await AuthApi.getUserId();
    if (myId == null) return;

    bool success = await ApiService.toggleLike(id);
    if (!success) return;

    setState(() {
      List likes = List.from(post['likes'] ?? []);

      bool alreadyLiked = likes.contains(myId);

      if (alreadyLiked) {
        likes.remove(myId);
      } else {
        likes.add(myId);
      }

      post['likes'] = likes;
    });
  }

  Widget _buildPostCard(Map post) {
    final String id = post["_id"] ?? "";

    final String userName =
        post['userId']?['username'] ??
            post['userId']?['name'] ??
            "Reader";

    final String postText = post['text'] ?? "";
    final List images = post["images"] ?? [];

    return GestureDetector(
        onDoubleTap: () async {
          setState(() => showHeart[id] = true);

          await _toggleLike(post);

          Future.delayed(const Duration(milliseconds: 800), () {
            setState(() => showHeart[id] = false);
          });},
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.25),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: Colors.white12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: kAccentColor.withOpacity(0.2),
                  child: Text(
                    userName[0].toUpperCase(),
                    style: TextStyle(color: kAccentColor),
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(userName,
                        style: const TextStyle(color: Colors.white)),
                    Text(timeAgo(post['createdAt']),
                        style: TextStyle(color: kAccentColor)),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 12),

            if (images.isNotEmpty)
              LayoutBuilder(
                builder: (context, constraints) {
                  final img = images[currentIndex[id] ?? 0];

                  final double originalW =
                  (img["width"] ?? 1).toDouble();
                  final double originalH =
                  (img["height"] ?? 1).toDouble();

                  double screenW = constraints.maxWidth;
                  double calculatedH =
                      screenW * (originalH / originalW);

                  double finalH =
                  calculatedH > 600 ? 600 : calculatedH;

                  return GestureDetector(
                    onDoubleTap: () async {
                      setState(() => showHeart[id] = true);

                      await _toggleLike(post);

                      Future.delayed(const Duration(milliseconds: 800), () {
                        setState(() => showHeart[id] = false);
                      });
                    },
                    child: Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        SizedBox(
                          height: finalH,
                          child: PageView(
                            onPageChanged: (i) {
                              setState(() {
                                currentIndex[id] = i;
                              });
                            },
                            children: images.map<Widget>((img) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: TelegramImage(
                                    fileId: img["file_id"],
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),

                        if (showHeart[id] == true)
                          const Center(
                            child: Icon(
                              Icons.favorite,
                              size: 120,
                              color: Colors.white70,
                            ),
                          ),

                        if (images.length > 1)
                          Positioned(
                            bottom: 10,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.6),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: List.generate(images.length, (i) {
                                  bool active =
                                      (currentIndex[id] ?? 0) == i;

                                  return AnimatedContainer(
                                    duration:
                                    const Duration(milliseconds: 200),
                                    margin:
                                    const EdgeInsets.symmetric(horizontal: 3),
                                    width: active ? 9 : 6,
                                    height: active ? 9 : 6,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: active
                                          ? kAccentColor
                                          : Colors.white54,
                                    ),
                                  );
                                }),
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),

            const SizedBox(height: 10),

            Text(postText,
                style: const TextStyle(color: Colors.white)),

            const SizedBox(height: 10),

            FutureBuilder<String?>(
              future: AuthApi.getUserId(),
              builder: (context, snap) {
                String? myId = snap.data;
                bool isLiked =
                    myId != null &&
                        (post['likes'] ?? []).contains(myId);

                return Row(
                  children: [
                    GestureDetector(
                      onTap: () => _toggleLike(post),
                      child: Row(
                        children: [
                          Icon(Icons.favorite,
                              color: isLiked
                                  ? kAccentColor
                                  : Colors.grey),
                          const SizedBox(width: 6),
                          Text("${post['likes']?.length ?? 0}",
                              style: const TextStyle(
                                  color: Colors.white)),
                        ],
                      ),
                    ),

                    const SizedBox(width: 20),

                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              CommentsScreen(postId: id),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.chat,
                              color: Colors.grey),
                          const SizedBox(width: 6),
                          Text("${post['commentCount'] ?? 0}",
                              style: const TextStyle(
                                  color: Colors.white)),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.3),
      floatingActionButton: FloatingActionButton(
        backgroundColor: kAccentColor,
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => const CreatePostScreen()),
          );
          loadFeed();
        },
        child: const Icon(Icons.edit, color: Colors.black),
      ),
      body: AppBackground2(
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: loading
                    ? Center(
                  child: CircularProgressIndicator(
                      color: kAccentColor),
                )
                    : RefreshIndicator(
                  onRefresh: loadFeed,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: posts.length,
                    itemBuilder: (context, index) {
                      return _buildPostCard(posts[index]);
                    },
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
