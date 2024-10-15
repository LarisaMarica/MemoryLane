import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:licenta/firebase/auth_service.dart';
import 'package:licenta/models/number_game_result.dart';

class NumberGameRepository {
  final FirebaseFirestore db = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();

  Future<void> addResult(NumberGameResult result) async {
    String? uid = await _authService.getAuthenticatedUserId();
    if (uid != null) {
      await db
          .collection('result')
          .doc(uid)
          .collection('number_game')
          .add(result.toFirestore());
    }
  }

  Future<List<NumberGameResult>> getResults() async {
    String? uid = await _authService.getAuthenticatedUserId();
    if (uid != null) {
      final snapshot = await db
          .collection('result')
          .doc(uid)
          .collection('number_game')
          .get();
      return snapshot.docs
          .map((doc) => NumberGameResult.fromFirestore(doc.data()))
          .toList();
    } else {
      return [];
    }
  }
}
