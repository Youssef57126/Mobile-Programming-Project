// // lib/pages/auth/login_page.dart
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import '../../components/my_textfield.dart';
// import '../../components/my_button.dart';
// import '../../components/square_title.dart';
// import '../../components/show_error_msg.dart';
//
// class LoginPage extends StatefulWidget {
//   final Function()? onTap; // ← Callback to switch to SignUp page
//
//   LoginPage({super.key, this.onTap});
//
//   @override
//   State<LoginPage> createState() => _LoginPageState();
// }
//
// class _LoginPageState extends State<LoginPage> {
//   final emailController = TextEditingController();
//   final passwordController = TextEditingController();
//
//   void signUserIn() async {
//     try {
//       await FirebaseAuth.instance.signInWithEmailAndPassword(
//         email: emailController.text.trim(),
//         password: passwordController.text.trim(),
//       );
//       // Success → AuthPage stream will automatically go to MainScreen
//     } on FirebaseAuthException catch (e) {
//       sharedErrorMessage(context, e.message ?? "Login failed");
//     } catch (e) {
//       sharedErrorMessage(context, "An unknown error occurred");
//     }
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
//               mainAxisSize: MainAxisSize.min,
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 // Logo
//                 Image.asset('lib/images/login.png', width: 150, height: 150),
//
//                 Text(
//                   "Welcome back! You've been missed!",
//                   style: TextStyle(
//                     fontSize: 16,
//                     color: Color(0xFFFF9100),
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//
//                 SizedBox(height: 30),
//
//                 // Email
//                 MyTextfield(
//                   controller: emailController,
//                   hintText: "Email",
//                   obscureText: false,
//                   icon: Icon(Icons.email_outlined),
//                 ),
//
//                 // Password
//                 MyTextfield(
//                   controller: passwordController,
//                   hintText: "Password",
//                   obscureText: true,
//                   icon: Icon(Icons.lock_outline),
//                 ),
//
//                 SizedBox(height: 10),
//
//                 // Forgot Password
//                 Padding(
//                   padding: EdgeInsets.symmetric(horizontal: 20),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.end,
//                     children: [
//                       GestureDetector(
//                         onTap: () {
//                           // Add forgot password logic later
//                         },
//                         child: Text(
//                           "Forgot Password?",
//                           style: TextStyle(
//                             color: Color(0xFFFF9100),
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//
//                 SizedBox(height: 25),
//
//                 // Sign In Button
//                 MyButton(text: "Sign In", onTap: signUserIn),
//
//                 SizedBox(height: 30),
//
//                 // Or continue with
//                 Padding(
//                   padding: EdgeInsets.symmetric(horizontal: 20),
//                   child: Row(
//                     children: [
//                       Expanded(
//                         child: Divider(thickness: 1, color: Colors.grey[600]),
//                       ),
//                       Padding(
//                         padding: EdgeInsets.symmetric(horizontal: 10),
//                         child: Text(
//                           "Or continue with",
//                           style: TextStyle(color: Colors.grey[700]),
//                         ),
//                       ),
//                       Expanded(
//                         child: Divider(thickness: 1, color: Colors.grey[600]),
//                       ),
//                     ],
//                   ),
//                 ),
//
//                 SizedBox(height: 20),
//
//                 // Google Sign In
//                 SquareTitle(
//                   imagPath: 'lib/images/google_1.png',
//                   width: 40,
//                   height: 40,
//                   onTap: () => print("Google sign in clicked"),
//                 ),
//
//                 SizedBox(height: 50),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Text(
//                       "Not a member? ",
//                       style: TextStyle(color: Colors.grey[700]),
//                     ),
//                     SizedBox(width: 4),
//                     GestureDetector(
//                       onTap: widget.onTap,
//                       child: Text(
//                         'Register now',
//                         style: TextStyle(
//                           color: Colors.blue,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
