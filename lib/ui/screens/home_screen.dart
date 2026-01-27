import 'package:bookproject/services/auth_services.dart';
import 'package:flutter/material.dart';
import '../../services/auth_services.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authService.logout();
              Navigator.pushReplacementNamed(context, "/login");
            },
          )
        ],
      ),
      body: const Center(
        child: Text(
          "Welcome to BookShare v0.0.1",
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
