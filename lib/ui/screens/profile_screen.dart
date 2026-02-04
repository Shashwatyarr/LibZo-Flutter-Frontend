import 'package:bookproject/services/auth_api.dart';
import 'package:bookproject/services/profile_api.dart';
import 'package:bookproject/ui/screens/edit_profile.dart';
import 'package:bookproject/ui/widgets/app_background2.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'home_screen.dart';
import 'login_screen.dart';


class ProfileAnalyticsPage extends StatefulWidget {
  const ProfileAnalyticsPage({super.key});

  @override
  State<ProfileAnalyticsPage> createState() => _ProfileAnalyticsPageState();
}

class _ProfileAnalyticsPageState extends State<ProfileAnalyticsPage> {
  Map<String,dynamic>? profile;
  int completion=0;
  bool loading=true;
@override
  void initState(){
    super.initState();
    loadProfile();
}

Future<void> loadProfile()async{
  try{
    final data=await ProfileApi.getProfile();
    final percent=await ProfileApi.getProfileCompletion();

    setState(() {
      profile = data["data"];
      completion = percent;
      loading = false;
    });
  }
  catch(err){
    setState(() {
      loading=false;
    });
  }
}

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0A0A0A),
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SafeArea(
        child: AppBackground2(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                const SizedBox(height: 20),

                // Custom Header Container
                _buildHeader(),

                const SizedBox(height: 24),

                // Profile Header Card
                _buildCard(
                  child: Column(
                    children: [
                      _buildAvatarSection(context),
                      const SizedBox(height: 12),
                      Text("@"+profile?["username"] ?? "—",
                          style: const TextStyle(fontSize: 13, color: Colors.grey)),
                      Text(profile?["fullName"] ?? "—",
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                      Text(profile?["profile"]?["location"] ?? "Unknown",
                          style: TextStyle(color: Colors.grey, fontSize: 12)),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildBadge("Goodreads", const Color(0xFF003D2B), const Color(0xFF00FFB3)),
                          const SizedBox(width: 8),
                          _buildBadge("PRO MEMBER", const Color(0xFF002A5A), const Color(0xFF009DFF)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        profile?["profile"]?["bio"] ?? "No bio added yet",
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.5),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Stats Row
                Row(
                  children: [
                    Expanded(child:_buildStatCard(
                      Icons.menu_book_outlined,
                      "${profile?["analytics"]?["totalBooksRead"] ?? 0}",
                      "BOOKS READ",
                      Colors.blue,
                    ),),
                    const SizedBox(width: 16),
                    Expanded(child: _buildStatCard(
                      Icons.bookmark,
                      "${profile?["analytics"]?["totalPagesRead"] ?? 0}",
                      "PAGES READ",
                      Colors.cyan,
                    ),),
                  ],
                ),

                const SizedBox(height: 16),

                // Favorite Genres
                _buildCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.favorite_outline_sharp, size: 16, color: Colors.cyan),
                          SizedBox(width: 8),
                          Text("FAVORITE GENRES",
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white, letterSpacing: 0.5)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: (profile?["profile"]?["favoriteGenres"] ?? [])
                            .map<Widget>((g) => _buildGenreChip(g))
                            .toList(),
                  ),
            ],
                ),
                ),

                const SizedBox(height: 16),

                // Reading Goal Section
                _buildCard(
                  child: Column(
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("READING GOAL 2024",
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                          Text("18 / 24 books",
                              style: TextStyle(fontSize: 12, color: Colors.blue)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      LinearProgressIndicator(
                        value: 0.75,
                        backgroundColor: Colors.white10,
                        color: Colors.cyan,
                        borderRadius: BorderRadius.circular(10),
                        minHeight: 10,
                      ),
                      const SizedBox(height: 12),

                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Updated Reading Progress & Kindle Section
                _buildCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.bar_chart, size: 16, color: Colors.cyan),
                            SizedBox(width: 8),
                            Text("WEEKLY PROGRESS",
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white)),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Day-wise Bars
                        SizedBox(
                          height: 120,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              _buildDayBar("MON", 0.4),
                              _buildDayBar("TUE", 0.7),
                              _buildDayBar("WED", 0.9),
                              _buildDayBar("THU", 0.5),
                              _buildDayBar("FRI", 0.6),
                              _buildDayBar("SAT", 0.8),
                              _buildDayBar("SUN", 0.3),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),
                        const Text("DOMINANT READING MOODS",
                            style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),

                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _buildMoodChip(Icons.navigation, "Introspective", const Color(0xFF2D2D5F)),
                            _buildMoodChip(Icons.electric_bolt, "Excited", const Color(0xFF4A3712)),
                            _buildMoodChip(Icons.energy_savings_leaf_rounded, "Relaxed", const Color(0xFF1B3D2F)),
                          ],
                        ),

                        const SizedBox(height: 24),

                        const Padding(
                          padding: EdgeInsets.only(left: 4, bottom: 12),
                          child: Text("CONNECTED ACCOUNTS",
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.0)),
                        ),

                        // Kindle Library Card with Functional Toggle
                        _buildCard(
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.menu_book_outlined, color: Colors.blue, size: 24),
                              ),
                              const SizedBox(width: 16),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Kindle Library",
                                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                                    SizedBox(height: 2),
                                    Text("SYNCED 2H AGO",
                                        style: TextStyle(color: Colors.grey, fontSize: 9, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                              const CustomKindleToggle(), // Functional Toggle Component
                            ],
                          ),
                        ),
                      ],
                    )
                ),

                const SizedBox(height: 16),

                // Logout Button
                Opacity(
                  opacity: 0.6,
                  child: TextButton.icon(
                    onPressed: ()async=>{
                      await AuthApi.logout(),

                    Navigator.pushAndRemoveUntil( context, MaterialPageRoute(builder: (_) => LoginScreen()), (route) => false, )
                    },
                    icon: const Icon(Icons.logout, color: Colors.redAccent, size: 18),
                    label: const Text("SIGN OUT ACCOUNT",
                        style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- Header, Avatar, and Components remain same ---
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Text(
              'Profile Analytics',
              style: TextStyle(color: Color(0xFF40E0D0), fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        Row(
          children: [
            _buildCircleIcon(Icons.notifications),
            const SizedBox(width: 12),
            _buildCircleIcon(Icons.settings),
          ],
        ),
      ],
    );
  }

  Widget _buildAvatarSection(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFF40E0D0), width: 3),
          ),
          child:  Padding(
            padding: EdgeInsets.all(4.0),
            child: CircleAvatar(
              radius: 46,
              backgroundImage: profile?["profile"]?["profileImage"] != null
                  ? NetworkImage(
                "http://10.0.2.2:5000${profile!["profile"]["profileImage"]}",
              )
                  : null,
              child: profile?["profile"]?["profileImage"] == null
                  ? const Icon(Icons.person, size: 60)
                  : null,
            ),
          ),
        ),
        Positioned(
          bottom: 4,
          right: 4,
          child: GestureDetector(
            onTap: () async{
              final updated = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EditProfilePage()),
              );

              if (updated == true) {
                loadProfile();
              }
            },
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.teal,
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF121212), width: 2),
              ),
              child: const Icon(Icons.edit, size: 14, color: Colors.white),
            ),
          ),
        ),
        Positioned(
          top: 0,
          right: -110,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Profile\nCompletion", style: TextStyle(color: Color(0xFF40E0D0), fontSize: 10, fontWeight: FontWeight.bold),textAlign: TextAlign.right,),
              Text("$completion%", style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),textAlign: TextAlign.right,),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF121212).withOpacity(0.4),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: child,
    );
  }

  Widget _buildStatCard(IconData icon, String val, String label, Color color) {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 12),
          Text(val, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
          Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildGenreChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
    );
  }

  Widget _buildBadge(String text, Color bg, Color textCol) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(text, style: TextStyle(color: textCol, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildCircleIcon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: const BoxDecoration(color: Color(0xFF1A1A1A), shape: BoxShape.circle),
      child: Icon(icon, color: Colors.white, size: 20),
    );
  }

  Widget _buildMoodChip(IconData icon, String label, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bg.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: bg, width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.white),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildDayBar(String day, double heightFactor) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text("${(heightFactor * 100).toInt()}%",
          style: TextStyle(
            // 80%+: Green, 40%+: Yellow, Else: Red
            color: (heightFactor * 100) >= 80
                ? Colors.green
                : (heightFactor * 100) >= 40
                ? Colors.yellowAccent
                : Colors.redAccent,
            fontSize: 7,
            fontWeight: FontWeight.bold,
          ),),
        const SizedBox(height: 4),
        Container(
          width: 18,
          height: 80 * heightFactor,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                ((heightFactor * 100) >= 80
                    ? Colors.green
                    : (heightFactor * 100) >= 40
                    ? Colors.yellowAccent
                    : Colors.redAccent).withOpacity(0.8),

                // Bottom color hamesha fade effect ke liye kam opacity par rahega
                ((heightFactor * 100) >= 80
                    ? Colors.green
                    : (heightFactor * 100) >= 40
                    ? Colors.yellowAccent
                    : Colors.redAccent).withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 8),
        Text(day,
            style: TextStyle(
                color: heightFactor > 0.8 ? Colors.white : Colors.grey,
                fontSize: 9,
                fontWeight: FontWeight.bold
            )
        ),
      ],
    );
  }
}

// --- Stateful Toggle Component ---
class CustomKindleToggle extends StatefulWidget {
  const CustomKindleToggle({super.key});

  @override
  State<CustomKindleToggle> createState() => _CustomKindleToggleState();
}

class _CustomKindleToggleState extends State<CustomKindleToggle> {
  bool isSwitched = true;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => isSwitched = !isSwitched),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 42,
        height: 22,
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: isSwitched ? const Color(0xFF00E5FF) : Colors.grey[800],
          borderRadius: BorderRadius.circular(12),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          alignment: isSwitched ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 18,
            height: 18,
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
          ),
        ),
      ),
    );
  }
}