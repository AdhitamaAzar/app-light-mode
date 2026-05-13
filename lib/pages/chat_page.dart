import 'package:flutter/material.dart';
import 'package:light_mode/auth/chat_service.dart';
import 'package:light_mode/auth/auth_service.dart';
import 'package:light_mode/components/chat_bubbles.dart';
import 'package:light_mode/components/id_textfield.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatPage extends StatelessWidget {
  final String receiverUsername;
  final String receiverID;

  ChatPage({
    super.key,
    required this.receiverUsername,
    required this.receiverID,
  });

  final TextEditingController _messageController = TextEditingController();

  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();

  void sendMessage() async {
    if (_messageController.text.trim().isNotEmpty) {
      await _chatService.sendMessage(
        receiverID,
        _messageController.text.trim(),
      );
      _messageController.clear();
    }
  }

  void _confirmDeleteChat(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Hapus Percakapan"),
        content: Text(
          "Hapus semua pesan dengan $receiverUsername? Tindakan ini tidak bisa dibatalkan.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await _chatService.deleteChatRoom(receiverID);
              if (context.mounted) Navigator.pop(context);
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

  void _confirmDeleteMessage(BuildContext context, String messageID) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Hapus Pesan"),
        content: const Text("Hapus pesan ini?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await _chatService.deleteMessage(receiverID, messageID);
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
        title: Text(receiverUsername),
        actions: [
          IconButton(
            tooltip: "Hapus Percakapan",
            icon: const Icon(Icons.delete_sweep),
            onPressed: () => _confirmDeleteChat(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _buildMessageList(context),
          ),
          _buildUserInput(),
        ],
      ),
    );
  }

  Widget _buildMessageList(BuildContext context) {
    String senderID = _authService.getCurrentUser()!.uid;

    return StreamBuilder(
      stream: _chatService.getMessages(senderID, receiverID),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(
            child: Text("Error"),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Text("Loading..."),
          );
        }

        return ListView(
          children: snapshot.data!.docs
              .map((doc) => _buildMessageItem(context, doc))
              .toList(),
        );
      },
    );
  }

  Widget _buildMessageItem(BuildContext context, DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    bool isCurrentUser =
        data['senderID'] == _authService.getCurrentUser()!.uid;

    var alignment =
        isCurrentUser ? Alignment.centerRight : Alignment.centerLeft;

    return GestureDetector(
      onLongPress: isCurrentUser
          ? () => _confirmDeleteMessage(context, doc.id)
          : null,
      child: Container(
        alignment: alignment,
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment:
              isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            ChatBubble(
              message: data['message'] ?? "",
              isCurrentUser: isCurrentUser,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInput() {
    return Row(
      children: [
        Expanded(
          child: IdTextField(
            obscureText: false,
            controller: _messageController,
            hintText: "Ketikkan pesan...",
          ),
        ),
        IconButton(
          onPressed: sendMessage,
          icon: const Icon(Icons.arrow_upward),
        ),
      ],
    );
  }
}