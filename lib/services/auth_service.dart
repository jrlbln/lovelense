import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Sign in with Google
  static Future<User?> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) return null;

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    return signInWithProvider(credential);
  }

  // Generic sign-in method for other providers
  static Future<User?> signInWithProvider(AuthCredential credential) async {
    return (await _auth.signInWithCredential(credential)).user;
  }

  // Sign out
  static Future<void> signOut() async {
    await _auth.signOut();
    await GoogleSignIn().signOut(); // Ensure Google sign-out
  }
}
