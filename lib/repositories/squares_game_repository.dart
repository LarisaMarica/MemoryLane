import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:licenta/firebase/auth_service.dart';
import 'package:licenta/models/squares_game_result.dart';

class SquaresGameRepository {
  final FirebaseFirestore db = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();

  Future<void> addResult(SquaresGameResult result) async {
    String? uid = await _authService.getAuthenticatedUserId();
    if (uid != null) {
      await db
          .collection('result')
          .doc(uid)
          .collection('squares_game')
          .add(result.toFirestore());
    }
  }

  Future<List<SquaresGameResult>> getResults() async {
    String? uid = await _authService.getAuthenticatedUserId();
    if (uid != null) {
      final snapshot = await db
          .collection('result')
          .doc(uid)
          .collection('squares_game')
          .get();
      return snapshot.docs
          .map((doc) => SquaresGameResult.fromFirestore(doc.data()))
          .toList();
    } else {
      return [];
    }
  }
}
