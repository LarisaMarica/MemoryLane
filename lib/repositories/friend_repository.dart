import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:licenta/firebase/auth_service.dart';
import 'package:licenta/firebase/utils.dart';
import 'package:licenta/models/friend.dart';

class FriendRepository{
  final db = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();

  Future<void> addFriend(Friend friend) async {
    String? uid = await _authService.getAuthenticatedUserId();
    if (uid != null) {
      await db
          .collection('friends')
          .doc(uid)
          .collection('person')
          .add(friend.toFirestore());
    }
  }

  Future<void> deleteFriend(String friendId) async{
    String? uid = await _authService.getAuthenticatedUserId();
    if(uid != null){
      var path = await db
          .collection('friends')
          .doc(uid)
          .collection('person')
          .doc(friendId)
          .get()
          .then((doc) => doc.data()?['imageURL']);
      await db
          .collection('friends')
          .doc(uid)
          .collection('person')
          .doc(friendId)
          .delete();
      await deleteImageByPath(path);
    }
  }

  Future<List<Friend>> getFriends() async {
    String? uid = await _authService.getAuthenticatedUserId();
    if (uid != null) {
      final snapshot =
          await db.collection('friends').doc(uid).collection('person').get();
      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.map((doc) {
          final friend = Friend.fromFirestore(doc.data());
          friend.id = doc.id;
          return friend;
        }).toList();
      }
    }
    return [];
  }
}