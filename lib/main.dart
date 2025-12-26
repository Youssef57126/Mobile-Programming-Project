import 'package:flutter/material.dart';
import 'package:mobile_project/pages/auth_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  @override
  build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: AuthPage());
  }
}

// youssefabdelmola456@gmail.com ==> 123456
// 1liferemains@gmail.com ==> 123456
// mobe89282@gmail.com ==> google sign in
