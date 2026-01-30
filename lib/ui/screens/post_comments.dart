import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: CommentsScreen(),
  ));
}

class CommentsScreen extends StatefulWidget {
  const CommentsScreen({super.key});

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  // Color Palette based on the image
  final Color kBackgroundColor = const Color(0xFF05080D); // Very dark blue/black
  final Color kCardColor = const Color(0xFF151922); // Dark grey-blue for cards
  final Color kAccentColor = const Color(0xFF00FFC2); // Neon Teal/Cyan
  final Color kTextColor = Colors.white;
  final Color kSecondaryTextColor = Colors.grey;

  // Dummy Data
  final List<Map<String, dynamic>> comments = [
    {
      "name": "Marcus V.",
      "time": "2h ago",
      "content": "The world building in the first half is definitely slow but so worth the payoff. Have you reached the Arrakis arrival yet?",
      "likes": 12,
      "isLiked": true,
      "avatarColor": Colors.orangeAccent,
    },
    {
      "name": "Alex Design",
      "time": "5h ago",
      "content": "Incredible book. The typography in the collector's edition is also a masterpiece of its own!",
      "likes": 45,
      "isLiked": true,
      "avatarColor": Colors.brown,
    },
    {
      "name": "Sarah J.",
      "time": "12h ago",
      "content": "Reading this while listening to the Hans Zimmer soundtrack is a spiritual experience. Trust me on this one.",
      "likes": 89,
      "isLiked": true,
      "avatarColor": Colors.deepPurple,
    },
    {
      "name": "Kate L.",
      "time": "Yesterday",
      "content": "I completely agree! The depth of the characters is unmatched.",
      "likes": 5,
      "isLiked": false,
      "avatarColor": Colors.teal,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: Container(
        // Adding a subtle gradient to match the blue/green glow in the image
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF0A1025), // Subtle Blue tint top left
              kBackgroundColor,
              const Color(0xFF051510), // Subtle Green tint bottom right
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildTopBar(),
              _buildHeaderFilter(),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    return _buildCommentCard(comments[index]);
                  },
                ),
              ),
              _buildBottomInput(),
            ],
          ),
        ),
      ),
    );
  }

  // 1. Top Navigation Bar (Custom)
  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: kCardColor,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      height: 35,
                      width: 35,
                      color: Colors.orange, // Placeholder for Dune poster
                      child: const Icon(Icons.movie, size: 20, color: Colors.black),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Dune",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      Row(
                        children: const [
                          Icon(Icons.person_outline, size: 10, color: Colors.purpleAccent),
                          SizedBox(width: 4),
                          Text(
                            "BookWorm_99",
                            style: TextStyle(color: Colors.grey, fontSize: 10),
                          ),
                        ],
                      )
                    ],
                  ),
                  const Spacer(),
                  const Text(
                    "POST",
                    style: TextStyle(
                        color: Color(0xFF00FFC2), fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                  const SizedBox(width: 10),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 2. "Comments 156" and "Recent" Filter
  Widget _buildHeaderFilter() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          RichText(
            text: const TextSpan(
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              children: [
                TextSpan(text: "Comments "),
                TextSpan(
                    text: "156",
                    style: TextStyle(color: Colors.grey, fontWeight: FontWeight.normal)),
              ],
            ),
          ),
          Row(
            children: const [
              Text("Recent",
                  style: TextStyle(
                      color: Color(0xFF00FFC2), fontWeight: FontWeight.w600)),
              Icon(Icons.keyboard_arrow_down, color: Color(0xFF00FFC2)),
            ],
          )
        ],
      ),
    );
  }

  // 3. Individual Comment Card
  Widget _buildCommentCard(Map<String, dynamic> comment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kCardColor.withOpacity(0.8), // Slightly transparent for glass effect
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: comment['avatarColor'],
            radius: 20,
            child: const Icon(Icons.person, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name and Heart Icon Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          comment['name'],
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          comment['time'],
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                    const Icon(Icons.favorite, color: Colors.grey, size: 20),
                  ],
                ),
                const SizedBox(height: 10),

                // Comment Text
                Text(
                  comment['content'],
                  style: TextStyle(color: Colors.grey.shade300, height: 1.4),
                ),

                const SizedBox(height: 12),

                // Bottom Actions (Reply, Likes count)
                Row(
                  children: [
                    Text(
                      "REPLY",
                      style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 12,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 20),
                    Icon(Icons.favorite, size: 16, color: kAccentColor),
                    const SizedBox(width: 6),
                    Text(
                      comment['likes'].toString(),
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  // 4. Bottom Input Field
  Widget _buildBottomInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: kBackgroundColor,
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.orange.shade200,
            radius: 20,
            child: const Icon(Icons.person, color: Colors.brown),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              height: 45,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: kCardColor,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: const Center(
                child: TextField(
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "Write a comment...",
                    hintStyle: TextStyle(color: Colors.grey),
                    border: InputBorder.none,
                    isDense: true,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            height: 45,
            width: 45,
            decoration: BoxDecoration(
                color: kAccentColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: kAccentColor.withOpacity(0.3),
                    blurRadius: 10,
                    spreadRadius: 2,
                  )
                ]
            ),
            child: const Icon(Icons.send, color: Colors.black, size: 20),
          )
        ],
      ),
    );
  }
}