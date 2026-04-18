import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    hostedDomain: '',
  );

  // Get current user
  User? get currentUser => _firebaseAuth.currentUser;

  // Get current user stream
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      late final GoogleSignInAccount? googleUser;
      
      if (kIsWeb) {
        // Web platform sign-in
        googleUser = await _googleSignIn.signIn();
      } else {
        // Mobile platform sign-in
        await _googleSignIn.signOut();
        googleUser = await _googleSignIn.signIn();
      }
      
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      return userCredential;
    } catch (e) {
      print('Google Sign-In Error: $e');
      return null;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _firebaseAuth.signOut();
    } catch (e) {
      print('Sign Out Error: $e');
    }
  }

  // Get user display name
  String get displayName => currentUser?.displayName ?? 'Guest User';

  // Get user email
  String get userEmail => currentUser?.email ?? 'no-email@example.com';

  // Get user photo URL
  String? get photoUrl => currentUser?.photoURL;

  // Check if user is signed in
  bool get isSignedIn => currentUser != null;
}
