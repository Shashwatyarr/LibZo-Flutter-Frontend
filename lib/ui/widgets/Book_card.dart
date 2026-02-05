import 'package:flutter/material.dart';

class BookCard extends StatelessWidget {
  final String title;
  final String author;
  final double rating;
  final String imageUrl;
  final bool isNew;
  final String bookID;

  const BookCard({
    super.key,
    required this.title,
    required this.author,
    required this.rating,
    required this.imageUrl,
    this.isNew = false,
    required this.bookID,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Book Cover Image Area
        Expanded(
          child: Stack(
            children: [
              // Container for Shadow and Image
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    "/book",
                    arguments: bookID,   // ← pass real id
                  );
                },

                child: Container(
                  width: double.infinity,

                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),

                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),

                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,

                      // --- LOADING ---
                      loadingBuilder:
                          (context, child, loadingProgress) {

                        if (loadingProgress == null) return child;

                        return Center(
                          child: CircularProgressIndicator(
                            color: const Color(0xFF00E5FF),

                            value:
                            loadingProgress.expectedTotalBytes !=
                                null
                                ? loadingProgress
                                .cumulativeBytesLoaded /
                                loadingProgress
                                    .expectedTotalBytes!
                                : null,
                          ),
                        );
                      },

                      // --- ERROR ---
                      errorBuilder:
                          (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[800],
                          child: const Center(
                            child: Icon(
                              Icons.broken_image,
                              color: Colors.white54,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),

              // "New" Badge
              if (isNew)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00E5FF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      "NEW",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),

        const SizedBox(height: 10),

        // Title
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),

        // Author
        Text(
          author,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 12,
          ),
        ),

        const SizedBox(height: 5),

        // Rating
        Row(
          children: [
            const Icon(Icons.star, color: Color(0xFF00E5FF), size: 14),
            const SizedBox(width: 4),
            Text(
              rating.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ],
    );
  }
}