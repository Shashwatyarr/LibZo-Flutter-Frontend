import 'package:bookproject/services/auth_api.dart';
import 'package:bookproject/ui/widgets/app_background.dart';
import 'package:flutter/material.dart';

class OtpScreen extends StatefulWidget {
  final String email;
  const OtpScreen({super.key, required this.email});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final controllers =
  List.generate(6, (_) => TextEditingController());
  final focusNodes =
  List.generate(6, (_) => FocusNode());

  bool loading = false;

  void moveToNext(int index, String value) {
    if (value.isNotEmpty && index < 5) {
      focusNodes[index + 1].requestFocus();
    }
  }

  Future<void> verifyOtp() async {
    String otp = controllers.map((e) => e.text).join();

    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Enter valid OTP")));
      return;
    }

    setState(() => loading = true);

    try {
      final res = await AuthApi.verifyOtp(
        email: widget.email,
        otp: otp,
      );

      print(res);
      await AuthApi.saveToken(res["token"]);
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
            context, "/home", (_) => false);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())));
    }

    setState(() => loading = false);
  }

  Future<void> resendOtp() async {
    await AuthApi.resendOtp(widget.email);

    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("OTP resent")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Verify Email",
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                const SizedBox(height: 10),
                Text(
                  "Enter the 6-digit code sent to your email",
                  textAlign: TextAlign.center,
                  style:
                  TextStyle(color: Colors.white.withOpacity(0.6)),
                ),
                const SizedBox(height: 40),

                /// OTP BOXES
                Row(
                  mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
                  children: List.generate(6, (index) {
                    return SizedBox(
                      width: 45,
                      child: TextField(
                        controller: controllers[index],
                        focusNode: focusNodes[index],
                        maxLength: 1,
                        textAlign: TextAlign.center,
                        keyboardType:
                        TextInputType.number,
                        style: const TextStyle(
                            fontSize: 20,
                            color: Colors.white),
                        decoration: InputDecoration(
                          counterText: "",
                          filled: true,
                          fillColor: Colors.white
                              .withOpacity(0.05),
                          border: OutlineInputBorder(
                            borderRadius:
                            BorderRadius.circular(12),
                          ),
                        ),
                        onChanged: (value) =>
                            moveToNext(index, value),
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 40),

                /// VERIFY BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed:
                    loading ? null : verifyOtp,
                    child: loading
                        ? const CircularProgressIndicator()
                        : const Text("Verify"),
                  ),
                ),
                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment:
                  MainAxisAlignment.center,
                  children: [
                    Text(
                      "Didn't receive code? ",
                      style: TextStyle(
                          color: Colors.white
                              .withOpacity(0.5)),
                    ),
                    GestureDetector(
                      onTap: resendOtp,
                      child: const Text(
                        "Resend Code",
                        style: TextStyle(
                            color: Colors.greenAccent,
                            fontWeight:
                            FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      backgroundColor: Colors.black,
    );
  }
}
