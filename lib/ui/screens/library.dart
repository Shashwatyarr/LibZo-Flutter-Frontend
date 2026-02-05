import 'package:bookproject/services/library_services.dart';
import 'package:bookproject/ui/widgets/app_background2.dart';
import 'package:flutter/material.dart';

import '../../services/library_services.dart';
import '../widgets/Book_card.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  List books = [];
  List categories = ["All", "Trending"];
  String selectedCategory = "All";

  int page = 1;
  bool loading = false;
  bool hasMore = true;

  final TextEditingController searchController =
  TextEditingController();

  @override
  void initState() {
    super.initState();
    loadCategories();
    loadBooks();
  }

  // ===== LOAD CATEGORIES FROM BACKEND =====
  Future loadCategories() async {
    try {
      final res = await LibraryService.getCategories();

      setState(() {
        categories = [
          "All",
          "Trending",
          ...res["data"]
        ];
      });
    } catch (e) {}
  }

  // ===== MAIN LOADER =====
  Future loadBooks({bool reset = false}) async {
    if (loading) return;

    if (reset) {
      page = 1;
      hasMore = true;
      books.clear();
    }

    setState(() => loading = true);

    try {
      Map<String, dynamic> res;

      if (selectedCategory == "All") {
        res = await LibraryService.getAllBooks(page);
      } else if (selectedCategory == "Trending") {
        res = await LibraryService.getTrending(page);
      } else {
        res = await LibraryService
            .getByCategory(selectedCategory, page);
      }

      setState(() {
        books.addAll(res["data"]);
        hasMore = page < res["totalPages"];
        page++;
      });

    } catch (e) {
      debugPrint(e.toString());
    }

    setState(() => loading = false);
  }

  // ===== SEARCH =====
  Future onSearch(String q) async {
    if (q.isEmpty) {
      loadBooks(reset: true);
      return;
    }

    setState(() => loading = true);

    try {
      final res = await LibraryService.search(q);

      setState(() {
        books = res["data"];
        hasMore = false;
      });

    } catch (e) {}

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground2(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                const SizedBox(height: 10),
                const HeaderSection(),
                const SizedBox(height: 20),

                // ===== SEARCH BAR =====
                CustomSearchBar(
                  controller: searchController,
                  onChanged: onSearch,
                ),

                const SizedBox(height: 20),

                // ===== CATEGORIES =====
                CategoryTabs(
                  categories: categories,
                  selected: selectedCategory,
                  onSelect: (c) {
                    setState(() => selectedCategory = c);
                    loadBooks(reset: true);
                  },
                ),

                const SizedBox(height: 20),

                // ===== GRID =====
                Expanded(
                  child: NotificationListener<
                      ScrollNotification>(
                    onNotification: (scroll) {
                      if (scroll.metrics.pixels >
                          scroll.metrics.maxScrollExtent - 200 &&
                          hasMore &&
                          !loading) {
                        loadBooks();
                      }
                      return true;
                    },

                    child: GridView.builder(
                      physics:
                      const BouncingScrollPhysics(),
                      itemCount:
                      books.length + (hasMore ? 1 : 0),

                      gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 15,
                        mainAxisSpacing: 20,
                        childAspectRatio: 0.60,
                      ),

                      itemBuilder: (context, index) {

                        if (index >= books.length) {
                          return const Center(
                              child:
                              CircularProgressIndicator());
                        }

                        final b = books[index];

                        return BookCard(
                          bookID:b["_id"],
                          title: b["title"] ?? "",
                          author: (b["authors"] != null &&
                              b["authors"].length > 0)
                              ? b["authors"][0]["name"]
                              : "Unknown",

                          rating: (b["ratings"]?["average"]
                              ?.toDouble() ??
                              0.0),

                          imageUrl: b["coverUrl"] ??
                              "https://via.placeholder.com/200x300",

                          isNew: b["isFeatured"] ?? false,
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
class CustomSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onChanged;

  const CustomSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: const Color(0xFF1F232F),
        borderRadius: BorderRadius.circular(20),
      ),

      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: const TextStyle(color: Colors.white),

        decoration: InputDecoration(
          icon:
          const Icon(Icons.search, color: Colors.grey),
          hintText: "Search books, authors...",
          border: InputBorder.none,
        ),
      ),
    );
  }
}
class CategoryTabs extends StatelessWidget {
  final List categories;
  final String selected;
  final Function(String) onSelect;

  const CategoryTabs({
    super.key,
    required this.categories,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 35,

      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,

        itemBuilder: (context, index) {
          final c = categories[index];

          bool isSelected = c == selected;

          return GestureDetector(
            onTap: () => onSelect(c),

            child: Padding(
              padding:
              const EdgeInsets.only(right: 10),

              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 8),

                decoration: BoxDecoration(
                  gradient: isSelected
                      ? const LinearGradient(
                    colors: [
                      Color(0xFF00C2FF),
                      Color(0xFF00E5FF)
                    ],
                  )
                      : null,

                  color: isSelected
                      ? null
                      : const Color(0xFF1F232F),

                  borderRadius:
                  BorderRadius.circular(20),
                ),

                child: Center(
                  child: Text(
                    c,
                    style: TextStyle(
                      color: isSelected
                          ? Colors.black
                          : Colors.grey,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
class HeaderSection extends StatelessWidget {
  const HeaderSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "Explore",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        CircleAvatar(
          radius: 20,
          backgroundColor: Colors.amber[100],
          backgroundImage: const NetworkImage("https://i.pravatar.cc/150?img=32"), // Dummy Avatar
        ),
      ],
    );
  }
}