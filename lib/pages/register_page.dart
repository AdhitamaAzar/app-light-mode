import 'package:flutter/material.dart';
import 'package:light_mode/auth/auth_service.dart';
import 'package:light_mode/components/id_textfield.dart';
import 'package:light_mode/components/tombol/tombol.dart';

class RegisterPage extends StatelessWidget {
  RegisterPage({super.key, required this.onTap});

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _pwControlller = TextEditingController();
  final TextEditingController _confirmpwControlller = TextEditingController();

  final void Function()? onTap;

  void register(BuildContext context) async {
    final authService = AuthService();

    if (_usernameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _pwControlller.text.trim().isEmpty ||
        _confirmpwControlller.text.trim().isEmpty) {
      showDialog(
        context: context,
        builder: (context) => const AlertDialog(
          title: Text("Semua field wajib diisi"),
        ),
      );
      return;
    }

    if (_pwControlller.text.trim() == _confirmpwControlller.text.trim()) {
      try {
        await authService.signUpWithEmailPassword(
          _emailController.text.trim(),
          _pwControlller.text.trim(),
          _usernameController.text.trim(),
        );
      } catch (e) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(e.toString()),
          ),
        );
      }
    } else {
      showDialog(
        context: context,
        builder: (context) => const AlertDialog(
          title: Text("Password tidak sama"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.message,
                size: 60,
                color: Theme.of(context).colorScheme.primary,
              ),

              const SizedBox(height: 50),

              Text(
                "Mari kita buat akun barumu!",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 25),

              IdTextField(
                hintText: "Username",
                obscureText: false,
                controller: _usernameController,
              ),

              const SizedBox(height: 10),

              IdTextField(
                hintText: "Email",
                obscureText: false,
                controller: _emailController,
              ),

              const SizedBox(height: 10),

              IdTextField(
                hintText: "Password",
                obscureText: true,
                controller: _pwControlller,
              ),

              const SizedBox(height: 10),

              IdTextField(
                hintText: "Konfirmasi Password",
                obscureText: true,
                controller: _confirmpwControlller,
              ),

              const SizedBox(height: 30),

              Tombol(
                text: "Register",
                onTap: () => register(context),
              ),

              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Sudah memiliki akun?",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),

                  GestureDetector(
                    onTap: onTap,
                    child: Text(
                      " Silahkan Login",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}