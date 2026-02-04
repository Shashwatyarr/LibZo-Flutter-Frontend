import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../services/auth_api.dart';

class AuthDecider extends StatefulWidget {
  const AuthDecider({super.key});

  @override
  State<AuthDecider> createState() => _AuthDeciderState();
}

class _AuthDeciderState extends State<AuthDecider> {

  @override
  void initState() {
    super.initState();
    decide();
  }

  void decide() async {

    bool loggedIn = await AuthApi.isLoggedIn();

    if (!mounted) return;

    if (loggedIn) {
      Navigator.pushReplacementNamed(context, "/home");
    } else {
      Navigator.pushReplacementNamed(context, "/login");
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
