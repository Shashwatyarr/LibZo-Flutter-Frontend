import 'package:flutter/material.dart';

import '../../services/library_services.dart';

import 'package:flutter/material.dart';
import '../../services/library_services.dart';

class BookDetailsScreen extends StatefulWidget {
  const BookDetailsScreen({super.key});

  @override
  State<BookDetailsScreen> createState() =>
      _BookDetailsScreenState();
}

class _BookDetailsScreenState
    extends State<BookDetailsScreen> {

  Map<String, dynamic>? book;
  bool loading = true;

  // ===== REVIEW SYSTEM =====
  List reviews = [];
  int page = 1;
  bool hasMore = true;
  bool reviewLoading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final id =
    ModalRoute.of(context)!.settings.arguments
    as String;

    loadBook(id);
  }

  Future loadBook(String id) async {
    try {
      final res =
      await LibraryService.getBook(id);

      setState(() {
        book = res["data"];
        loading = false;
      });

      loadReviews();

    } catch (e) {
      setState(() => loading = false);
    }
  }

  Future loadReviews() async {
    if (reviewLoading || !hasMore) return;

    setState(() => reviewLoading = true);

    final res =
    await LibraryService.getReviews(
        book!["_id"], page);

    setState(() {
      reviews.addAll(res["data"]);

      hasMore = page < res["totalPages"];
      page++;
      reviewLoading = false;
    });
  }

  // ===== WRITE REVIEW DIALOG =====
  void openReviewBox() {

    int rating = 5;
    TextEditingController c = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1F232F),

      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom),

          child: StatefulBuilder(
            builder: (ctx, set) {
              return Padding(
                padding: const EdgeInsets.all(20),

                child: Column(
                  mainAxisSize: MainAxisSize.min,

                  children: [

                    const Text(
                      "Write Review",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18),
                    ),

                    const SizedBox(height: 10),

                    // ===== STAR RATING =====
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,

                      children: List.generate(5, (i) {
                        return IconButton(
                          onPressed: () {
                            set(() => rating = i + 1);
                          },
                          icon: Icon(
                            Icons.star,
                            color: i < rating
                                ? const Color(0xFF00E5FF)
                                : Colors.grey,
                          ),
                        );
                      }),
                    ),

                    TextField(
                      controller: c,
                      maxLines: 3,
                      style: const TextStyle(color: Colors.white),

                      decoration: const InputDecoration(
                        hintText: "Share your thoughts...",
                        hintStyle: TextStyle(color: Colors.grey),
                      ),
                    ),

                    const SizedBox(height: 10),

                    ElevatedButton(
                      onPressed: () async {

                        try {

                          print("SUBMIT CLICKED");
                          print("BOOK ID: ${book!["_id"]}");

                          final res =
                          await LibraryService.addReview(
                            bookId: book!["_id"],
                            rating: rating,
                            comment: c.text,
                          );

                          print("API RESPONSE: $res");

                          Navigator.pop(context);

                          setState(() {
                            reviews.clear();
                            page = 1;
                            hasMore = true;
                          });

                          loadReviews();

                          ScaffoldMessenger.of(context)
                              .showSnackBar(
                            const SnackBar(
                                content:
                                Text("Review added")),
                          );

                        } catch (e) {

                          print("ERROR: $e");

                          ScaffoldMessenger.of(context)
                              .showSnackBar(
                            SnackBar(
                                content:
                                Text("Failed: $e")),
                          );
                        }
                      },

                      child: const Text("Submit"),
                    )
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {

    const Color bgColor =
    Color(0xFF050B18);
    const Color cardColor =
    Color(0xFF1F232F);
    const Color accentColor =
    Color(0xFF00E5FF);

    if (loading) {
      return const Scaffold(
        backgroundColor: bgColor,
        body: Center(
            child:
            CircularProgressIndicator()),
      );
    }

    if (book == null) {
      return const Scaffold(
        backgroundColor: bgColor,
        body: Center(
          child: Text(
            "Book not found",
            style:
            TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    final title = book!["title"] ?? "";

    final author =
    (book!["authors"] != null &&
        book!["authors"].length > 0)
        ? book!["authors"][0]["name"]
        : "Unknown";

    final cover = book!["coverUrl"] ??
        "https://via.placeholder.com/200x300";

    final rating =
    (book!["ratings"]?["average"] ?? 0)
        .toString();

    final pages =
    (book!["totalPages"] ?? "-")
        .toString();

    final lang =
        book!["language"] ?? "Eng";

    final categories =
        book!["categories"] as List? ?? [];

    return Scaffold(
      backgroundColor: bgColor,

      body: SafeArea(
        child: Stack(
          children: [

            SingleChildScrollView(
              padding:
              const EdgeInsets.fromLTRB(
                  20, 10, 20, 100),

              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,

                children: [

                  const CustomAppBar(),

                  const SizedBox(height: 20),

                  // ===== CARD =====
                  Container(
                    width: double.infinity,
                    padding:
                    const EdgeInsets.all(
                        20),

                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius:
                      BorderRadius.circular(
                          24),
                    ),

                    child: Column(
                      children: [

                        Container(
                          height: 220,
                          width: 150,

                          decoration:
                          BoxDecoration(
                            borderRadius:
                            BorderRadius
                                .circular(
                                12),

                            image:
                            DecorationImage(
                              image:
                              NetworkImage(
                                  cover),
                              fit:
                              BoxFit.cover,
                            ),
                          ),
                        ),

                        const SizedBox(
                            height: 20),

                        Text(
                          title,
                          textAlign:
                          TextAlign.center,

                          style:
                          const TextStyle(
                            fontSize: 24,
                            fontWeight:
                            FontWeight
                                .bold,
                            color:
                            Colors.white,
                          ),
                        ),

                        const SizedBox(
                            height: 8),

                        Text(
                          author,
                          style:
                          const TextStyle(
                            fontSize: 16,
                            color:
                            Colors.grey,
                          ),
                        ),

                        const SizedBox(
                            height: 20),

                        Divider(
                            color: Colors.grey
                                .withOpacity(
                                0.2)),

                        const SizedBox(
                            height: 10),

                        Row(
                          mainAxisAlignment:
                          MainAxisAlignment
                              .spaceEvenly,

                          children: [
                            StatItem(
                              label:
                              "Rating",
                              value:
                              rating,
                              icon: Icons.star,
                              iconColor:
                              accentColor,
                            ),

                            StatItem(
                              label:
                              "Pages",
                              value:
                              pages,
                            ),

                            StatItem(
                              label: "Lang",
                              value: lang,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  const Text(
                    "Synopsis",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    book!["description"] ??
                        "No description available",
                    style:
                    const TextStyle(
                      color: Colors.grey,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 20),

                  Wrap(
                    children: categories
                        .map((c) =>
                        GenreTag(text: c))
                        .toList(),
                  ),

                  const SizedBox(height: 30),

                  // ===== REVIEWS =====
                  const Text(
                    "Ratings & Reviews",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 15),

                  for (var r in reviews)
                    ReviewCard(
                      name: (r["userId"] != null
                          ? r["userId"]["name"]
                          : "User") ?? "User",

                      date: "just now",

                      rating: (r["rating"] ?? 0).toDouble(),

                      comment: r["comment"] ?? "",

                      avatarUrl: (r["userId"] != null
                          ? r["userId"]["avatar"]
                          : null) ??
                          "https://i.pravatar.cc/150",
                    ),

                  if (hasMore)
                    Center(
                      child: TextButton(
                        onPressed:
                        loadReviews,

                        child: const Text(
                          "LOAD MORE →",
                          style: TextStyle(
                              color: Colors
                                  .grey),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // ===== BOTTOM BAR =====
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,

              child: Container(
                padding:
                const EdgeInsets.all(20),

                child: ElevatedButton(
                  onPressed:
                  openReviewBox,

                  style: ElevatedButton
                      .styleFrom(
                    backgroundColor:
                    accentColor,
                  ),

                  child: const Text(
                    "WRITE A REVIEW",
                    style: TextStyle(
                        color:
                        Colors.black),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}



  Widget _buildAvatar(double left, String url) {
    return Positioned(
      left: left,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFF050B18), width: 2),
        ),
        child: CircleAvatar(
          radius: 14,
          backgroundImage: NetworkImage(url),
        ),
      ),
    );
  }


// --- SUB WIDGETS ---

class CustomAppBar extends StatelessWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed:()=> Navigator.pop(context), // Add navigation pop here
        ),
        const Text(
          "DETAILS",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.2),
        ),
        IconButton(
          icon: const Icon(Icons.favorite, color: Colors.white, size: 24),
          onPressed: () {},
        ),
      ],
    );
  }
}

class StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;
  final Color? iconColor;

  const StatItem({super.key, required this.label, required this.value, this.icon, this.iconColor});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            if (icon != null) ...[
              const SizedBox(width: 2),
              Icon(icon, color: iconColor, size: 14),
            ]
          ],
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }
}

class GenreTag extends StatelessWidget {
  final String text;
  const GenreTag({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1F232F),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Text(text, style: const TextStyle(color: Colors.grey, fontSize: 12)),
    );
  }
}

class ReviewCard extends StatelessWidget {
  final String name;
  final String date;
  final double rating;
  final String comment;
  final String avatarUrl;

  const ReviewCard({
    super.key,
    required this.name,
    required this.date,
    required this.rating,
    required this.comment,
    required this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1F232F),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundImage: NetworkImage(avatarUrl),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  Row(
                    children: List.generate(5, (index) => Icon(
                      Icons.star,
                      size: 12,
                      color: index < rating ? const Color(0xFF00E5FF) : Colors.grey,
                    )),
                  )
                ],
              ),
              const Spacer(),
              Text(date, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 10),
          Text(comment, style: const TextStyle(color: Colors.grey, fontSize: 13, height: 1.4)),
        ],
      ),
    );
  }
}