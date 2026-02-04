import 'package:bookproject/services/auth_services.dart'; // Make sure this path is correct in your project
import 'package:bookproject/ui/screens/create_account.dart';
import 'package:bookproject/ui/widgets/app_background.dart'; // Ensure this path is correct
import 'package:bookproject/utils/fonts.dart';
import 'package:bookproject/utils/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../services/auth_api.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controllers to retrieve text
  bool loading = false;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _telegramController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // State for toggling password visibility
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _telegramController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Define colors from the image
    const Color primaryBlue = Color(0xFF0066FF);
    const Color accentGreen = Color(0xFF00C896);
    const Color inputFillColor = Color(0xFF12151C); // Very dark blue/grey// Almost black, slightly transparent look

    return Scaffold(
      // extending body behind app bar if you add one later
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
                    "Your world of stories awaits.",
                    style: AppTextStyles.subtitle()
                  ),
                  const SizedBox(height: 40),

                  // --- Login Card ---
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.08), // Subtle border
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Username Field
                        _buildLabel("USERNAME"),
                        const SizedBox(height: 8),
                        _buildTextField(
                          controller: _usernameController,
                          hintText: "your username",
                          icon: Icons.person_outline,
                          fillColor: inputFillColor.withOpacity(0.4),
                        ),

                        const SizedBox(height: 20),

// Telegram Username
                        _buildLabel("TELEGRAM USERNAME"),
                        const SizedBox(height: 8),
                        _buildTextField(
                          controller: _telegramController,
                          hintText: "@your_telegram",
                          icon: Icons.telegram,
                          fillColor: inputFillColor.withOpacity(0.4),
                        ),
                        const SizedBox(height: 20),

                        // Password Field
                        _buildLabel("PASSWORD"),
                        const SizedBox(height: 8),
                        _buildTextField(
                          controller: _passwordController,
                          hintText: "••••••••",
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

                        // Forgot Password
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              // TODO: Handle Forgot Password
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white54,
                              padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Text(
                              "Forgot password?",
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Log In Button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: loading ? null : () async {
                              setState(() => loading = true);

                              try {

                                // STEP 1 – Login
                                await AuthApi.login(
                                  username: _usernameController.text.trim(),
                                  password: _passwordController.text,
                                );

                                // STEP 2 – Check Telegram linked
                                bool linked = await AuthApi.checkTelegramLinked(
                                    _usernameController.text.trim()
                                );

                                if (!linked) {

                                  // Telegram open karo
                                  final link =
                                      "https://t.me/libzo_auth_bot?start=${_usernameController.text.trim()}";

                                  await launchUrl(Uri.parse(link));

                                  showErrorSnackBar(
                                      context,
                                      "Open Telegram and press START first"
                                  );

                                  return;
                                }

                                // STEP 3 – Request OTP
                                await AuthApi.requestOtp(
                                  username: _usernameController.text.trim(),
                                );

                                // STEP 4 – Go to OTP screen
                                Navigator.pushNamed(
                                  context,
                                  "/otp",
                                  arguments: {
                                    "username": _usernameController.text.trim()
                                  },
                                );

                              } catch (e) {
                                showErrorSnackBar(context, e.toString());
                              }

                              setState(() => loading = false);
                            },


                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryBlue,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 6,
                              shadowColor: primaryBlue.withOpacity(0.4)
                            ),
                            child: loading
                                ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                                : const Text(
                              "Log In",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                          ),
                        ),

                        const SizedBox(height: 24),

                        // Divider
                        Row(
                          children: [
                            const Expanded(child: Divider(color: Colors.white12)),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: Text(
                                "OR CONTINUE WITH",
                                style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.white.withOpacity(0.3),
                                    fontWeight: FontWeight.bold
                                ),
                              ),
                            ),
                            const Expanded(child: Divider(color: Colors.white12)),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Google Button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () async {final user = await authService.signInWithGoogle();
                              if (user != null && mounted) {
                                Navigator.pushReplacementNamed(context, "/home");
                              }
                              print("Google Sign In Pressed");
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white.withOpacity(0.05), // Glassy dark
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(color: Colors.white.withOpacity(0.1)),
                              ),
                              elevation: 0,
                            ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SvgPicture.asset(
                                    'assets/images/google.svg',
                                    width: 24,
                                    height: 24,
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    "Google",
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              )
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // --- Footer ---
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacementNamed(context, "/signup");
                    },
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(fontSize: 14),
                        children: [
                          TextSpan(
                            text: "Don't have an account? ",
                            style: AppTextStyles.subtitle(color: Colors.white.withOpacity(0.5)),
                          ),
                          TextSpan(
                            text: "Create account",
                            style: AppTextStyles.subtitle(
                              color: accentGreen,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- Helper Widgets ---

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

          // Remove double borders
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }
}