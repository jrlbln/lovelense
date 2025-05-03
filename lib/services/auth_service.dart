import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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

    final user = await signInWithProvider(credential);

    if (user != null) {
      // Record user data in Firestore
      await _firestore.collection('users').doc(user.uid).set({
        'name': user.displayName,
        'email': user.email,
        'remainingShots': 5,
      }, SetOptions(merge: true));
    }

    return user;
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
