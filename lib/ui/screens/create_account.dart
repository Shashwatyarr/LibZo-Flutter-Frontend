import 'dart:ui';

import 'package:bookproject/services/auth_api.dart';
import 'package:bookproject/services/auth_services.dart';
import 'package:bookproject/ui/widgets/app_background.dart';
import 'package:bookproject/utils/fonts.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart'; // Uncomment if you add social login here too

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  // Controllers
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // State for toggling password visibility
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Define colors
    const Color primaryBlue = Color(0xFF0066FF);
    const Color accentGreen = Color(0xFF00C896);
    const Color inputFillColor = Color(0xFF12151C);

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: AppBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // --- Header Section ---
                  Text(
                    "Libzo",
                    style: AppTextStyles.title(),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Join the community",
                    style: AppTextStyles.subtitle(),
                  ),
                  const SizedBox(height: 30), // Slightly less spacing to fit more fields

                  // --- Signup Card ---
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.transparent, // Keeping your glassy style
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.08),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Stack(
                      children:[
                        // BackdropFilter(
                        //   filter: ImageFilter.blur(
                        //     sigmaX: 20, // blur intensity X
                        //     sigmaY: 20, // blur intensity Y
                        //   ),
                        //   child: Container(
                        //     color: Colors.white.withOpacity(0.5),
                        //   ),
                        // ),

                        Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          // Username Field
                          _buildLabel("USERNAME"),
                          const SizedBox(height: 8),
                          _buildTextField(
                            controller: _usernameController,
                            hintText: "bookworm_23",
                            icon: Icons.person_outline,
                            fillColor: inputFillColor.withOpacity(0.4),
                          ),

                          const SizedBox(height: 16),

                          // Full Name Field
                          _buildLabel("FULL NAME"),
                          const SizedBox(height: 8),
                          _buildTextField(
                            controller: _fullNameController,
                            hintText: "Alex Rivera",
                            icon: Icons.badge_outlined,
                            fillColor: inputFillColor.withOpacity(0.4),
                          ),

                          const SizedBox(height: 16),

                          // Email Field
                          _buildLabel("EMAIL ADDRESS"),
                          const SizedBox(height: 8),
                          _buildTextField(
                            controller: _emailController,
                            hintText: "name@example.com",
                            icon: Icons.mail_outline,
                            fillColor: inputFillColor.withOpacity(0.4),
                          ),

                          const SizedBox(height: 16),

                          // Password Field
                          _buildLabel("PASSWORD"),
                          const SizedBox(height: 8),
                          _buildTextField(
                            controller: _passwordController,
                            hintText: "Create a password",
                            icon: Icons.lock_outline,
                            fillColor: inputFillColor.withOpacity(0.4),
                            isPassword: true,
                            isPasswordVisible: _isPasswordVisible,
                            onVisibilityToggle: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),

                          const SizedBox(height: 24),

                          // Create Account Button
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: () async{
                                try {
                                  final res = await AuthApi.signup(
                                    username: _usernameController.text.trim(),
                                    fullname: _fullNameController.text.trim(),
                                    email: _emailController.text.trim(),
                                    password: _passwordController.text,
                                  );

                                  final token = res['token'];
                                  final user = res['user'];

                                  Navigator.pushReplacementNamed(
                                      context, '/otp',arguments: {"email":_emailController.text.trim()});
                                }
                                catch(e){
                                  print(e.toString());
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryBlue,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                                shadowColor: primaryBlue,
                              ),
                              child: const Text(
                                "Create Account",
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                      ]
                    ),
                  ),

                  const SizedBox(height: 30),

                  // --- Footer ---
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacementNamed(context, "/login");
                    },
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(fontSize: 14),
                        children: [
                          TextSpan(
                            text: "Already have an account? ",
                            style: AppTextStyles.subtitle(
                                color: Colors.white.withOpacity(0.5)),
                          ),
                          TextSpan(
                            text: "Log in",
                            style: AppTextStyles.subtitle(
                              color: accentGreen,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Bottom padding to ensure scrolling works well
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- Helper Widgets (Same as LoginScreen) ---

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white54,
        fontSize: 10,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.8,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    required Color fillColor,
    bool isPassword = false,
    bool isPasswordVisible = false,
    VoidCallback? onVisibilityToggle,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: fillColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword && !isPasswordVisible,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
          prefixIcon: Icon(icon, color: Colors.white54, size: 20),
          suffixIcon: isPassword
              ? IconButton(
            icon: Icon(
              isPasswordVisible ? Icons.visibility : Icons.visibility_off,
              color: Colors.white38,
              size: 20,
            ),
            onPressed: onVisibilityToggle,
          )
              : null,
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.white.withOpacity(0.1),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.white.withOpacity(0.3),
              width: 1.4,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }
}