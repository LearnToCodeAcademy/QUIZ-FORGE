import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  late final GoogleSignIn _googleSignIn;

  AuthService() {
    _googleSignIn = GoogleSignIn(
      clientId: kIsWeb ? '666046041125-0qpjq4beaon15l13aqlt3jic5r40en5h.apps.googleusercontent.com' : null,
      scopes: ['email', 'profile'],
      serverClientId: kIsWeb ? null : '666046041125-0qpjq4beaon15l13aqlt3jic5r40en5h.apps.googleusercontent.com',
    );
  }

  // Get current user
  User? get currentUser => _firebaseAuth.currentUser;

  // Get current user stream
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // Sign in with Google (Forces Browser Flow)
  Future<UserCredential?> signInWithGoogle() async {
    try {
      print('Starting Google Sign-In...');
      
      final googleProvider = GoogleAuthProvider();
      googleProvider.addScope('email');
      googleProvider.addScope('profile');
      
      UserCredential? userCredential;

      if (kIsWeb) {
        // Use popup or redirect for web to avoid UnimplementedError
        print('Web platform detected, using signInWithPopup...');
        userCredential = await _firebaseAuth.signInWithPopup(googleProvider);
      } else {
        // For mobile, using signInWithProvider (which uses browser flow on some configs)
        // or standard GoogleSignIn flow.
        print('Mobile platform detected, using signInWithProvider...');
        userCredential = await _firebaseAuth.signInWithProvider(googleProvider);
      }

      print('Sign-in successful for user: ${userCredential.user?.displayName}');
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
