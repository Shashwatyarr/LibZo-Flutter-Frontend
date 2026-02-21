import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class FeedSkeleton extends StatelessWidget {
  const FeedSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 4,
      itemBuilder: (context, index) {
        return const SkeletonPostCard();
      },
    );
  }
}

class SkeletonPostCard extends StatelessWidget {
  const SkeletonPostCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
      child: Shimmer.fromColors(
        baseColor: const Color(0xFF2A2A2A),
        highlightColor: const Color(0xFF3A3A3A),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 120,
                  height: 12,
                  color: Colors.white,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // TEXT LINES
            Container(height: 10, width: double.infinity, color: Colors.white),
            const SizedBox(height: 8),
            Container(height: 10, width: double.infinity, color: Colors.white),
            const SizedBox(height: 8),
            Container(height: 10, width: 200, color: Colors.white),

            const SizedBox(height: 16),

            // IMAGE PLACEHOLDER
            Container(
              height: 250,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),

            const SizedBox(height: 16),

            // ICON ROW
            Row(
              children: [
                Container(width: 24, height: 24, color: Colors.white),
                const SizedBox(width: 16),
                Container(width: 24, height: 24, color: Colors.white),
                const SizedBox(width: 16),
                Container(width: 24, height: 24, color: Colors.white),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
