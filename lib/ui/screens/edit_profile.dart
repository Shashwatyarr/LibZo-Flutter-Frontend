import 'dart:io';
import 'dart:ui';
import 'package:bookproject/ui/widgets/app_background2.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:image_picker/image_picker.dart';

import '../../services/profile_api.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  double _readingGoal = 8;
  bool _kindleSync = true;
  final TextEditingController fullNamectrl=TextEditingController();
  final TextEditingController userNamectrl=TextEditingController();
  final TextEditingController bioctrl=TextEditingController();
  final TextEditingController locationctrl=TextEditingController();
  String? profileImageUrl;
  File? selectedImage;
  bool loading=true;

  @override
  void initState(){
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile()async{
    try {
      final res = await ProfileApi.getProfile();
      final user = res["data"];

      fullNamectrl.text = user["fullName"] ?? "";
      userNamectrl.text = user["username"] ?? "";
      bioctrl.text = user["profile"]?["bio"] ?? "";
      locationctrl.text = user["profile"]?["location"] ?? "";
      _readingGoal =
          (user["readingPreferences"]?["readingGoalPerYear"] ?? 8).toDouble();
      _kindleSync =
          user["integrations"]?["kindleConnected"] ?? false;
      profileImageUrl=user["profile"]?["profileImage"];
      setState(() => loading = false);
    } catch (e) {
      setState(() => loading = false);
    }
  }
  Future<void> pickProfileImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() => selectedImage = File(picked.path));

      await ProfileApi.uploadProfilePhoto(selectedImage!);
    }
  }
  Future<void> saveProfile() async {
    try {
      await ProfileApi.updateProfile({
        "fullName": fullNamectrl.text,
        "username": userNamectrl.text,
        "profile.bio": bioctrl.text,
        "profile.location": locationctrl.text,
        "readingPreferences.readingGoalPerYear": _readingGoal.toInt(),
        "integrations.kindleConnected": _kindleSync,
      });

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF070B14),
      body: AppBackground2(
        child: Stack(
          children: [
            // 1. Mesh Gradient Background
            const MeshBackground(),

            SafeArea(
              child: Column(
                children: [
                  // 2. Custom Top Navigation
                  _buildHeader(context),

                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          // 3. Profile Photo Section
                          _buildPhotoSection(),
                          const SizedBox(height: 40),

                          // 4. Personal Info Section
                          _buildSectionHeader(Icons.account_circle_rounded, "Personal Information"),
                          const SizedBox(height: 16),
                          _buildGlassInput(label: "FULL NAME", controller: fullNamectrl),
                          const SizedBox(height: 12),
                          _buildGlassInput(label: "USERNAME", controller: userNamectrl, prefix: "@"),
                          const SizedBox(height: 12),
                          _buildGlassInput(label: "BIO", controller: bioctrl, isMultiline: true),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(child: _buildGlassInput(label: "LOCATION", controller: locationctrl)),
                              const SizedBox(width: 12),
                              //Expanded(child: _buildGlassInput(label: "BIRTHDAY", value: "May 12, 1995")),
                            ],
                          ),

                          const SizedBox(height: 32),

                          // 5. Reading Preferences
                          _buildSectionHeader(Icons.star, "Reading Preferences"),
                          const SizedBox(height: 16),
                          _buildPreferencesCard(),

                          const SizedBox(height: 32),

                          // 6. Integrations
                          _buildSectionHeader(Icons.layers, "Integrations"),
                          const SizedBox(height: 16),
                          _buildIntegrationTile(),

                          const SizedBox(height: 120), // Bottom button space
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 7. Fixed Bottom Button
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  // --- UI Components ---

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("Edit Profile", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),

        ],
      ),
    );
  }

  Widget _buildPhotoSection() {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF0657F9), width: 2),
                boxShadow: [BoxShadow(color: const Color(0xFF0657F9).withOpacity(0.4), blurRadius: 20)],
              ),
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: CircleAvatar(
                  backgroundImage: selectedImage != null
                      ? FileImage(selectedImage!) // 🟢 New picked image
                      : (profileImageUrl != null && profileImageUrl!.isNotEmpty)
                      ? NetworkImage(
                    "http://10.0.2.2:5000$profileImageUrl",
                  ) // 🔵 Existing backend image
                      : null,
                    child: (selectedImage == null &&
                        (profileImageUrl == null || profileImageUrl!.isEmpty))
                        ? const Icon(Icons.person, size: 60, color: Colors.white54)
                        : null,
                ),
              ),
            ),
            GestureDetector(
              onTap: pickProfileImage,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF0657F9),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.edit, color: Colors.white, size: 16),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const Text("CHANGE PHOTO", style: TextStyle(color: Color(0xFF00F5D4), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
      ],
    );
  }

  Widget _buildSectionHeader(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF0657F9), size: 18),
        const SizedBox(width: 8),
        Text(title.toUpperCase(), style: const TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
      ],
    );
  }

  Widget _buildGlassInput({
    required String label,
    required TextEditingController controller,
    String? prefix,
    bool isMultiline = false,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.03),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      color: Colors.white38,
                      fontSize: 9,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              TextField(
                controller: controller,
                maxLines: isMultiline ? 4 : 1,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                  prefixText: prefix,
                  prefixStyle:
                  const TextStyle(color: Color(0xFF0657F9)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildPreferencesCard() {
    return _buildGlassContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Favorite Genres", style: TextStyle(color: Colors.white60, fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 10,
            children: [
              _buildPill("Cyberpunk", true),
              _buildPill("Sci-Fi", false),
              _buildPill("Thriller", true),
              _buildPill("Mystery", false),
              _buildPill("Fantasy", true),
              _buildAddButton(),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Monthly Reading Goal", style: TextStyle(color: Colors.white60, fontSize: 12, fontWeight: FontWeight.bold)),
              RichText(text: TextSpan(children: [
                TextSpan(text: "${_readingGoal.toInt()} ", style: const TextStyle(color: Color(0xFF0657F9), fontSize: 24, fontWeight: FontWeight.bold)),
                const TextSpan(text: "BOOKS", style: TextStyle(color: Colors.white38, fontSize: 10)),
              ])),
            ],
          ),
          Slider(
            value: _readingGoal,
            max: 100,
            min: 1,
            activeColor: const Color(0xFF0657F9),
            inactiveColor: Colors.white10,
            onChanged: (val) => setState(() => _readingGoal = val),
          ),
        ],
      ),
    );
  }

  Widget _buildIntegrationTile() {
    return _buildGlassContainer(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.menu_book_outlined, color: Colors.white70),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Kindle Integration", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                Text("Sync highlights automatically", style: TextStyle(color: Colors.white38, fontSize: 10)),
              ],
            ),
          ),
          Switch(
            value: _kindleSync,
            activeColor: const Color(0xFF0657F9),
            onChanged: (v) => setState(() => _kindleSync = v),
          )
        ],
      ),
    );
  }

  Widget _buildPill(String text, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF0657F9) : Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        boxShadow: isActive ? [BoxShadow(color: const Color(0xFF0657F9).withOpacity(0.3), blurRadius: 10)] : null,
      ),
      child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildAddButton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF00F5D4).withOpacity(0.3)),
        color: const Color(0xFF00F5D4).withOpacity(0.1),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.add, color: Color(0xFF00F5D4), size: 14),
          SizedBox(width: 4),
          Text("Add", style: TextStyle(color: Color(0xFF00F5D4), fontSize: 11, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildGlassContainer({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.03),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
            borderRadius: BorderRadius.circular(20),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return GestureDetector(
      onTap: saveProfile,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter, end: Alignment.bottomCenter,
              colors: [Colors.transparent, const Color(0xFF070B14).withOpacity(0.9), const Color(0xFF070B14)],
            ),
          ),
          child: Container(
            width: double.infinity,
            height: 60,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF0657F9), Color(0xFF00F5D4)]),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [BoxShadow(color: const Color(0xFF0657F9).withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 0))],
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Save Changes", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(width: 8),
                Icon(Icons.save_alt_outlined, color: Colors.white),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// --- Background Mesh Effect Painter ---
class MeshBackground extends StatelessWidget {
  const MeshBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Container();
  }

  // Helper widget to create smooth "Light" instead of just a blurry circle
  Widget _glowCircle({required Color color, required double size, required double opacity}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color.withOpacity(opacity), // Center of light
            color.withOpacity(0.0),     // Fades completely to transparent
          ],
          radius: 0.5, // Controls how "spread out" the light is
        ),
      ),
    );
  }

  Widget _blurCircle(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.15),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
        child: Container(color: Colors.transparent),
      ),
    );
  }
}
