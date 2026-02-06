import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () {},
        ),
        title: const Text(
          "libzo.curator",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_horiz),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ProfileHeader(),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: ProfileInfo(),
            ),
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: ActionButtons(),
            ),
            const SizedBox(height: 24),
            const CustomTabBar(),
            const Divider(height: 1, color: Colors.white10),
            const PostList(),
          ],
        ),
      ),
    );
  }
}

// --- WIDGETS ---

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          // Avatar with Gradient Border
          Container(
            padding: const EdgeInsets.all(3),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Colors.cyanAccent, Colors.blueAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const CircleAvatar(
              radius: 40,
              backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=11'), // Placeholder Image
            ),
          ),
          const SizedBox(width: 24),
          // Stats Row
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                StatItem(label: "Shared", count: "428"),
                StatItem(label: "Followers", count: "12.4k"),
                StatItem(label: "Following", count: "892"),
              ],
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
    );
  }
}

class StatItem extends StatelessWidget {
  final String label;
  final String count;

  const StatItem({super.key, required this.label, required this.count});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          count,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}

class ProfileInfo extends StatelessWidget {
  const ProfileInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Alex Sterling",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 6),
        RichText(
          text: const TextSpan(
            style: TextStyle(color: Colors.grey, height: 1.4),
            children: [
              TextSpan(text: "Curating the best of modern sci-fi & cyberpunk literature 📚✨ "),
              TextSpan(text: "Exploring digital worlds one page at a time."),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: const [
            Icon(Icons.location_on, size: 14, color: Colors.blueAccent),
            SizedBox(width: 4),
            Text(
              "SAN FRANCISCO, CA",
              style: TextStyle(
                color: Colors.blueAccent,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class ActionButtons extends StatelessWidget {
  const ActionButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.white24),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: const Text("Edit Profile", style: TextStyle(color: Colors.white)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E3A8A).withOpacity(0.5), // गहरा नीला बटन
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              padding: const EdgeInsets.symmetric(vertical: 12),
              elevation: 0,
            ),
            icon: const Icon(Icons.bar_chart, size: 18),
            label: const Text("Profile Analytics"),
          ),
        ),
      ],
    );
  }
}

class CustomTabBar extends StatelessWidget {
  const CustomTabBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildTab("Thoughts", isSelected: true),
        _buildTab("Replies", isSelected: false),
        _buildTab("Media", isSelected: false),
      ],
    );
  }

  Widget _buildTab(String text, {required bool isSelected}) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Text(
            text,
            style: TextStyle(
              color: isSelected ? Colors.blueAccent : Colors.grey,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
        if (isSelected)
          Container(
            height: 3,
            width: 40,
            decoration: const BoxDecoration(
              color: Colors.blueAccent,
              borderRadius: BorderRadius.vertical(top: Radius.circular(2)),
            ),
          )
        else
          const SizedBox(height: 3),
      ],
    );
  }
}

class PostList extends StatelessWidget {
  const PostList({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        PostItem(
          time: "2h",
          text: "Just finished \"Neuromancer\" for the fifth time. The prose still hits like a high-speed data transfer. The way Gibson describes the sprawl is unmatched. 🌌💻",
          hasImage: true,
          imageUrl: "https://m.media-amazon.com/images/I/918s+91yC6L._AC_UF1000,1000_QL80_.jpg", // Example book cover
          comments: "24",
          retweets: "12",
          likes: "156",
        ),
        Divider(color: Colors.white10),
        PostItem(
          time: "5h",
          text: "Is it just me or is the hard sci-fi genre having a massive resurgence lately? Seeing so many incredible debut authors this month. Drop your recs below! 👇",
          hasImage: false,
          comments: "89",
          retweets: "42",
          likes: "312",
        ),
        Divider(color: Colors.white10),
        PostItem(
          time: "1d",
          text: "Mini-Review: \"Project Hail Mary\" by Andy Weir. 🚀 Pure joy from start to finish. If you liked The Martian, you'll love this. Science, heart, and a very cool friend. 5/5 stars.",
          hasImage: true,
          imageUrl: "https://m.media-amazon.com/images/I/91tW1H1pZgL._AC_UF1000,1000_QL80_.jpg", // Example book cover
          comments: "12",
          retweets: "5",
          likes: "85",
        ),
      ],
    );
  }
}

class PostItem extends StatelessWidget {
  final String time;
  final String text;
  final bool hasImage;
  final String? imageUrl;
  final String comments, retweets, likes;

  const PostItem({
    super.key,
    required this.time,
    required this.text,
    this.hasImage = false,
    this.imageUrl,
    required this.comments,
    required this.retweets,
    required this.likes,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(
            radius: 20,
            backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=11'),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      "Alex Sterling",
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "@libzo.curator · $time",
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                    const Spacer(),
                    const Icon(Icons.more_horiz, color: Colors.grey, size: 16),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  text,
                  style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.4),
                ),
                if (hasImage && imageUrl != null) ...[
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      imageUrl!,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Container(height: 180, color: Colors.grey[800], child: const Icon(Icons.broken_image)),
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _actionIcon(Icons.chat_bubble_outline, comments),
                    _actionIcon(Icons.repeat, retweets),
                    _actionIcon(Icons.favorite_border, likes),
                    _actionIcon(Icons.share_outlined, ""),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionIcon(IconData icon, String count) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey),
        if (count.isNotEmpty) ...[
          const SizedBox(width: 4),
          Text(count, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ],
    );
  }
}