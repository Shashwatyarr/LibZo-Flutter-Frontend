import 'package:bookproject/services/auth_api.dart';
import 'package:bookproject/ui/screens/book.dart';
import 'package:bookproject/ui/screens/create_account.dart';
import 'package:bookproject/ui/screens/feed_screen.dart';
import 'package:bookproject/ui/screens/library.dart';
import 'package:bookproject/ui/screens/login_screen.dart';
import 'package:bookproject/ui/screens/main_profile.dart';
import 'package:bookproject/ui/screens/onboarding_screen.dart';
import 'package:bookproject/ui/screens/otp_screen.dart';
import 'package:bookproject/ui/screens/profile_screen.dart';
import 'package:bookproject/ui/widgets/AuthDecider.dart';
import 'package:bookproject/ui/widgets/main_wrapper.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
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

      home: const AuthDecider(),

      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
      ),

      routes: {
        "/signup": (context) => const CreateAccountScreen(),
        "/onboarding": (context) => const OnboardingScreen(),
        "/login": (context) => const LoginScreen(),
        "/home": (context) => const MainWrapper(),
        "/feed": (context) => const FeedScreen(),
        "/profile": (context) => const ProfileScreen(),
        "/library":(context)=> const LibraryScreen(),
        "/book": (context)=>const BookDetailsScreen(),
        "/profileanalytics":(context)=>const ProfileAnalyticsPage(),
      },

      onGenerateRoute: (settings) {
        if (settings.name == "/otp") {
          final args = settings.arguments as Map<String, dynamic>;

          return MaterialPageRoute(
            builder: (_) => OtpScreen(
              username: args["username"],   // 👈 CHANGED
            ),
          );
        }
        return null;
      },
    );
  }
}
