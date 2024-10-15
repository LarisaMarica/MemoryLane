import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:licenta/firebase/auth_service.dart';
import 'package:licenta/firebase/utils.dart';
import 'package:licenta/models/family.dart';


class FamilyRepository {
  final db = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();

  Future<void> addFamilyMember(Family family) async {
    String? uid = await _authService.getAuthenticatedUserId();
    if (uid != null) {
      await db
          .collection('family')
          .doc(uid)
          .collection('member')
          .add(family.toFirestore());
    }
  }

  Future<void> deleteFamilyMember(String familyMemberId) async {
    String? uid = await _authService.getAuthenticatedUserId();
    if (uid != null) {
      var path = await db
          .collection('family')
          .doc(uid)
          .collection('member')
          .doc(familyMemberId)
          .get()
          .then((doc) => doc.data()?['imageURL']);

      await db
          .collection('family')
          .doc(uid)
          .collection('member')
          .doc(familyMemberId)
          .delete();

       await deleteImageByPath(path);
    }
  }

  Future<List<Family>> getFamilyMembers() async {
    String? uid = await _authService.getAuthenticatedUserId();
    if (uid != null) {
      final snapshot =
          await db.collection('family').doc(uid).collection('member').get();
      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.map((doc) {
          final family = Family.fromFirestore(doc.data());
          family.id = doc.id; 
          return family;
        }).toList();
      }
    }
    return [];
  }
}

