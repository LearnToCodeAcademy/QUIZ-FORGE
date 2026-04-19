import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    serverClientId: '666046041125-2lc674r7jivd8pdriing84c06e8ajdbt.apps.googleusercontent.com',
  );

  // Get current user
  User? get currentUser => _firebaseAuth.currentUser;

  // Get current user stream
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      print('Starting Google Sign-In...');
      late final GoogleSignInAccount? googleUser;
      
      if (kIsWeb) {
        // Web platform sign-in
        print('Using web sign-in flow');
        googleUser = await _googleSignIn.signIn();
      } else {
        // Mobile platform sign-in
        print('Using mobile sign-in flow, signing out first...');
        await _googleSignIn.signOut();
        googleUser = await _googleSignIn.signIn();
      }
      
      if (googleUser == null) {
        print('Google sign-in cancelled by user');
        return null;
      }

      print('Google user selected: ${googleUser.displayName} (${googleUser.email})');

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        print('Error: Missing access token or ID token');
        return null;
      }

      print('Creating Firebase credential...');
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      print('Signing in with Firebase...');
      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      print('Sign-in successful for user: ${userCredential.user?.displayName}');
      return userCredential;
    } catch (e, stackTrace) {
      print('Google Sign-In Error: $e');
      print('Stack trace: $stackTrace');
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
