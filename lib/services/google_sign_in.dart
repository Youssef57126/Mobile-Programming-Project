// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:google_sign_in/google_sign_in.dart';
//
// class AuthService {
//   Future<UserCredential?> signInWithGoogle() async {
//     try {
//       // Start Google sign-in
//       final GoogleSignInAccount? gUser = await GoogleSignIn().signIn();
//
//       if (gUser == null) {
//         // User canceled login
//         return null;
//       }
//
//       // Get auth details
//       final GoogleSignInAuthentication gAuth = await gUser.authentication;
//
//       // Create Firebase credential
//       final OAuthCredential credential = GoogleAuthProvider.credential(
//         accessToken: gAuth.accessToken,
//         idToken: gAuth.idToken,
//       );
//
//       // Sign in to Firebase
//       return await FirebaseAuth.instance.signInWithCredential(credential);
//     } catch (e) {
//       print("Google Sign-In Error: $e");
//       return null;
//     }
//   }
// }
