import 'package:bookproject/services/auth_services.dart';
import 'package:bookproject/ui/widgets/app_background.dart';
import 'package:flutter/material.dart';
import '../../services/auth_services.dart' hide authService;

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
        
                // Logout button aligned right
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    icon: const Icon(Icons.logout, size: 28),
                    onPressed: () async {
                      await authService.logout();
                      Navigator.pushReplacementNamed(context, "/login");
                    },
                  ),
                ),
        
                const SizedBox(height: 40),
        
                const Center(
                  child: Text(
                    "Welcome to BookShare v0.0.1",
                    style: TextStyle(fontSize: 20),
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
