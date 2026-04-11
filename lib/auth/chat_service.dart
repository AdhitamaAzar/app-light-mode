import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:light_mode/model/message.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<List<Map<String, dynamic>>> getUserStream() {
    return _firestore
        .collection("user")
        .snapshots()
        .map((snapshot){
          return snapshot.docs.map((doc){
            final user = doc.data();

            return user;
          }).toList();
        });
  }
   
  // mengirim pesan
  Future<void> sendMessage(String receiverID, String message) async{
    //mendapatkan info user
    final String currentUserID = _auth.currentUser!.uid;
    final String currentUserEmail = _auth.currentUser!.email!;
    final Timestamp timestamp = Timestamp.now();

    // membuat pesan baru
    Message newMessage = Message(
      senderID: currentUserID,
      senderEmail: currentUserEmail,
      receiverID: receiverID,
      message: message,
      timestamp: timestamp,
    );

    // membuat ID chat room berdasarkan ID user yang terlibat
    List<String> ids = [currentUserID, receiverID];
    ids.sort();
    String chatRoomID = ids.join("_");

    // membuat pesan baru
    await _firestore
      .collection("chatRooms")
      .doc(chatRoomID)
      .collection("messages")
      .add(newMessage.toMap());
  }

  // mendapatkan pesan
  Stream<QuerySnapshot> getMessages(String userID, otherUserID) {
    // membuat ID chat room berdasarkan ID user yang terlibat
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
}