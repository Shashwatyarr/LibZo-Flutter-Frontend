import 'package:flutter/material.dart';
import '../../services/community_service.dart';

class JoinRequestsPage extends StatefulWidget {

  final String clubId;
  final String clubName;

  const JoinRequestsPage({
    super.key,
    required this.clubId,
    required this.clubName,
  });

  @override
  State<JoinRequestsPage> createState() => _JoinRequestsPageState();
}

class _JoinRequestsPageState extends State<JoinRequestsPage> {

  bool loading = true;
  List<dynamic> requests = [];

  @override
  void initState() {
    super.initState();
    loadRequests();
  }

  // ───── LOAD REQUESTS ─────
  Future<void> loadRequests() async {
    try {
      final data =
      await CommunityService.getRequests(widget.clubId);

      setState(() {
        requests = data;
        loading = false;
      });

    } catch (e) {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );

      setState(() => loading = false);
    }
  }

  // ───── HANDLE ACTION ─────
  Future<void> handleAction(
      String requestId, String action) async {

    try {

      await CommunityService.handleRequest(
        clubId: widget.clubId,
        requestId: requestId,
        action: action,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Request $action")),
      );

      await loadRequests();

    } catch (e) {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      body: Container(

        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF081221),
              Color(0xFF030508)
            ],
          ),
        ),

        child: SafeArea(
          child: Column(
            children: [

              _buildAppBar(context),

              if (loading)
                const Expanded(
                  child: Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF00FFE0),
                    ),
                  ),
                )

              else if (requests.isEmpty)
                const Expanded(
                  child: Center(
                    child: Text(
                      "No pending requests",
                      style: TextStyle(
                        color: Colors.white54,
                      ),
                    ),
                  ),
                )

              else
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: loadRequests,

                    child: ListView.builder(
                      padding: const EdgeInsets.only(top: 10),

                      itemCount: requests.length,

                      itemBuilder: (context, index) {

                        return _buildRequestCard(
                          requests[index],
                        );
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

  // ───────────────── APP BAR ─────────────────

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),

      child: Row(
        children: [

          CircleAvatar(
            backgroundColor:
            Colors.white.withOpacity(0.05),

            child: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: 18,
              ),

              onPressed: () => Navigator.pop(context),
            ),
          ),

          Expanded(
            child: Center(
              child: Column(
                children: [

                  Text(
                    widget.clubName.toUpperCase(),
                    style: const TextStyle(
                      color: Color(0xFF00FFE0),
                      fontSize: 10,
                      letterSpacing: 1.2,
                    ),
                  ),

                  const SizedBox(height: 4),

                  const Text(
                    'Join Requests',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 40),
        ],
      ),
    );
  }

  // ───────────────── CARD ─────────────────

  Widget _buildRequestCard(Map<String, dynamic> data) {

    final user = data["userId"] ?? {};

    String name = user["username"] ?? "Unknown";

    return Container(

      margin: const EdgeInsets.symmetric(
          horizontal: 20, vertical: 10),

      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
        ),
      ),

      child: Row(
        children: [

          // ───── AVATAR ─────
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.cyanAccent,
            child: Text(
              name.isNotEmpty
                  ? name[0].toUpperCase()
                  : "?",
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(width: 16),

          // ───── INFO ─────
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [

                Text(
                  widget.clubName.toUpperCase(),
                  style: const TextStyle(
                    color: Color(0xFF00FFE0),
                    fontSize: 11,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 4),

                const Text(
                  'View Profile',
                  style: TextStyle(
                    color: Colors.blueAccent,
                    fontSize: 13,
                    decoration:
                    TextDecoration.underline,
                  ),
                ),
              ],
            ),
          ),

          // ───── ACTIONS ─────
          Column(
            children: [

              GestureDetector(
                onTap: () => handleAction(
                  data["_id"],
                  "approve",
                ),

                child: _actionButton(
                  icon: Icons.check,
                  color: const Color(0xFF00FFE0),
                  isPrimary: true,
                ),
              ),

              const SizedBox(height: 12),

              GestureDetector(
                onTap: () => handleAction(
                  data["_id"],
                  "rejected",
                ),

                child: _actionButton(
                  icon: Icons.close,
                  color: Colors.white.withOpacity(0.1),
                  isPrimary: false,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ───────────────── BUTTON ─────────────────

  Widget _actionButton({
    required IconData icon,
    required Color color,
    required bool isPrimary,
  }) {
    return Container(
      width: 45,
      height: 45,

      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(15),

        boxShadow: isPrimary
            ? [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 12,
            spreadRadius: 1,
          )
        ]
            : [],
      ),

      child: Icon(
        icon,
        color:
        isPrimary ? Colors.black : Colors.white60,
        size: 20,
      ),
    );
  }
}
