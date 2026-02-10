import 'package:flutter/material.dart';
import '../../services/community_service.dart';

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

  bool loading = true;

  Map<String, dynamic>? club;
  String relation = "not_joined";   // member / requested / not_joined
  String? myRole;

  @override
  void initState() {
    super.initState();
    loadClub();
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
      setState(() => loading = false);
    }
  }

  Future<void> handleJoin() async {
    await CommunityService.joinClub(widget.clubId);
    await loadClub();
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
                padding: const EdgeInsets.all(16.0),
                child: _buildPinnedPost(),
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
                  const SizedBox(width: 10),
                  _roundIcon(
                      icon: Icons.more_vert,
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

                  _buildActionButton(),
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

      child: Row(
        mainAxisAlignment:
        MainAxisAlignment.spaceEvenly,

        children: [
          _tabButton("Discussions", true),
          _tabButton("ReadingList", false),
          _tabButton("Events", false),
        ],
      ),
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
        children: const [

          Text(
            "Welcome to ${"Club"}",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: 8),

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
          );
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
}
