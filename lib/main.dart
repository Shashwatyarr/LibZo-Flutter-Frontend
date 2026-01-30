import 'package:bookproject/ui/screens/create_account.dart';
import 'package:bookproject/ui/screens/feed_screen.dart';
import 'package:bookproject/ui/screens/home_screen.dart';
import 'package:bookproject/ui/screens/login_screen.dart';
import 'package:bookproject/ui/screens/onboarding_screen.dart';
import 'package:bookproject/ui/screens/otp_screen.dart';
import 'package:bookproject/ui/screens/post_comments.dart';
import 'package:bookproject/ui/screens/splashscreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';

void main()async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  WidgetsFlutterBinding.ensureInitialized();

  // FULL SCREEN — remove status bar
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent, // transparent
        statusBarIconBrightness: Brightness.dark, // icons color
      ),
  );
  runApp(const BookProject());
}

class BookProject extends StatelessWidget {
  const BookProject({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const Splashscreen(),
      theme: ThemeData(brightness: Brightness.dark),
      routes:{
        "/signup":(context)=>const CreateAccountScreen(),
        "/onboarding":(context)=>const OnboardingScreen(),
        "/login":(context)=>const LoginScreen(),
        "/home":(context)=> const HomeScreen(),
        "/feed":(context)=> const FeedScreen(),
        "/post/comments":(context) => CommentsScreen(),
    },
        onGenerateRoute: (settings) {
      if (settings.name == "/otp") {
        final args = settings.arguments as Map<String,dynamic>;

        return MaterialPageRoute(
          builder: (_) => OtpScreen(email: args["email"]),
        );
      }
      return null;
    },
    );
  }
}

