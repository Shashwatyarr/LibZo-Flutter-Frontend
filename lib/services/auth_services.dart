import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';


class authService{
  static final FirebaseAuth _auth=FirebaseAuth.instance;

  static Future<User?> signInWithGoogle()async{
    try{
      final GoogleSignInAccount? gUser=await GoogleSignIn().signIn();
      if(gUser==null){
        print('SignIn failed');
        return null;
      }
      final GoogleSignInAuthentication gAuth = await gUser.authentication;

      final credential=GoogleAuthProvider.credential(
        accessToken: gAuth.accessToken,
        idToken: gAuth.idToken,
      );
      UserCredential userCredential= await _auth.signInWithCredential(credential);
      return userCredential.user;
    }
    catch(e){
      print("Google Sign-In Error: $e");
      return null;
    }
  }
  static Future<void> logout()async{
    await GoogleSignIn().signOut();
    await _auth.signOut();
}
}