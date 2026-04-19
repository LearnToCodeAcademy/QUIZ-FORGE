import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../lib/firebase_options.dart';

void main() async {
  print('🔍 Testing Google Sign-In Configuration...');

  try {
    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase initialized successfully');

    // Check current user
    final currentUser = FirebaseAuth.instance.currentUser;
    print('Current user: ${currentUser?.displayName ?? 'None'}');

    // Test Google Sign-In configuration
    final googleSignIn = GoogleSignIn(
      scopes: ['email', 'profile'],
    );

    print('Google Sign-In client ID: ${googleSignIn.clientId}');
    print('Google Sign-In server client ID: ${googleSignIn.serverClientId}');

    // Check if user is already signed in
    final googleUser = await googleSignIn.signInSilently();
    if (googleUser != null) {
      print('✅ User already signed in: ${googleUser.displayName}');
    } else {
      print('ℹ️  No user currently signed in');
    }

    print('✅ Google Sign-In configuration test completed');

  } catch (e, stackTrace) {
    print('❌ Error during testing: $e');
    print('Stack trace: $stackTrace');
  }
}