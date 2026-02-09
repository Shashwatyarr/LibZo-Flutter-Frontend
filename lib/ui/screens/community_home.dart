import 'package:bookproject/ui/widgets/app_background2.dart';
import 'package:flutter/material.dart';

import '../../services/community_service.dart';

class BookClubsScreen extends StatefulWidget {
  const BookClubsScreen({super.key});

  @override
  State<BookClubsScreen> createState() => _BookClubsScreenState();
}

class _BookClubsScreenState extends State<BookClubsScreen> {

  bool loading = true;

  List<dynamic> allClubs = [];
  List<dynamic> myMemberships = [];
  List<dynamic> requests = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  // ================= LOAD DATA =================

  Future<void> loadData() async {
    try {
      final data = await CommunityService.getClubs();

      print("CLUB API RESPONSE: $data");

      setState(() {
        // ─── FIXED KEYS ───
        allClubs = data["publicClubs"] ?? [];
        myMemberships = data["myMemberships"] ?? [];
        requests = data["requests"] ?? [];
        loading = false;
      });

    } catch (e) {
      print("LOAD ERROR: $e");
      setState(() => loading = false);
    }
  }

  bool isMember(String clubId) {
    return myMemberships.any(
            (m) => m["clubId"]["_id"] == clubId
    );
  }

  bool isRequested(String clubId) {
    return requests.any(
            (r) => r["clubId"]["_id"] == clubId
    );
  }

  // ================= BUILD =================

  @override
  Widget build(BuildContext context) {

    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: AppBackground2(
        child: SafeArea(
          child: RefreshIndicator(

            color: const Color(0xFF00FFA3),
            backgroundColor: const Color(0xFF121212),

            onRefresh: loadData,

            child: SingleChildScrollView(

              // ─── IMPORTANT FOR REFRESH ───
              physics: const AlwaysScrollableScrollPhysics(),

              padding: const EdgeInsets.symmetric(horizontal: 16.0),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  const SizedBox(height: 20),

                  _buildHeader(),

                  const SizedBox(height: 20),

                  _buildSearchBar(),

                  const SizedBox(height: 20),

                  _buildCategoryChips(),

                  const SizedBox(height: 30),

                  _buildSectionHeader("My Clubs", showViewAll: true),

                  const SizedBox(height: 16),

                  if (myMemberships.isEmpty)
                    const Text(
                      "No clubs joined yet",
                      style: TextStyle(color: Colors.white54),
                    )
                  else
                    ...myMemberships.map((m) {

                      final club = m["clubId"];

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              "/clubDetail",
                              arguments: club["_id"],
                            );
                          },

                          child: _buildClubTile(
                            club,
                            club["name"],
                            club["currentBook"]?["title"] ?? "No Book",
                            "Members: ${club["stats"]["members"]}",
                            Colors.teal,
                          ),
                        ),
                      );
                    }).toList(),

                  const SizedBox(height: 30),

                  _buildSectionHeader("All Clubs", showViewAll: false),

                  const SizedBox(height: 16),

                  ...allClubs.map((club) {

                    bool publicClub = club["type"] == "public";

                    bool member = isMember(club["_id"]);
                    bool requested = isRequested(club["_id"]);

                    String buttonText;
                    VoidCallback? action;

                    if (member) {
                      buttonText = "Open Club";
                      action = () {
                        Navigator.pushNamed(
                          context,
                          "/clubDetail",
                          arguments: club["_id"],
                        );
                      };

                    } else if (requested) {
                      buttonText = "Requested";
                      action = null;

                    } else if (publicClub) {
                      buttonText = "Join Club";
                      action = () async {
                        await CommunityService.joinClub(club["_id"]);
                        await loadData();   // ─── RELOAD FIX ───
                      };

                    } else {
                      buttonText = "Request Access";
                      action = () async {
                        await CommunityService.joinClub(club["_id"]);
                        await loadData();   // ─── RELOAD FIX ───
                      };
                    }

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _buildExploreCard(
                        club: club,
                        buttonText: buttonText,
                        onTap: action,
                      ),
                    );

                  }).toList(),

                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ================= HEADER =================

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [

        const Text(
          "Book Clubs",
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),

        ElevatedButton.icon(
          onPressed: () async {

            // ─── CREATE KE BAAD RELOAD ───
            final created =
            await Navigator.pushNamed(context, "/create-club");

            if (created == true) {
              await loadData();
            }

          },
          icon: const Icon(Icons.add, size: 18),
          label: const Text("Create Club"),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00FFA3),
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            shadowColor: Color(0xFF00FFA3),
            elevation: 5,
          ),
        ),
      ],
    );
  }

  // ================= SEARCH BAR =================

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Color(0xFF00FFA3).withOpacity(0.2),
            blurRadius: 12,
            spreadRadius: 1,
          ),
        ],
      ),
      child: TextField(
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: "Search clubs...",
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
          prefixIcon: const Icon(Icons.search, color: Colors.white38),
          filled: true,
          fillColor: const Color(0xFF121212),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  // ================= CATEGORY CHIPS =================

  Widget _buildCategoryChips() {

    final categories = ["All", "Sci-Fi", "Fantasy", "Thriller", "Romance"];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categories.map((cat) {

          bool isSelected = cat == "All";

          return Container(
            margin: const EdgeInsets.only(right: 10),

            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),

            decoration: BoxDecoration(
              color: isSelected
                  ? Colors.white
                  : const Color(0xFF121212),

              borderRadius: BorderRadius.circular(20),

              border: Border.all(color: Colors.white10),
            ),

            child: Text(
              cat,
              style: TextStyle(
                color: isSelected ? Colors.black : Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          );

        }).toList(),
      ),
    );
  }

  Widget _buildExploreCard({
    required Map<String, dynamic> club,
    required String buttonText,
    required VoidCallback? onTap,
  }) {

    return Container(
      width: double.infinity,
      height: 200,   // 👈 IMPORTANT: height dena zaroori hai
      margin: const EdgeInsets.only(bottom: 16),

      child: Stack(
        fit: StackFit.expand,
        children: [

          // ───── 1. BACKGROUND IMAGE ─────
          if (club["coverImage"] != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.network(
                CommunityService.getCoverUrl(
                  club["coverImage"]["file_id"],
                ),
                fit: BoxFit.cover,
              ),
            )
          else
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF121212),
                borderRadius: BorderRadius.circular(20),
              ),
            ),

          // ───── 2. LEFT → RIGHT BLACK GRADIENT ─────
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),

              gradient: LinearGradient(
                begin: Alignment.bottomLeft,
                end: Alignment.topRight,

                colors: [
                  Colors.black.withOpacity(0.9),
                  Colors.black.withOpacity(0.2),
                ],
              ),
            ),
          ),

          // ───── 3. CONTENT LAYER ─────
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // TYPE TAG
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    club["type"].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                    ),
                  ),
                ),

                const Spacer(),

                // TITLE
                Text(
                  club["name"],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),

                // DESC
                Text(
                  club["description"],
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),

                const SizedBox(height: 10),

                // BUTTON
                ElevatedButton(
                  onPressed: onTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white12,
                  ),
                  child: Text(
                    buttonText,
                    style: const TextStyle(color: Colors.white),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildSectionHeader(String title, {required bool showViewAll}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [

        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),

        if (showViewAll)
          const Text(
            "View All",
            style: TextStyle(
              color: Color(0xFF00FFA3),
              fontSize: 12,
            ),
          ),
      ],
    );
  }
}
Widget _buildClubTile(
    Map<String, dynamic> club,
    String title,
    String currentBook,
    String status,
    Color accent,
    ) {
  return Container(
    padding: const EdgeInsets.all(12),

    decoration: BoxDecoration(
      color: const Color(0xFF121212).withOpacity(0.55),

      borderRadius: BorderRadius.circular(18),

      border: Border.all(
        width: 0.3,
        color: Colors.white.withOpacity(0.15),
      ),

      boxShadow: [
        BoxShadow(
          color: accent.withOpacity(0.12),
          blurRadius: 10,
          spreadRadius: 1,
        ),
      ],
    ),

    child: Row(
      children: [

        // ─────────── COVER + OVERLAY ───────────
        Stack(
          children: [

            Container(
              height: 56,
              width: 56,

              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),

                image: club["coverImage"] != null
                    ? DecorationImage(
                  image: NetworkImage(
                    CommunityService.getCoverUrl(
                      club["coverImage"]["file_id"],
                    ),
                  ),
                  fit: BoxFit.cover,
                )
                    : null,

                color: accent.withOpacity(0.2),
              ),

              child: club["coverImage"] == null
                  ? Icon(Icons.menu_book, color: accent)
                  : null,
            ),

            // black gradient overlay
            Container(
              height: 56,
              width: 56,

              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),

                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.6),
                    Colors.transparent,
                  ],
                ),
              ),
            ),

            // members badge
            Positioned(
              bottom: 4,
              right: 4,

              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 2,
                ),

                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(6),
                ),

                child: Text(
                  club["stats"]["members"].toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(width: 14),

        // ─────────── TEXT AREA ───────────
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // TITLE
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,

                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.3,

                  shadows: [
                    Shadow(
                      color: accent.withOpacity(0.5),
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 4),

              // CURRENT BOOK CHIP
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 3,
                ),

                decoration: BoxDecoration(
                  color: accent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),

                child: Text(
                  currentBook,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,

                  style: TextStyle(
                    color: accent,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(height: 4),

              // STATUS
              Text(
                status,
                style: const TextStyle(
                  color: Colors.white38,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),

        // ─────────── ARROW ───────────
        Container(
          padding: const EdgeInsets.all(6),

          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(8),
          ),

          child: const Icon(
            Icons.chevron_right,
            color: Colors.white54,
            size: 20,
          ),
        ),
      ],
    ),
  );
}
