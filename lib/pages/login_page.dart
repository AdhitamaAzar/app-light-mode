import 'package:flutter/material.dart';
import 'package:light_mode/auth/auth_service.dart';
import 'package:light_mode/components/id_textfield.dart';
import 'package:light_mode/components/tombol/tombol.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key, required this.onTap});

  final TextEditingController _emailController =
      TextEditingController();

  final TextEditingController _pwControlller =
      TextEditingController();
      
        // get login => null;
        
        final void Function()? onTap;

  void login(BuildContext context) async{
    final authService = AuthService();

    try{
      await authService.signInWithEmailPassword(
        _emailController.text, 
        _pwControlller.text
      );
    }
    catch(e){
      showDialog(
        // ignore: use_build_context_synchronously
        context: context, 
        builder: (context) => AlertDialog(
          title: Text(e.toString()),
        )
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
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
              "Selamat datang kembali!",
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 25),

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

            const SizedBox(height: 30),

            Tombol(
              text: "Login", 
              onTap: () => login(context),
            ),

            const SizedBox(height: 15),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Belum memiliki akun?",
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
                ),

                GestureDetector(
                  onTap: onTap,
                  child: Text(" Silahkan mendaftar",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}