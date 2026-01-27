import 'package:bookproject/services/update_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class Splashscreen extends StatefulWidget {
  const Splashscreen({super.key});

  @override
  State<Splashscreen> createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen> {

  @override
  void initState() {
    super.initState();
    _startApp();
  }

  Future<void> _startApp() async {
    await Future.delayed(const Duration(milliseconds: 500));

    bool needUpdate = await UpdateService.isUpdateAvailable();

    if (needUpdate) {
      _showUpdateDialog();
      return;
    }

    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      Navigator.pushReplacementNamed(context, "/login");
    } else {
      Navigator.pushReplacementNamed(context, "/home");
    }
  }

  void _showUpdateDialog() {
    String link = UpdateService.getUpdateLink();
   String versionname=UpdateService.getlatestversion();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text("Update Required"),
          content: Text("A new version ($versionname) of the app is available."),
          actions: [
            TextButton(
              onPressed: () {
                launchUrl(Uri.parse(link),
                    mode: LaunchMode.externalApplication);
              },
              child: Text("Update"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
