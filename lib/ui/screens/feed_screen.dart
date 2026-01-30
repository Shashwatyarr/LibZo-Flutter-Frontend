import 'package:bookproject/ui/widgets/app_background2.dart';
import 'package:flutter/material.dart';
import '../../services/post_service.dart';
import 'create_post_screen.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  List posts = [];
  bool loading = true;
  Map<String, bool> showHeart = {};
  final Color kBackgroundColor = const Color(0xFF000000);
  final Color kCardColor = const Color(0xFF1F222A);
  final Color kAccentColor = const Color(0xFF00E676);

  @override
  void initState() {
    super.initState();
    loadFeed();
  }

  //for reload
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
      floatingActionButton: SizedBox(
        height: 65,
        width: 65,
        child: FloatingActionButton(
          backgroundColor: kAccentColor,
          shape: const CircleBorder(),
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const CreatePostScreen(),
              ),
            );
            loadFeed();
          },
          child: const Icon(Icons.edit, color: Colors.black, size: 28),
        ),
      ),

      body: AppBackground2(
        child: SafeArea(
          child: loading
              ? Center(child: CircularProgressIndicator(color: kAccentColor))
              : Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
            child: Column(
              children: [
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Community\nFeed",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.1,
                      ),
                    ),
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: Colors.white24,
                      child: const Icon(Icons.person, color: Colors.white),
                    )
                  ],
                ),
                const SizedBox(height: 20),

                // --- Feed List ---
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: loadFeed,
                    color: kAccentColor,
                    backgroundColor: kCardColor,
                    child: ListView.builder(
                      itemCount: posts.length,
                      itemBuilder: (context, index) {
                        final post = posts[index];
                        return _buildPostCard(post);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  Widget _buildPostCard(Map post) {
    final String userName = post['userId']?['username'] ?? "Unknown User";
    final String postText = post['text'] ?? "";
    final String displayImage = "https://images.unsplash.com/photo-1544947950-fa07a98d237f?auto=format&fit=crop&q=80&w=800";
    DateTime time = DateTime.parse(post['createdAt']).toLocal();
    Duration diff = DateTime.now().difference(time);

    String timeAgo;
    if (diff.inMinutes < 60) {
      timeAgo = "${diff.inMinutes}m ago";
    } else if (diff.inHours < 24) {
      timeAgo = "${diff.inHours}h ago";
    } else {
      timeAgo = "${diff.inDays}d ago";
    }

    return GestureDetector(
      onDoubleTap: () async {
        final id = post['_id'];

        setState(() => showHeart[id] = true);

        await ApiService.likePost(id);

        setState(() {
          if (post['likes'].contains(post['userId'])) {
            post['likes'].remove(post['userId']);
          } else {
            post['likes'].add(post['userId']);
          }
        });

        await Future.delayed(const Duration(milliseconds: 600));

        setState(() => showHeart[id] = false);
      },
      child: Stack(
        children:[ Container(
          margin: const EdgeInsets.only(bottom: 24),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.2),
            borderRadius: BorderRadius.circular(40),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.deepPurple,
                      child: Text(
                        userName.isNotEmpty ? userName[0].toUpperCase() : "?",
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),

                        Text(
                        timeAgo,
                        style: TextStyle(color: Color(0xFF00E676), fontSize: 12),
                      ),
                      ],
                    ),
                    const Spacer(),
                    const Icon(Icons.more_horiz, color: Colors.grey),
                  ],
                ),

                const SizedBox(height: 16),
                if (post['image'] != null && post['image'] != "")
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          displayImage,
                          height: 250,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(height: 250, color: Colors.grey[800]),
                        ),
                      ),

                      Positioned(
                        bottom: 12,
                        left: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: const [
                              Icon(Icons.star, color: Color(0xFF00E676), size: 14),
                              SizedBox(width: 4),
                              Text(
                                "Featured",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),


                    ],
                  ),


                const SizedBox(height: 8),

                Text(
                  postText,
                  style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.4),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 16),
                Divider(color: Colors.white.withOpacity(0.1)),
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                  child: Row(
                    children:  [
                      GestureDetector(
                          onTap: () async {
                            final res = await ApiService.likePost(post['_id']);
                            setState(() {
                              if (post['likes'].contains(post['userId'])) {
                                post['likes'].remove(post['userId']);
                              } else {
                                post['likes'].add(post['userId']);
                              }
                            });
                          },
                          child: Icon(Icons.favorite, color: Color(0xFF00E676), size: 22)),
                      SizedBox(width: 6),
                      Text((post['likes']?.length??0).toString(), style: TextStyle(color: Colors.white)),
                      SizedBox(width: 20),
                      Icon(Icons.chat_bubble_outline, color: Colors.grey, size: 22),
                      SizedBox(width: 6),
                      GestureDetector(
                        onTap:()=> Navigator.pushReplacementNamed(context,"/post/comments"),
                          child: Text((post['commentCount']).toString(), style: TextStyle(color: Colors.white))), // Static counter
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
          // Big heart animation
          if (showHeart[post['_id']] == true)
            Positioned.fill(
              child: Center(
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.6, end: 1.4),
                  duration: const Duration(milliseconds: 400),
                  builder: (context, scale, child) {
                    return Opacity(
                      opacity: (1.4 - scale).clamp(0.0, 1.0),
                      child: Transform.scale(
                        scale: scale,
                        child: child,
                      ),
                    );
                  },
                  child: const Icon(
                    Icons.favorite,
                    color: Colors.pinkAccent,
                    size: 120,
                  ),
                ),
              ),
            ),    ]
      ),

    );
  }
}