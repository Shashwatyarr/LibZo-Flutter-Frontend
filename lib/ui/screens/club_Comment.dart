import 'package:flutter/material.dart';
import '../../services/community_service.dart';
import '../../services/auth_api.dart';

class ClubCommentsPage extends StatefulWidget {
  final String clubId;
  final String postId;

  const ClubCommentsPage({
    super.key,
    required this.clubId,
    required this.postId,
  });

  @override
  State<ClubCommentsPage> createState() => _ClubCommentsPageState();
}

class _ClubCommentsPageState extends State<ClubCommentsPage> {

  List<dynamic> comments = [];
  bool loading = true;

  final TextEditingController _comment = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadComments();
  }

  Future<void> loadComments() async {
    try {
      final data = await CommunityService.getComments(
        clubId: widget.clubId,
        postId: widget.postId,
      );

      setState(() {
        comments = data;
        loading = false;
      });

    } catch (e) {
      setState(() => loading = false);
    }
  }

  Future<void> addComment() async {

    if (_comment.text.trim().isEmpty) return;

    try {
      await CommunityService.addComment(
        clubId: widget.clubId,
        postId: widget.postId,
        text: _comment.text.trim(),
      );

      _comment.clear();

      loadComments();   // refresh

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),

      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("Comments"),
      ),

      body: Column(
        children: [

          // ───── COMMENT LIST ─────
          Expanded(
            child: loading
                ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF00FFC2),
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: comments.length,
              itemBuilder: (c, i) {
                return _buildCommentCard(comments[i]);
              },
            ),
          ),

          // ───── ADD COMMENT BOX ─────
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Color(0xFF121212),
            ),

            child: Row(
              children: [

                Expanded(
                  child: TextField(
                    controller: _comment,
                    style: const TextStyle(color: Colors.white),

                    decoration: const InputDecoration(
                      hintText: "Write a comment...",
                      hintStyle: TextStyle(color: Colors.white38),
                      border: InputBorder.none,
                    ),
                  ),
                ),

                IconButton(
                  onPressed: addComment,

                  icon: const Icon(
                    Icons.send,
                    color: Color(0xFF00FFC2),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildCommentCard(Map<String, dynamic> c) {

    final user = c["userId"] ?? {};
    final name = user["username"] ?? "User";

    return Container(
      margin: const EdgeInsets.only(bottom: 12),

      padding: const EdgeInsets.all(12),

      decoration: BoxDecoration(
        color: const Color(0xFF121212),
        borderRadius: BorderRadius.circular(14),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Row(
            children: [

              CircleAvatar(
                radius: 14,
                backgroundColor: const Color(0xFF00FFC2),

                child: Text(
                  name[0].toUpperCase(),
                  style: const TextStyle(color: Colors.black),
                ),
              ),

              const SizedBox(width: 8),

              Text(
                name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Text(
            c["text"] ?? "",
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}
