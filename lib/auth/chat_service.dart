import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:light_mode/model/message.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<List<Map<String, dynamic>>> getUserStream() {
    return _firestore.collection("user").snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final user = doc.data();

        return {
          ...user,
          'uid': doc.id,
        };
      }).toList();
    });
  }

  Future<String> getUsernameByUid(String uid) async {
    try {
      final doc = await _firestore.collection("user").doc(uid).get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;

        return data['username'] ??
            data['fullname'] ??
            data['name'] ??
            data['email'] ??
            'Unknown User';
      }

      return 'Unknown User';
    } catch (e) {
      return 'Unknown User';
    }
  }

  Future<void> sendMessage(String receiverID, String message) async {
    final String currentUserID = _auth.currentUser!.uid;
    final String currentUserEmail = _auth.currentUser!.email!;
    final Timestamp timestamp = Timestamp.now();

    Message newMessage = Message(
      senderID: currentUserID,
      senderEmail: currentUserEmail,
      receiverID: receiverID,
      message: message,
      timestamp: timestamp,
    );

    List<String> ids = [currentUserID, receiverID];
    ids.sort();
    String chatRoomID = ids.join("_");

    await _firestore
        .collection("chatRooms")
        .doc(chatRoomID)
        .collection("messages")
        .add(newMessage.toMap());

    // Update chatRoom doc untuk sorting di home page
    await _firestore.collection("chatRooms").doc(chatRoomID).set({
      'participants': ids,
      'lastMessageTimestamp': timestamp,
    }, SetOptions(merge: true));
  }

  Stream<QuerySnapshot> getMessages(String userID, otherUserID) {
    List<String> ids = [userID, otherUserID];
    ids.sort();
    String chatRoomID = ids.join("_");

    return _firestore
        .collection("chatRooms")
        .doc(chatRoomID)
        .collection("messages")
        .orderBy("timestamp", descending: false)
        .snapshots();
  }

  Future<void> deleteMessage(
    String otherUserID,
    String messageID,
  ) async {
    final String currentUserID = _auth.currentUser!.uid;

    List<String> ids = [currentUserID, otherUserID];
    ids.sort();
    String chatRoomID = ids.join("_");

    await _firestore
        .collection("chatRooms")
        .doc(chatRoomID)
        .collection("messages")
        .doc(messageID)
        .delete();
  }

  Future<void> deleteChatRoom(String otherUserID) async {
    final String currentUserID = _auth.currentUser!.uid;

    List<String> ids = [currentUserID, otherUserID];
    ids.sort();
    String chatRoomID = ids.join("_");

    final messagesRef = _firestore
        .collection("chatRooms")
        .doc(chatRoomID)
        .collection("messages");

    final snapshots = await messagesRef.get();
    for (final doc in snapshots.docs) {
      await doc.reference.delete();
    }

    await _firestore.collection("chatRooms").doc(chatRoomID).delete();
  }

  // Stream urutan chat berdasarkan pesan terakhir
  Stream<Map<String, Timestamp>> getChatRoomOrder() {
    final currentUserID = _auth.currentUser!.uid;

    return _firestore
        .collection("chatRooms")
        .where('participants', arrayContains: currentUserID)
        .snapshots()
        .map((snapshot) {
      Map<String, Timestamp> order = {};

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final participants = List<String>.from(data['participants'] ?? []);
        final otherUID = participants.firstWhere(
          (id) => id != currentUserID,
          orElse: () => '',
        );

        if (otherUID.isNotEmpty && data['lastMessageTimestamp'] != null) {
          order[otherUID] = data['lastMessageTimestamp'];
        }
      }

      return order;
    });
  }
}