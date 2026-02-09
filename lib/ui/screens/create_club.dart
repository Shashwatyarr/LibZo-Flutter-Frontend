import 'dart:io';
import 'package:bookproject/ui/widgets/app_background2.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../services/community_service.dart';

class CreateClubScreen extends StatefulWidget {
  const CreateClubScreen({super.key});

  @override
  State<CreateClubScreen> createState() => _CreateClubScreenState();
}

class _CreateClubScreenState extends State<CreateClubScreen> {

  final nameCtrl = TextEditingController();
  final descCtrl = TextEditingController();

  bool isPublic = true;
  bool loading = false;

  List<String> selectedGenres = [];
  File? bannerImage;

  final ImagePicker picker = ImagePicker();

  // ================= IMAGE PICK =================

  Future<void> pickBanner() async {
    final XFile? image =
    await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        bannerImage = File(image.path);
      });
    }
  }

  // ================= CREATE CLUB =================

  Future<void> createClub() async {

    if (nameCtrl.text.trim().isEmpty) {
      showMsg("Club name required");
      return;
    }

    try {
      setState(() => loading = true);

      await CommunityService.createClub(
        name: nameCtrl.text,
        description: descCtrl.text,
        genre: selectedGenres,
        type: isPublic ? "public" : "private",
        imagePath: bannerImage?.path,
      );

      showMsg("Club Created Successfully");

      Navigator.pop(context, true);

    } catch (e) {
      showMsg(e.toString());
    }

    setState(() => loading = false);
  }

  void showMsg(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground2(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                _buildTopBar(context),

                const SizedBox(height: 20),

                GestureDetector(
                  onTap: pickBanner,
                  child: _buildBannerUpload(),
                ),

                const SizedBox(height: 32),

                _buildSectionLabel("BASIC INFORMATION"),

                _buildTextField("Club Name", controller: nameCtrl),

                const SizedBox(height: 16),

                _buildTextField(
                  "Description",
                  maxLines: 4,
                  controller: descCtrl,
                ),

                const SizedBox(height: 32),

                _buildSectionLabel("PRIVACY SETTINGS"),

                _buildPrivacyToggle(),

                const SizedBox(height: 32),

                _buildSectionLabel("INTERESTS & GENRES"),

                _buildGenreChips(),

                const SizedBox(height: 40),

                GestureDetector(
                  onTap: loading ? null : createClub,
                  child: _buildCreateButton(),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ================= COMPONENTS =================

  Widget _buildTopBar(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close, color: Colors.white),
          style: IconButton.styleFrom(backgroundColor: Colors.white10),
        ),
        const Expanded(
          child: Center(
            child: Text("Create Club",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(width: 48),
      ],
    );
  }

  Widget _buildBannerUpload() {
    return Container(
      width: double.infinity,
      height: 160,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),

        image: bannerImage != null
            ? DecorationImage(
          image: FileImage(bannerImage!),
          fit: BoxFit.cover,
        )
            : null,
      ),

      child: bannerImage == null
          ? Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.add_a_photo_outlined,
              color: Colors.white38, size: 32),
          SizedBox(height: 8),
          Text("Add Club Banner",
              style:
              TextStyle(color: Colors.white38, fontSize: 12)),
        ],
      )
          : null,
    );
  }

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(label,
          style: const TextStyle(
              color: Colors.white38,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2)),
    );
  }

  Widget _buildTextField(String hint,
      {int maxLines = 1,
        IconData? prefixIcon,
        TextEditingController? controller}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white24),
        prefixIcon:
        prefixIcon != null ? Icon(prefixIcon, color: Colors.white24) : null,
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.all(16),
      ),
    );
  }

  Widget _buildPrivacyToggle() {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Expanded(child: _toggleButton("Public", isPublic)),
          Expanded(child: _toggleButton("Private", !isPublic)),
        ],
      ),
    );
  }

  Widget _toggleButton(String text, bool selected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          isPublic = text == "Public";
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: selected ? Colors.white12 : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(text,
              style: TextStyle(
                  color: selected
                      ? const Color(0xFF00FFA3)
                      : Colors.white38,
                  fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _buildGenreChips() {
    List<String> all = [
      "Sci-Fi",
      "Fantasy",
      "Thriller",
      "Romance",
      "Mystery",
      "Horror"
    ];

    return Wrap(
      spacing: 8,
      children: all.map((g) {
        bool sel = selectedGenres.contains(g);

        return GestureDetector(
          onTap: () {
            setState(() {
              if (sel)
                selectedGenres.remove(g);
              else
                selectedGenres.add(g);
            });
          },
          child: _genreChip(g, sel),
        );
      }).toList(),
    );
  }

  Widget _genreChip(String label, bool isSelected) {
    return Chip(
      label: Text(label,
          style: TextStyle(
              color: isSelected
                  ? const Color(0xFF00FFA3)
                  : Colors.white38,
              fontSize: 12)),
      backgroundColor: isSelected
          ? const Color(0xFF00FFA3).withOpacity(0.1)
          : Colors.white.withOpacity(0.05),
      shape: StadiumBorder(
          side: BorderSide(
              color: isSelected
                  ? const Color(0xFF00FFA3).withOpacity(0.3)
                  : Colors.white10)),
    );
  }

  Widget _buildCreateButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [Color(0xFF007BFF), Color(0xFF00FFA3)],
        ),
      ),
      child: Center(
        child: loading
            ? const CircularProgressIndicator(color: Colors.black)
            : const Text("Create Club",
            style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 16)),
      ),
    );
  }
}
