import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Fungsi register/sign-up
  Future<UserCredential> signUpWithEmailPassword(
    String email,
    String password,
    String username,
  ) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _firestore.collection("user").doc(userCredential.user!.uid).set({
        "uid": userCredential.user!.uid,
        "email": email,
        "username": username,
        "createdAt": FieldValue.serverTimestamp(),
      });

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? e.code);
    }
  }

  // Fungsi login/sign-in
  Future<UserCredential> signInWithEmailPassword(
    String email,
    String password,
  ) async {
    try {
      UserCredential userCredential =
          await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Jangan timpa username saat login
      await _firestore.collection("user").doc(userCredential.user!.uid).set({
        "uid": userCredential.user!.uid,
        "email": email,
        "lastLogin": FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? e.code);
    }
  }

  // Fungsi hapus akun
  Future<void> deleteAccount() async {
    try {
      final User? user = _auth.currentUser;

      if (user == null) {
        throw Exception("User tidak ditemukan");
      }

      final String uid = user.uid;

      // Hapus data user di Firestore
      await _firestore.collection("user").doc(uid).delete();

      // Hapus akun dari Firebase Authentication
      await user.delete();
    } on FirebaseAuthException catch (e) {
      if (e.code == "requires-recent-login") {
        throw Exception(
          "Untuk menghapus akun, silakan logout lalu login kembali terlebih dahulu.",
        );
      } else {
        throw Exception(e.message ?? e.code);
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // Fungsi logout/sign-out
  Future<void> signOut() async {
    return await _auth.signOut();
  }
}