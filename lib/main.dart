import 'package:bookproject/ui/screens/home_screen.dart';
import 'package:bookproject/ui/screens/login_screen.dart';
import 'package:bookproject/ui/screens/splashscreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main()async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const BookProject());
}

class BookProject extends StatelessWidget {
  const BookProject({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const Splashscreen(),
      routes:{
        "/login":(context)=>const LoginScreen(),
        "/home":(context)=> const HomeScreen(),
    }
    );
  }
}
