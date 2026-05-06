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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
      ),
      drawer: MyDrawer(),
      body: _buildUserList(),
    );
  }

  Widget _buildUserList() {
    return StreamBuilder(
      stream: _chatService.getUserStream(),
      builder: (context, snapshot) {
        // error
        if (snapshot.hasError) {
          return Center(
            child: Text("Error: ${snapshot.error}"),
          );
        }

        // loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        // data kosong
        if (!snapshot.hasData || snapshot.data == null) {
          return const Center(
            child: Text("Tidak ada user"),
          );
        }

        final users = snapshot.data as List;

        final filteredUsers = users.where((user) {
          return user["uid"] != _authService.getCurrentUser()!.uid;
        }).toList();

        if (filteredUsers.isEmpty) {
          return const Center(
            child: Text("Belum ada user lain"),
          );
        }

        return ListView(
          children: filteredUsers
              .map<Widget>((userData) => _buildUserListItem(userData, context))
              .toList(),
        );
      },
    );
  }

  Widget _buildUserListItem(
    Map<String, dynamic> userData,
    BuildContext context,
  ) {
    final String displayName =
        userData["username"] ?? userData["email"] ?? "Unknown User";

    return UserTile(
      text: displayName,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatPage(
              receiverEmail: userData["email"] ?? "",
              receiverID: userData["uid"],
            ),
          ),
        );
      },
    );
  }
}