import 'package:flutter/material.dart';
import 'package:light_mode/auth/auth_gate.dart%20%20';
import 'package:light_mode/themes/light_mode.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:light_mode/pages/home_page.dart';
import 'firebase_options.dart';

void main() async {
WidgetsFlutterBinding.ensureInitialized(); await
Firebase.initializeApp( options:
DefaultFirebaseOptions.currentPlatform, );
runApp(const MyApp());}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const AuthGate(),
      theme: lightmode,

    routes: {
    '/home': (context) => HomePage(), // 🔥 WAJIB
    },
  );
  }
}
