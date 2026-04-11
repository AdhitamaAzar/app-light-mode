import 'package:flutter/material.dart';

class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("PENGATURAN"),
      ),

      // 🔥 Tambahan body (biar ada isi)
      body: const Center(
        child: Text(
          "Halaman Pengaturan",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}