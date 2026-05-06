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

  void deleteAccount(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Hapus Akun"),
        content: const Text(
          "Apakah kamu yakin ingin menghapus akun ini? Data akun akan hilang permanen.",
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
            },
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);

              try {
                await _authService.deleteAccount();

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Akun berhasil dihapus"),
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text("Gagal hapus akun"),
                      content: Text(e.toString()),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("OK"),
                        ),
                      ],
                    ),
                  );
                }
              }
            },
            child: const Text(
              "Hapus",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
        actions: [
          IconButton(
            tooltip: "Hapus Akun",
            onPressed: () => deleteAccount(context),
            icon: const Icon(Icons.delete_forever),
          ),
        ],
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