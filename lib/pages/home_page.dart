import 'package:flutter/material.dart';
import 'package:light_mode/components/drawer.dart';
import 'package:light_mode/pages/chat_page.dart';
import 'package:light_mode/auth/auth_service.dart';
import 'package:light_mode/components/user_tile.dart';
import 'package:light_mode/auth/chat_service.dart';




class HomePage extends StatelessWidget {
    HomePage({super.key}); 

  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();

   @override 
  Widget build(BuildContext context){ 
    return Scaffold(
      appBar: AppBar(title: Text("Home"),
      ),
      drawer: MyDrawer(), 
      body: _buildUserList()
    );
  }

Widget _buildUserList() {
  return StreamBuilder(
    stream: _chatService.getUserStream(),
    builder: (context, snapshot) {

      // error
      if (snapshot.hasError) {
        return Center(child: Text("Error: ${snapshot.error}"));
      }

      // loading
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }

      // data kosong
      if (!snapshot.hasData || snapshot.data == null) {
        return const Center(child: Text("Tidak ada user"));
      }

      final users = snapshot.data as List;

      return ListView(
        children: users
            .where((user) =>
                user["uid"] != _authService.getCurrentUser()!.uid) // ❗ exclude diri sendiri
            .map<Widget>((userData) =>
                _buildUserListItem(userData, context))
            .toList(),
      );
    },
  );
}

  Widget _buildUserListItem(
    Map<String, dynamic> userData, BuildContext context){
      return UserTile(
        text: userData["email"],
        onTap: () {
          Navigator.push(
            context,
          MaterialPageRoute(
              builder: (context) => ChatPage(
                receiverEmail: userData["email"], 
                receiverID: userData["uid"],
              )
            )
          );
        }
      );
    }
}
