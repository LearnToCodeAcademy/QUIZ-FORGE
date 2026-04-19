import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    serverClientId: '666046041125-9oc54aeqabu1b3jl1noedqnq6eqmgpr4.apps.googleusercontent.com',
  );

  // Get current user
  User? get currentUser => _firebaseAuth.currentUser;

  // Get current user stream
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // Sign in with Google (Forces Browser Flow)
  Future<UserCredential?> signInWithGoogle() async {
    try {
      print('Starting Google Sign-In via Browser Flow...');
      
      // Using GoogleAuthProvider with signInWithProvider forces a browser/tab flow
      // This bypasses many native emulator issues
      final googleProvider = GoogleAuthProvider();
      googleProvider.addScope('email');
      googleProvider.addScope('profile');
      
      final userCredential = await _firebaseAuth.signInWithProvider(googleProvider);

      print('Sign-in successful for user: ${userCredential.user?.displayName}');
      return userCredential;
    } catch (e) {
      print('Google Sign-In Browser Flow Error: $e');
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
