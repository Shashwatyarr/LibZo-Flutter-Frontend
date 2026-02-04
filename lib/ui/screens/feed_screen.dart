import 'package:bookproject/ui/screens/post_comments.dart';
import 'package:bookproject/ui/widgets/app_background2.dart';
import 'package:bookproject/ui/widgets/telegram_image.dart';
import 'package:flutter/material.dart';
import '../../services/post_service.dart';
import 'create_post_screen.dart';
import '../../services/auth_api.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  List posts = [];
  bool loading = true;
  Map<String, bool> showHeart = {};
  Map<String, int> currentIndex = {};

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
      debugPrint("Error: $e");
    }
    setState(() => loading = false);
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
            MaterialPageRoute(builder: (_) => const CreatePostScreen()),
          );
          loadFeed();
        },
        child: const Icon(Icons.edit, color: Colors.black),
      ),

      body: AppBackground2(
        child: SafeArea(
          child: loading
              ? Center(
            child: CircularProgressIndicator(color: kAccentColor),
          )
              : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: posts.length,
            itemBuilder: (context, index) {
              return _buildPostCard(posts[index]);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPostCard(Map post) {
    final String userName =
        post['userId']?['username'] ?? "Unknown User";

    final String postText = post['text'] ?? "";

    DateTime time =
    DateTime.parse(post['createdAt']).toLocal();

    Duration diff = DateTime.now().difference(time);

    String timeAgo;
    if (diff.inMinutes < 60) {
      timeAgo = "${diff.inMinutes}m ago";
    } else if (diff.inHours < 24) {
      timeAgo = "${diff.inHours}h ago";
    } else {
      timeAgo = "${diff.inDays}d ago";
    }

    return Container(
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

          // -------- USER HEADER --------
          Row(
            children: [
              CircleAvatar(
                child: Text(userName[0].toUpperCase()),
              ),

              const SizedBox(width: 10),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(userName,
                      style: const TextStyle(color: Colors.white)),

                  Text(timeAgo,
                      style: TextStyle(color: kAccentColor)),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ===========================================
          // 🔥 IMAGE SECTION – REAL FIX HERE
          // ===========================================

          // -------------------------------
// 🔥 IMAGE SECTION WITH REAL SIZE
// -------------------------------
          if (post["images"] != null && post["images"].length > 0)

            LayoutBuilder(
              builder: (context, constraints) {

                final img = post["images"][currentIndex[post["_id"]] ?? 0];

                final double originalW = (img["width"] ?? 1).toDouble();
                final double originalH = (img["height"] ?? 1).toDouble();

                double screenW = constraints.maxWidth;

                // 🔥 REAL HEIGHT FROM BACKEND
                double calculatedH = screenW * (originalH / originalW);

                // MAX LIMIT
                double finalH = calculatedH > 600 ? 600 : calculatedH;

                return Stack(
                  alignment: Alignment.bottomCenter,

                  children: [

                    // -------- IMAGE WITH EXACT HEIGHT --------
                    SizedBox(
                      height: finalH,

                      child: PageView(
                        onPageChanged: (i) {
                          setState(() {
                            currentIndex[post["_id"]] = i;
                          });
                        },

                        children: (post["images"] as List).map<Widget>((img) {

                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),

                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),

                              child: TelegramImage(
                                fileId: img["file_id"],

                                // ab fit matter nahi karega
                                fit: BoxFit.cover,
                              ),
                            ),
                          );

                        }).toList(),
                      ),
                    ),

                    // -------- DOTS ON IMAGE --------
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
                          mainAxisSize: MainAxisSize.min,

                          children: List.generate(
                            (post["images"] as List).length,
                                (i) {

                              bool active =
                                  (currentIndex[post["_id"]] ?? 0) == i;

                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 200),

                                margin: const EdgeInsets.symmetric(horizontal: 3),

                                width: active ? 8 : 6,
                                height: active ? 8 : 6,

                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: active
                                      ? const Color(0xFF00E676)
                                      : Colors.white54,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),


          const SizedBox(height: 10),

          // -------- TEXT --------
          Text(
            postText,
            style: const TextStyle(color: Colors.white),
          ),

          const SizedBox(height: 10),

          // -------- ACTIONS --------
          Row(
            children: [
              Icon(Icons.favorite, color: kAccentColor),
              const SizedBox(width: 6),
              Text("${post['likes']?.length ?? 0}",
                  style: const TextStyle(color: Colors.white)),

              const SizedBox(width: 20),

              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        CommentsScreen(postId: post['_id']),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.chat, color: Colors.grey),
                    const SizedBox(width: 6),
                    Text("${post['commentCount'] ?? 0}",
                        style: const TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
