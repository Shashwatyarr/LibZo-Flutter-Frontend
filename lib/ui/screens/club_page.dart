import 'package:flutter/material.dart';
import '../../services/auth_api.dart';
import '../../services/community_service.dart';
import '../widgets/image_viewer.dart';
import 'club_Comment.dart';

class ClubPage extends StatefulWidget {
  final String clubId;

  const ClubPage({
    super.key,
    required this.clubId,
  });

  @override
  State<ClubPage> createState() => _ClubPageState();
}

class _ClubPageState extends State<ClubPage> {
  String? myUserId;
  bool loading = true;
  List<dynamic> post=[];
  bool postloading=true;
  Map<String, dynamic>? club;
  String relation = "not_joined";   // member / requested / not_joined
  String? myRole;

  @override
  void initState() {
    super.initState();
    loadClub();
    loadPosts();
    loadMyId();
  }

  Future<void> loadMyId() async {
    myUserId = await AuthApi.getUserId();
  }
  void updatePostInList(Map<String, dynamic> updatedPost) {
    setState(() {
      final index = post.indexWhere(
            (p) => p["_id"] == updatedPost["_id"],
      );

      if (index != -1) {
        post[index] = updatedPost;
      }
    });
  }

  Future<void> loadPosts() async {
    try {

      print("📡 CALLING GET POSTS for club: ${widget.clubId}");
      final data = await CommunityService.getPosts(widget.clubId);

      setState(() {
        post = data;
        postloading = false;
      });
      print(post);
    } catch (e) {
      setState(() => postloading = false);
    }
  }

  Future<void> loadClub() async {
    try {
      final data =
      await CommunityService.getSingleClub(widget.clubId);
      setState(() {
        club = data["club"];
        relation = data["relation"];
        myRole = data["myRole"];
        loading = false;
      });

    } catch (e) {
      setState(() =>
        loading = false);
    }
  }

  Future<void> handleJoin() async {
    await CommunityService.joinClub(widget.clubId);
    await loadClub();
  }
  bool isStaff() {
    return myRole == "admin" || myRole == "moderator";
  }
  Future<void> handleUpvote(String postId) async {
    try {
      final res = await CommunityService.toggleUpvote(
        clubId: widget.clubId,
        postId: postId,
      );

      updatePostInList(res["post"]);

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  Future<void> handleDownvote(String postId) async {
    try {
      final res = await CommunityService.toggleDownvote(
        clubId: widget.clubId,
        postId: postId,
      );

      updatePostInList(res["post"]);

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }
  Future<void> handleDeletePost(String postId) async {
    try {

      await CommunityService.deletePost(
        clubId: widget.clubId,
        postId: postId,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Post deleted")),
      );

      loadPosts();   // refresh list

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }


  @override
  Widget build(BuildContext context) {

    if (loading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0D0D0D),
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xFF00FFC2),
          ),
        ),
      );
    }

    if (club == null) {
      return const Scaffold(
        body: Center(
          child: Text(
            "Club not found",
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),

      body: RefreshIndicator(
        onRefresh: loadClub,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),

          child: Column(
            children: [

              _customHeader(),

              _tabSection(),

              Padding(
                padding: const EdgeInsets.all(10.0),
                child: _buildPinnedPost(),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: _buildPostSection(),
              ),
            ],
          ),

        ),
      ),
      floatingActionButton: _buildFab(),
    );
  }

  // ───────────────── HEADER ─────────────────
  Widget _customHeader() {

    String coverUrl =
    club!["coverImage"] != null
        ? CommunityService.getCoverUrl(
        club!["coverImage"]["file_id"])
        : "";

    return Stack(
      children: [

        // BACKGROUND IMAGE
        coverUrl.isNotEmpty
            ? Image.network(
          coverUrl,
          height: 330,
          width: double.infinity,
          fit: BoxFit.cover,

          errorBuilder: (_, __, ___) =>
              Container(
                  height: 330,
                  color: Colors.black),
        )
            : Container(height: 330, color: Colors.black),

        // GRADIENT
        Container(
          height: 330,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.2),
                const Color(0xFF0D0D0D),
              ],
            ),
          ),
        ),

        // TOP ICONS
        Positioned(
          top: 40,
          left: 12,
          right: 12,

          child: Row(
            mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
            children: [

              _roundIcon(
                icon: Icons.arrow_back,
                onTap: () => Navigator.pop(context),
              ),

              Row(
                children: [
                  _roundIcon(
                      icon: Icons.share,
                      onTap: () {}),


                ],
              ),
            ],
          ),
        ),

        // TEXT AREA
        Positioned(
          bottom: 16,
          left: 16,
          right: 16,

          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [

              // TAG = GENRE
              Container(
                padding:
                const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.blueAccent,
                  borderRadius:
                  BorderRadius.circular(6),
                ),

                child: Text(
                  (club!["genre"] as List)
                      .join(", ")
                      .toUpperCase(),

                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                  ),
                ),
              ),

              const SizedBox(height: 10),

              Row(
                mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
                children: [

                  Expanded(
                    child: Text(
                      club!["name"],
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight:
                        FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Row(
                  children: [
                    _buildActionButton(),

                    if (isStaff())
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert, color: Colors.white,shadows: [Shadow(color: Colors.black,blurRadius: 10)],),
                        color: const Color(0xFF1A1A1A),
                        shadowColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),

                        ),

                        onSelected: (value) {
                          if (value == "requests") {

                            Navigator.pushNamed(
                              context,
                              "/club-requests",
                              arguments: {
                                "clubId": widget.clubId,
                                "clubName": club!["name"],
                              },
                            );

                          }
                        },

                        itemBuilder: (context) => [

                          const PopupMenuItem(
                            value: "requests",
                            child: Row(
                              children: [
                                Icon(Icons.group_add,
                                    color: Color(0xFF00FFC2), size: 18),

                                SizedBox(width: 10),

                                Text(
                                  "Join Requests",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          ),

                          // const PopupMenuItem(
                          //   value: "settings",
                          //   child: Row(
                          //     children: [
                          //       Icon(Icons.settings,
                          //           color: Colors.white70, size: 18),
                          //
                          //       SizedBox(width: 10),
                          //
                          //       Text(
                          //         "Club Settings",
                          //         style: TextStyle(color: Colors.white),
                          //       ),
                          //     ],
                          //   ),
                          // ),
                        ],
                      ),
                  ]
                  )
                ],
              ),

              const SizedBox(height: 6),

              Text(
                "${club!["stats"]["members"]} Members  •  ${club!["type"].toUpperCase()}",
                style:
                const TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ───────────── JOIN / OPEN BUTTON ─────────────
  Widget _buildActionButton() {

    String text = "";
    VoidCallback? action;

    if (relation == "member") {
      text = "Open";
      action = () {};
    }
    else if (relation == "requested") {
      text = "Requested";
      action = null;
    }
    else {
      text = club!["type"] == "public"
          ? "+ Join"
          : "Request";

      action = handleJoin;
    }

    return GestureDetector(
      onTap: action,

      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF00FFC2),
          borderRadius: BorderRadius.circular(30),
        ),

        child: Padding(
          padding:
          const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 10,
          ),

          child: Text(
            text,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  // ───────────────── TABS ─────────────────
  Widget _tabSection() {
    return Container(
      color: const Color(0xFF0D0D0D),
      padding:
      const EdgeInsets.symmetric(vertical: 10),

      // child: Row(
      //   mainAxisAlignment:
      //   MainAxisAlignment.spaceEvenly,
      //
      //   children: [
      //     _tabButton("Discussions", true),
      //     _tabButton("ReadingList", false),
      //     _tabButton("Events", false),
      //   ],
      // ),
    );
  }

  Widget _tabButton(String text, bool active) {
    return Container(
      padding:
      const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),

      decoration: BoxDecoration(
        color: active
            ? Colors.white12
            : Colors.transparent,
        borderRadius:
        BorderRadius.circular(20),
      ),

      child: Text(
        text,
        style: TextStyle(
          color:
          active ? Colors.white : Colors.grey,
        ),
      ),
    );
  }

  // ───────────────── PINNED POST (STATIC FOR NOW) ─────────────────
  Widget _buildPinnedPost() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(24),
      ),

      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [

          Text(
            "Welcome to ${"Club"} 🫡",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: 1),

          Text(
            "Start discussions and explore together!",
            style: TextStyle(color: Colors.grey),
          ),

        ],

      ),

    );
  }

  // ───────────────── ICON ─────────────────
  Widget _roundIcon({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,

      child: Container(
        padding: const EdgeInsets.all(8),

        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.4),
          shape: BoxShape.circle,
        ),

        child: Icon(icon, color: Colors.white),
      ),
    );
  }

  Widget? _buildFab() {
    bool isMember = relation == "member";

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: isMember ? 1 : 0.4,

      child: FloatingActionButton.extended(
        onPressed: isMember
            ? () {
          // 👉 Yahan tum apni Create Post Screen open karna
          Navigator.pushNamed(
            context,
            "/club-createpost",
            arguments:{ "clubId": widget.clubId,
              "clubName": club!["name"],}
          ).then((value){
            if(value==true){
              loadPosts();
            }
          });
        }
            : () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Join the club to post"),
            ),
          );
        },

        backgroundColor: const Color(0xFF00FFC2),
        icon: const Icon(
          Icons.add_comment_rounded,
          color: Colors.black,
        ),

        label: const Text(
          "New Post",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
  Widget _buildPostSection() {

    if (postloading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF00FFC2),
        ),
      );
    }

    if (post.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text(
            "No posts yet. Be the first to post!",
            style: TextStyle(color: Colors.white38),
          ),
        ),
      );
    }

    return Column(
      children: (post).map((p) => _buildPostCard(p)).toList(),
    );
  }
  Widget _buildPostCard(Map<String, dynamic> post) {

    // ───────── SAFE USER PARSING ─────────
    final dynamic userRaw = post["userID"];

    String name = "Unknown";

    if (userRaw is Map<String, dynamic>) {
      name = userRaw["username"] ?? "Unknown";
    } else if (userRaw is String) {
      name = "User";
    }

    // ───────── SAFE STATS PARSING ─────────
    final stats = post["stats"] as Map<String, dynamic>? ?? {};

    final int up = (stats["upvotes"] is int) ? stats["upvotes"] : 0;
    final int down = (stats["downvotes"] is int) ? stats["downvotes"] : 0;

    final int score = up - down;

    final List upList =
    (post["upvotedBy"] is List) ? post["upvotedBy"] : [];

    final List downList =
    (post["downvotedBy"] is List) ? post["downvotedBy"] : [];

    final bool isUp = upList.contains(myUserId);
    final bool isDown = downList.contains(myUserId);
    final String postId = post["_id"] is String
        ? post["_id"]
        : post["_id"].toString();

    return Container(
      margin: const EdgeInsets.only(bottom: 14),

      decoration: BoxDecoration(
        color: const Color(0xFF121212),
        borderRadius: BorderRadius.circular(18),

        border: Border.all(
          color: Colors.white.withOpacity(0.06),
        ),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 6),
          )
        ],
      ),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          // ───────── LEFT VOTE BAR ─────────
          Container(
            width: 42,

            decoration: const BoxDecoration(
              color: Color(0xFF0E0E0E),

              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(18),
                bottomLeft: Radius.circular(18),
              ),
            ),

            child: Column(
              children: [

                // ───── UPVOTE ─────
                GestureDetector(
                  onTap: () => handleUpvote(post["_id"]),

                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),

                    padding: const EdgeInsets.symmetric(vertical: 6),

                    child: Icon(
                      Icons.arrow_upward_rounded,

                      color: isUp
                          ? const Color(0xFF00FFC2)
                          : Colors.white38,

                      size: 22,
                    ),
                  ),
                ),

                // ───── SCORE ─────
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),

                  child: Text(
                    score.toString(),

                    style: TextStyle(
                      fontWeight: FontWeight.bold,

                      color: isUp
                          ? const Color(0xFF00FFC2)
                          : isDown
                          ? Colors.redAccent
                          : Colors.white70,
                    ),
                  ),
                ),

                // ───── DOWNVOTE ─────
                GestureDetector(
                  onTap: () => handleDownvote(post["_id"]),

                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),

                    padding: const EdgeInsets.symmetric(vertical: 6),

                    child: Icon(
                      Icons.arrow_downward_rounded,

                      color: isDown
                          ? Colors.redAccent
                          : Colors.white38,

                      size: 22,
                    ),
                  ),
                ),

                const SizedBox(height: 12),
              ],
            ),
          ),

          // ───────── MAIN CONTENT ─────────
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(14),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [

                  // ───── USER ROW ─────
                  Row(
                    children: [

                      CircleAvatar(
                        radius: 14,
                        backgroundColor: const Color(0xFF00FFC2),

                        child: Text(
                          name.isNotEmpty
                              ? name[0].toUpperCase()
                              : "U",

                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      const SizedBox(width: 8),

                      Text(
                        "u/$name",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),

                      const SizedBox(width: 6),

                      // ───── TYPE TAG ─────
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),

                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(6),
                        ),

                        child: Text(
                          (post["type"] ?? "TEXT").toString().toUpperCase(),

                          style: const TextStyle(
                            color: Colors.cyanAccent,
                            fontSize: 9,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ),

                      const Spacer(),

                      Text(
                        _timeAgo(post["createdAt"]),

                        style: const TextStyle(
                          color: Colors.white38,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // ───── CONTENT ─────
                  Text(
                    (post["content"] ?? "").toString(),

                    style: const TextStyle(
                      color: Colors.white,
                      height: 1.35,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // ───── IMAGE SECTION ─────
                  if (post["image"] != null &&
                      post["image"].toString().isNotEmpty)

                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ImageViewer(
                              imageUrl: CommunityService.getCoverUrl(
                                  post["image"]),
                              tag: post["_id"],
                            ),
                          ),
                        );
                      },

                      child: Hero(
                        tag: post["_id"],

                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),

                          child: Image.network(
                            CommunityService.getCoverUrl(post["image"]),

                            height: 180,
                            width: double.infinity,
                            fit: BoxFit.cover,

                            errorBuilder: (_, __, ___) =>
                                Container(
                                    height: 180,
                                    color: Colors.black26),
                          ),
                        ),
                      ),
                    ),

                  const SizedBox(height: 12),

                  // ───── ACTION BAR ─────
                  Row(
                    children: [

                      _actionChip(
                        Icons.chat_bubble_outline,
                        "${stats["comments"] ?? 0} Comments",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ClubCommentsPage(
                                clubId: widget.clubId,
                                postId: postId,   // ✅ safe string
                              ),
                            ),
                          ).then((_) => loadPosts());
                        },
                      ),

                      const SizedBox(width: 10),

                      _actionChip(
                        Icons.share_outlined,
                        "Share",
                      ),

                      const Spacer(),

                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_horiz, color: Colors.white38),

                        color: const Color(0xFF1A1A1A),

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),

                        onSelected: (value) async {

                          // ───── VIEW PROFILE ─────
                          if (value == "profile") {
                            Navigator.pushNamed(
                              context,
                              "/profile",
                              arguments: userRaw["_id"],
                            );
                          }

                          // ───── DELETE POST ─────
                          else if (value == "delete") {

                            final confirm = await showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                backgroundColor: const Color(0xFF121212),
                                title: const Text(
                                  "Delete Post?",
                                  style: TextStyle(color: Colors.white),
                                ),
                                content: const Text(
                                  "This action cannot be undone.",
                                  style: TextStyle(color: Colors.white70),
                                ),
                                actions: [

                                  TextButton(
                                    onPressed: () => Navigator.pop(context, false),
                                    child: const Text("Cancel"),
                                  ),

                                  TextButton(
                                    onPressed: () => Navigator.pop(context, true),
                                    child: const Text(
                                      "Delete",
                                      style: TextStyle(color: Colors.redAccent),
                                    ),
                                  ),
                                ],
                              ),
                            );

                            if (confirm == true) {
                              await handleDeletePost(post["_id"]);
                            }
                          }
                        },

                        itemBuilder: (context) {

                          bool isOwner =
                              userRaw["_id"] == myUserId;

                          bool canDelete = isOwner || isStaff();

                          return [

                            // ───── VIEW PROFILE ─────
                            const PopupMenuItem(
                              value: "profile",
                              child: Row(
                                children: [
                                  Icon(Icons.person, color: Colors.white70, size: 18),
                                  SizedBox(width: 10),
                                  Text("View Profile",
                                      style: TextStyle(color: Colors.white)),
                                ],
                              ),
                            ),

                            // ───── DELETE (CONDITIONAL) ─────
                            if (canDelete)
                              const PopupMenuItem(
                                value: "delete",
                                child: Row(
                                  children: [
                                    Icon(Icons.delete,
                                        color: Colors.redAccent, size: 18),
                                    SizedBox(width: 10),
                                    Text("Delete Post",
                                        style: TextStyle(color: Colors.redAccent)),
                                  ],
                                ),
                              ),
                          ];
                        },
                      )

                    ],
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }



// ───── ACTION CHIP ─────
  Widget _actionChip(IconData icon, String label, {VoidCallback? onTap}) {

    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 10, vertical: 6),

      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
      ),

      child: GestureDetector(
        onTap: onTap,
        child: Row(
          children: [

            Icon(icon, color: Colors.white60, size: 16),

            const SizedBox(width: 6),

            Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _timeAgo(String? date) {

    if (date == null) return "";

    final d = DateTime.parse(date);
    final diff = DateTime.now().difference(d);

    if (diff.inMinutes < 60) return "${diff.inMinutes}m ago";
    if (diff.inHours < 24) return "${diff.inHours}h ago";

    return "${diff.inDays}d ago";
  }

}
