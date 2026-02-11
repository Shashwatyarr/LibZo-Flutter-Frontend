import 'dart:io';
import 'package:bookproject/services/auth_api.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../services/community_service.dart';
import '../widgets/app_background2.dart';

class ClubCreatepost extends StatefulWidget {
  final String clubId;
  final String clubName;

  const ClubCreatepost({
    super.key,
    required this.clubId,
    required this.clubName,
  });

  @override
  State<ClubCreatepost> createState() => _ClubCreatepostState();
}

class _ClubCreatepostState extends State<ClubCreatepost> {

  final TextEditingController _content = TextEditingController();

  String postType = "text";

  File? selectedImage;

  bool posting = false;

  // ───── PICK IMAGE ─────
  Future<void> pickImage() async {
    final picker = ImagePicker();

    final img = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (img != null) {
      setState(() {
        selectedImage = File(img.path);
      });
    }
  }

  // ───── CREATE POST ─────
  Future<void> createPost() async {

    if (_content.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Write something first")),
      );
      return;
    }

    setState(() => posting = true);

    try {

      await CommunityService.createClubPostWithImage(
        clubId: widget.clubId,
        content: _content.text.trim(),
        type: postType,
        imageFile: selectedImage,
      );

      Navigator.pop(context, true);   // refresh previous page

    } catch (e) {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );

    } finally {
      setState(() => posting = false);
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      body: AppBackground2(
        child: SafeArea(
          child: Column(
            children: [

              // ─────────── TOP BAR ───────────
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),

                child: Row(
                  mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,

                  children: [

                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Text(
                        "Cancel",
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),

                    Column(
                      children: [

                        Text(
                          widget.clubName.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.cyanAccent,
                            fontSize: 10,
                            letterSpacing: 1.2,
                          ),
                        ),

                        const SizedBox(height: 4),

                        const Text(
                          "New Post",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),

                    GestureDetector(
                      onTap: posting ? null : createPost,

                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 6),

                        decoration: BoxDecoration(
                          color: const Color(0xFF00FFC2),
                          borderRadius:
                          BorderRadius.circular(20),
                        ),

                        child: posting
                            ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.black,
                          ),
                        )
                            : const Text(
                          "POST",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight:
                            FontWeight.bold,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ─────────── USER ROW ───────────
              FutureBuilder(
                future: AuthApi.getUsername(),

                builder: (context, snap) {

                  String name = "You";

                  if (snap.hasData) {
                    name =
                        snap.data ?? "You";
                  }

                  return ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Colors.orange,
                      child: Icon(Icons.person,
                          color: Colors.white),
                    ),

                    title: Text(
                      name,
                      style: const TextStyle(
                          color: Colors.white),
                    ),

                    subtitle: const Text(
                      "Posting to Discussions",
                      style: TextStyle(
                          color: Colors.white38,
                          fontSize: 12),
                    ),
                  );
                },
              ),

              // ─────────── TEXT FIELD ───────────
              Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 16),

                child: TextField(
                  controller: _content,

                  maxLines: 8,

                  style: const TextStyle(
                      color: Colors.white),

                  decoration: const InputDecoration(
                    hintText:
                    "Share your thoughts with the society...",
                    hintStyle:
                    TextStyle(color: Colors.white24),
                    border: InputBorder.none,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // ─────────── TAG CHIPS ───────────
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding:
                const EdgeInsets.symmetric(horizontal: 16),

                child: Row(
                  children: [

                    _chip("Text", "text"),
                    _chip("Image", "image"),
                    _chip("Quote", "quote"),

                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ─────────── UPLOAD MEDIA BOX ───────────
              GestureDetector(
                onTap: pickImage,

                child: Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16),

                  child: Container(
                    height: 180,
                    width: double.infinity,

                    decoration: BoxDecoration(
                      color:
                      Colors.white.withOpacity(0.05),

                      borderRadius:
                      BorderRadius.circular(16),

                      border: Border.all(
                          color: Colors.white10),
                    ),

                    child: selectedImage == null

                        ? const Column(
                      mainAxisAlignment:
                      MainAxisAlignment.center,

                      children: [

                        Icon(
                          Icons.camera_alt_outlined,
                          color: Colors.white38,
                          size: 36,
                        ),

                        SizedBox(height: 8),

                        Text(
                          "UPLOAD MEDIA",
                          style: TextStyle(
                            color: Colors.white38,
                            fontSize: 12,
                          ),
                        ),

                        SizedBox(height: 4),

                        Text(
                          "Images or book covers",
                          style: TextStyle(
                            color: Colors.white24,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    )

                        : ClipRRect(
                      borderRadius:
                      BorderRadius.circular(16),

                      child: Image.file(
                        selectedImage!,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),

              const Spacer(),

              // ─────────── SEND BUTTON ───────────
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),

                child: Row(
                  children: [

                    const Spacer(),

                    GestureDetector(
                      onTap: posting ? null : createPost,

                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius:
                            BorderRadius.circular(20),
                            color:
                            const Color(0xFF00FFC2)),

                        child: const Padding(
                          padding: EdgeInsets.all(20),

                          child: Icon(
                            Icons.send,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ───── CHIP WIDGET ─────
  Widget _chip(String text, String value) {

    bool active = postType == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          postType = value;
        });
      },

      child: Container(
        margin: const EdgeInsets.only(right: 8),

        padding: const EdgeInsets.symmetric(
            horizontal: 12, vertical: 6),

        decoration: BoxDecoration(
          color: active
              ? const Color(0xFF00FFC2).withOpacity(0.15)
              : Colors.white.withOpacity(0.05),

          borderRadius: BorderRadius.circular(20),

          border: Border.all(
            color: active
                ? const Color(0xFF00FFC2)
                : Colors.white10,
          ),
        ),

        child: Text(
          text,
          style: TextStyle(
            color: active
                ? const Color(0xFF00FFC2)
                : Colors.white54,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
