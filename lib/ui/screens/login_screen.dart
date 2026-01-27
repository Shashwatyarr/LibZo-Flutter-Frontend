import 'package:bookproject/services/auth_services.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(onPressed: ()async{
          final user = await authService.signInWithGoogle();

          if (user != null) {
            Navigator.pushReplacementNamed(context, "/home");
          }
        },
            style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 40,vertical: 15),
        ),
            child: Text(
              "SignIn with Google",
              style: TextStyle(fontSize: 18),
            )),
      ),
    );
  }
}
