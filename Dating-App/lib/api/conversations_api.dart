import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:dating_app/constants/constants.dart';
import 'package:dating_app/models/user_model.dart';

class ConversationsApi {
  /// Get firestore instance
  ///
  final _firestore = FirebaseFirestore.instance;

  /// Save last conversation in database
  Future<void> saveConversation({
    required String type,
    required String senderId,
    required String receiverId,
    required String userPhotoLink,
    required String userFullName,
    required String textMsg,
    required bool isRead,
  }) async {
    await _firestore
        .collection(C_CONNECTIONS)
        .doc(senderId)
        .collection(C_CONVERSATIONS)
        .doc(receiverId)
        .set(<String, dynamic>{
      USER_ID: receiverId,
      USER_PROFILE_PHOTO: userPhotoLink,
      USER_FULLNAME: userFullName,
      MESSAGE_TYPE: type,
      LAST_MESSAGE: textMsg,
      MESSAGE_READ: isRead,
      TIMESTAMP: FieldValue.serverTimestamp(),
    }).then((value) {
      debugPrint('saveConversation() -> succes');
    }).catchError((e) {
      debugPrint('saveConversation() -> error: $e');
    });
  }

  /// Get stream conversations for current user
  Stream<QuerySnapshot<Map<String, dynamic>>> getConversations() {
    return _firestore
        .collection(C_CONNECTIONS)
        .doc(UserModel().user.userId)
        .collection(C_CONVERSATIONS)
        .orderBy(TIMESTAMP, descending: true)
        .snapshots();
    // return _firestore
    //     .collection(C_CONNECTIONS)
    //     .doc('1Ry7n0KrysW3Tb3b3v0z4kuENbQ2')
    //     .collection(C_CONVERSATIONS)
    //     .orderBy(TIMESTAMP, descending: true)
    //     .snapshots();
  }

  /// Delete current user conversation
  Future<void> deleteConverce(String withUserId,
      {bool isDoubleDel = false}) async {
    // For current user
    await _firestore
        .collection(C_CONNECTIONS)
        .doc(UserModel().user.userId)
        .collection(C_CONVERSATIONS)
        .doc(withUserId)
        .delete();
    // Delete the current user id from onother user conversation list
    if (isDoubleDel) {
      await _firestore
          .collection(C_CONNECTIONS)
          .doc(withUserId)
          .collection(C_CONVERSATIONS)
          .doc(UserModel().user.userId)
          .delete();
    }
  }
}
