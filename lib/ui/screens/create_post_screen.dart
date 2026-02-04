import 'dart:io';
import 'package:bookproject/ui/widgets/app_background2.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/post_service.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController controller = TextEditingController();
  bool loading = false;

  // 🔥 CHANGE 1: List instead of single file
  List<File> selectedImages = [];

  final PageController pageController = PageController();

  final Color kAccentColor = const Color(0xFF00E676);
  final Color kCardColor = const Color(0xFF1F222A);

  // --------------------------------------------------
  // IMAGE PICK FUNCTION (MULTI SUPPORT)
  // --------------------------------------------------
  Future<void> pickImage() async {
    try {
      final picker = ImagePicker();

      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (picked == null) return;

      final file = File(picked.path);

      // ----- VALIDATIONS -----
      if (selectedImages.length >= 4) {
        showSnack("Maximum 4 images allowed");
        return;
      }

      final sizeInMB = file.lengthSync() / (1024 * 1024);
      if (sizeInMB > 5) {
        showSnack("Image must be ≤ 5MB");
        return;
      }

      setState(() {
        selectedImages.add(file);
      });

    } catch (e) {
      showSnack("Failed to pick image");
    }
  }

  // --------------------------------------------------
  // POST FUNCTION WITH SNACKBARS
  // --------------------------------------------------
  Future<void> post() async {
    try {
      if (controller.text.trim().isEmpty) {
        showSnack("Text is mandatory");
        return;
      }

      setState(() => loading = true);

      await ApiService.createPost(
        text: controller.text.trim(),
        images: selectedImages,
      );

      setState(() => loading = false);

      showSnack("Post uploaded successfully 🎉");

      Navigator.pop(context, true);

    } catch (e) {
      setState(() => loading = false);
      showSnack(e.toString());
    }
  }

  void showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  // --------------------------------------------------
  // CAROUSEL WIDGET
  // --------------------------------------------------
  Widget imageCarousel() {
    return Column(
      children: [
        SizedBox(
          height: 220,
          child: PageView.builder(
            controller: pageController,
            itemCount: selectedImages.length,
            itemBuilder: (context, index) {
              return Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.file(
                        selectedImages[index],
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  // DELETE BUTTON
                  Positioned(
                    right: 10,
                    top: 10,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedImages.removeAt(index);
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),

        const SizedBox(height: 8),

        // DOT INDICATOR
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            selectedImages.length,
                (i) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: kAccentColor,
              ),
            ),
          ),
        )
      ],
    );
  }

  // --------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground2(
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Column(
              children: [
                // HEADER
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        margin: const EdgeInsets.only(right: 20),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: kAccentColor,
                        ),
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.black,
                          size: 20,
                        ),
                      ),
                    ),

                    const Text(
                      "Create Post",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(width: 40),
                  ],
                ),

                const SizedBox(height: 20),

                // TEXT FIELD
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: kCardColor.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: TextField(
                    controller: controller,
                    maxLines: 6,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: "Share your thoughts...",
                      border: InputBorder.none,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // 🔥 CAROUSEL PREVIEW
                if (selectedImages.isNotEmpty) imageCarousel(),

                const SizedBox(height: 12),

                // ADD IMAGE BUTTON
                GestureDetector(
                  onTap: pickImage,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: kCardColor,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.image, color: Colors.white70),
                        SizedBox(width: 8),
                        Text(
                          "Add Image",
                          style: TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // POST BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: loading ? null : post,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kAccentColor,
                    ),
                    child: loading
                        ? const CircularProgressIndicator(color: Colors.black)
                        : const Text(
                      "Post",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
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
