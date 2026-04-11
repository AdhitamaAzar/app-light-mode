import 'package:flutter/material.dart';
import 'package:light_mode/auth/auth_service.dart';
import 'package:light_mode/pages/settings_page.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  void logout() {
    final _auth = AuthService();
    _auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
     backgroundColor: Theme.of(context).colorScheme.surface,
     child: Column(
      children: [
        Column(
          children: [
            DrawerHeader(
              child: Center(
                child: Icon(
                  Icons.message,
                  color: Theme.of(context).colorScheme.primary,
                  size: 40,
                )
              )
            ),
            
            // Home
            Padding(
              padding: const EdgeInsets.only(left: 25.0),
              child: ListTile(
                title: Text("Home"),
                leading: Icon(Icons.home),
                onTap: () {},
              ),
            ),

            // Settings
            Padding(
              padding: const EdgeInsets.only(left: 25.0),
              child: ListTile(
                title: Text("Settings"),
                leading: Icon(Icons.settings),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SettingPage()
                    )
                  );
                },
              ),
            ),

            // Logout
            Padding(
              padding: const EdgeInsets.only(left: 25.0),
              child: ListTile(
                title: Text("Logout"),
                leading: Icon(Icons.logout),
                onTap: logout,
              ),
            ),
          ],
        )
      ],
     ),
    );
  }
}