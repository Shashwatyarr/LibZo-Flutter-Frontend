import 'package:bookproject/services/post_comments_services.dart';
import 'package:flutter/material.dart';

class CommentsScreen extends StatefulWidget {
  final String postId;
  const CommentsScreen({super.key, required this.postId});

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  final Color kBackgroundColor = const Color(0xFF05080D);
  final Color kCardColor = const Color(0xFF151922);
  final Color kAccentColor = const Color(0xFF00FFC2);

  final TextEditingController commentController = TextEditingController();

  List comments = [];
  bool loading = true;

  Future<void> loadComments() async {
    final data =
    await PostCommentsServices.getComments(widget.postId);

    setState(() {
      comments = data;
      loading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    loadComments();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            _buildHeaderFilter(),
            Expanded(
              child: RefreshIndicator(
                onRefresh: loadComments,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    return _buildCommentCard(comments[index]);
                  },
                ),
              ),
            ),

            _buildBottomInput(),
          ],
        )
      ),
    );
  }

  /// TOP BAR
  Widget _buildTopBar() {
    return Padding(
      padding:
      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_ios,
                  color: Colors.white, size: 20)),
        ],
      ),
    );
  }

  /// HEADER
  Widget _buildHeaderFilter() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Comments ${comments.length}",
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white),
          ),
          const Row(
            children: [
              Text("Recent",
                  style: TextStyle(
                      color: Color(0xFF00FFC2),
                      fontWeight: FontWeight.w600)),
              Icon(Icons.keyboard_arrow_down,
                  color: Color(0xFF00FFC2)),
            ],
          )
        ],
      ),
    );
  }

  /// COMMENT CARD
  Widget _buildCommentCard(Map comment) {
    final user = comment['userId'];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kCardColor.withOpacity(0.8),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(
            radius: 20,
            child: Icon(Icons.person),
          ),
          const SizedBox(width: 12),

          /// TEXT PART
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?['name'] ?? "User",
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 6),

                Text(
                  comment['text'] ?? "",
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// INPUT BAR
  Widget _buildBottomInput() {
    return Container(
      padding:
      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: kBackgroundColor,
        border: Border(
            top: BorderSide(color: Colors.white.withOpacity(0.05))),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 20,
            child: Icon(Icons.person),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Container(
              height: 45,
              padding:
              const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: kCardColor,
                borderRadius: BorderRadius.circular(30),
              ),
              child: TextField(
                controller: commentController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: "Write a comment...",
                  hintStyle:
                  TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          Container(
            height: 45,
            width: 45,
            decoration: const BoxDecoration(
              color: Color(0xFF00FFC2),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: () async {
                final text =
                commentController.text.trim();
                if (text.isEmpty) return;

                await PostCommentsServices
                    .createComments(
                    widget.postId, text);

                setState(() {
                  comments.insert(0, {
                    "text": text,
                    "userId": {"name": "You"},
                  });
                });

                commentController.clear();
              },
              icon: const Icon(Icons.send,
                  color: Colors.black),
            ),
          )
        ],
      ),
    );
  }
}
