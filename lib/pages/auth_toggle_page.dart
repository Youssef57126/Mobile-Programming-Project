// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import '../../components/my_textfield.dart';
// import '../../components/my_button.dart';
// import '../../components/square_title.dart';
// import '../../components/show_error_msg.dart';
//
// class AuthTogglePage extends StatefulWidget {
//   AuthTogglePage({super.key});
//
//   @override
//   State<AuthTogglePage> createState() => _AuthTogglePageState();
// }
//
// class _AuthTogglePageState extends State<AuthTogglePage> {
//   bool isLogin = true;
//
//   final emailController = TextEditingController();
//   final passwordController = TextEditingController();
//   final usernameController = TextEditingController();
//
//   // final GoogleSignIn _googleSignIn = GoogleSignIn();
//
//   @override
//   void dispose() {
//     emailController.dispose();
//     passwordController.dispose();
//     usernameController.dispose();
//     super.dispose();
//   }
//
//   void toggleMode() {
//     setState(() {
//       isLogin = !isLogin;
//       emailController.clear();
//       passwordController.clear();
//       usernameController.clear();
//     });
//   }
//
//   void authAction() async {
//     final email = emailController.text.trim();
//     final password = passwordController.text.trim();
//
//     if (email.isEmpty || password.isEmpty) {
//       sharedErrorMessage(context, "Please fill all fields");
//       return;
//     }
//
//     try {
//       if (isLogin) {
//         await FirebaseAuth.instance.signInWithEmailAndPassword(
//           email: email,
//           password: password,
//         );
//       } else {
//         if (usernameController.text.trim().isEmpty) {
//           sharedErrorMessage(context, "Please enter a username");
//           return;
//         }
//         await FirebaseAuth.instance.createUserWithEmailAndPassword(
//           email: email,
//           password: password,
//         );
//       }
//     } on FirebaseAuthException catch (e) {
//       sharedErrorMessage(context, e.message ?? "Authentication failed");
//     }
//   }
//
//   // Future<void> signInWithGoogle() async {
//   //   try {
//   //     final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
//   //     if (googleUser == null) return; // User canceled
//   //
//   //     final GoogleSignInAuthentication googleAuth = googleUser.authentication;
//   //
//   //     final credential = GoogleAuthProvider.credential(
//   //       idToken: googleAuth.idToken,
//   //     );
//   //
//   //     await FirebaseAuth.instance.signInWithCredential(credential);
//   //   } catch (e) {
//   //     sharedErrorMessage(context, "Google Sign In failed");
//   //   }
//   // }
//
//   void forgotPassword() {
//     showDialog(
//       context: context,
//       builder: (context) {
//         final resetController = TextEditingController();
//
//         return AlertDialog(
//           title: Text("Reset Password"),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Text("Enter your email to receive a reset link"),
//               SizedBox(height: 10),
//               MyTextfield(
//                 controller: resetController,
//                 hintText: "Email",
//                 obscureText: false,
//                 icon: Icon(Icons.email_outlined),
//               ),
//             ],
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: Text("Cancel"),
//             ),
//             MyButton(
//               text: "Send",
//               onTap: () async {
//                 try {
//                   await FirebaseAuth.instance.sendPasswordResetEmail(
//                     email: resetController.text.trim(),
//                   );
//                   Navigator.pop(context);
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(
//                       content: Text("Reset email sent! Check your inbox."),
//                     ),
//                   );
//                 } on FirebaseAuthException catch (e) {
//                   Navigator.pop(context);
//                   sharedErrorMessage(
//                     context,
//                     e.message ?? "Failed to send email",
//                   );
//                 }
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[300],
//       body: SafeArea(
//         child: Center(
//           child: SingleChildScrollView(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Image.asset(
//                   isLogin ? 'lib/images/login.png' : 'lib/images/signup.png',
//                   width: 150,
//                   height: 150,
//                 ),
//
//                 SizedBox(height: 20),
//
//                 Text(
//                   isLogin
//                       ? "Welcome back! You've been missed!"
//                       : "Let's create an account for you!",
//                   style: TextStyle(
//                     fontSize: 16,
//                     color: Color(0xFFFF9100),
//                     fontWeight: FontWeight.bold,
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//
//                 SizedBox(height: 50),
//
//                 if (!isLogin)
//                   MyTextfield(
//                     controller: usernameController,
//                     hintText: "Username",
//                     obscureText: false,
//                     icon: Icon(Icons.person),
//                   ),
//
//                 MyTextfield(
//                   controller: emailController,
//                   hintText: "Email",
//                   obscureText: false,
//                   icon: Icon(Icons.email_outlined),
//                 ),
//                 SizedBox(height: 0),
//                 // Password
//                 MyTextfield(
//                   controller: passwordController,
//                   hintText: "Password",
//                   obscureText: true,
//                   icon: Icon(Icons.lock_outline),
//                 ),
//
//                 if (isLogin)
//                   Padding(
//                     padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.end,
//                       children: [
//                         GestureDetector(
//                           onTap: forgotPassword,
//                           child: Text(
//                             "Forgot Password?",
//                             style: TextStyle(
//                               color: Color(0xFFFF9100),
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//
//                 SizedBox(height: 25),
//
//                 MyButton(
//                   text: isLogin ? "Sign In" : "Sign Up",
//                   onTap: authAction,
//                 ),
//
//                 SizedBox(height: 30),
//
//                 SquareTitle(
//                   imagPath: 'lib/images/google_1.png',
//                   width: 60,
//                   height: 60,
//                   // onTap: signInWithGoogle,
//                   onTap: () => print("Google sign in"),
//                 ),
//
//                 SizedBox(height: 50),
//
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Text(
//                       isLogin ? "Not a member? " : "Already have an account? ",
//                       style: TextStyle(color: Colors.grey[700]),
//                     ),
//                     GestureDetector(
//                       onTap: toggleMode,
//                       child: Text(
//                         isLogin ? "Register now" : "Login now",
//                         style: TextStyle(
//                           color: Colors.blue,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//
//                 SizedBox(height: 20),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
// lib/pages/auth/auth_toggle_page.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../components/my_textfield.dart';
import '../../components/my_button.dart';
import '../../components/square_title.dart';
import '../../components/show_error_msg.dart';

class AuthTogglePage extends StatefulWidget {
  AuthTogglePage({super.key});

  @override
  State<AuthTogglePage> createState() => _AuthTogglePageState();
}

class _AuthTogglePageState extends State<AuthTogglePage> {
  bool isLogin = true;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final usernameController = TextEditingController();

  // Google Sign In instance (v7.2.0: singleton)
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  @override
  void initState() {
    super.initState();
    // Initialize GoogleSignIn with your Web client ID for Android
    _googleSignIn.initialize(
      serverClientId:
          '962792463176-npe3f9a27tb9kkihgnrhakgsekoian5b.apps.googleusercontent.com',
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    usernameController.dispose();
    super.dispose();
  }

  void toggleMode() {
    setState(() {
      isLogin = !isLogin;
      emailController.clear();
      passwordController.clear();
      usernameController.clear();
    });
  }

  void authAction() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      sharedErrorMessage(context, "Please fill all fields");
      return;
    }

    try {
      if (isLogin) {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      } else {
        if (usernameController.text.trim().isEmpty) {
          sharedErrorMessage(context, "Please enter a username");
          return;
        }
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
      }
    } on FirebaseAuthException catch (e) {
      sharedErrorMessage(context, e.message ?? "Authentication failed");
    }
  }

  // Working Google Sign In (v7.2.0 API)
  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn
          .authenticate();
      if (googleUser == null) return; // User canceled

      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      sharedErrorMessage(context, "Google Sign In failed: $e");
    }
  }

  void forgotPassword() {
    showDialog(
      context: context,
      builder: (context) {
        final resetController = TextEditingController();
        return AlertDialog(
          title: Text("Reset Password"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Enter your email to receive a reset link"),
              SizedBox(height: 10),
              MyTextfield(
                controller: resetController,
                hintText: "Email",
                obscureText: false,
                icon: Icon(Icons.email_outlined),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            MyButton(
              text: "Send",
              onTap: () async {
                try {
                  await FirebaseAuth.instance.sendPasswordResetEmail(
                    email: resetController.text.trim(),
                  );
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Reset email sent! Check your inbox."),
                    ),
                  );
                } on FirebaseAuthException catch (e) {
                  Navigator.pop(context);
                  sharedErrorMessage(
                    context,
                    e.message ?? "Failed to send email",
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  isLogin ? 'lib/images/login.png' : 'lib/images/signup.png',
                  width: 150,
                  height: 150,
                ),
                SizedBox(height: 20),
                Text(
                  isLogin
                      ? "Welcome back! You've been missed!"
                      : "Let's create an account for you!",
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFFFF9100),
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 50),
                if (!isLogin)
                  MyTextfield(
                    controller: usernameController,
                    hintText: "Username",
                    obscureText: false,
                    icon: Icon(Icons.person),
                  ),
                MyTextfield(
                  controller: emailController,
                  hintText: "Email",
                  obscureText: false,
                  icon: Icon(Icons.email_outlined),
                ),
                SizedBox(height: 0),
                MyTextfield(
                  controller: passwordController,
                  hintText: "Password",
                  obscureText: true,
                  icon: Icon(Icons.lock_outline),
                ),
                if (isLogin)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: forgotPassword,
                          child: Text(
                            "Forgot Password?",
                            style: TextStyle(
                              color: Color(0xFFFF9100),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                SizedBox(height: 25),
                MyButton(
                  text: isLogin ? "Sign In" : "Sign Up",
                  onTap: authAction,
                ),
                SizedBox(height: 30),
                SquareTitle(
                  imagPath: 'lib/images/google_1.png',
                  width: 60,
                  height: 60,
                  onTap: signInWithGoogle,
                ),
                SizedBox(height: 50),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      isLogin ? "Not a member? " : "Already have an account? ",
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    GestureDetector(
                      onTap: toggleMode,
                      child: Text(
                        isLogin ? "Register now" : "Login now",
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
