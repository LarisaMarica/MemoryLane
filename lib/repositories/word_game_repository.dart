import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:licenta/firebase/auth_service.dart';
import 'package:licenta/models/word_game_result.dart';

class WordGameRepository {
  final FirebaseFirestore db = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();

  Future<void> addResult(WordGameResult result) async {
    String? uid = await _authService.getAuthenticatedUserId();
    if (uid != null) {
      await db
          .collection('result')
          .doc(uid)
          .collection('word_game')
          .add(result.toFirestore());
    }
  }

  Future<List<WordGameResult>> getResults() async {
    String? uid = await _authService.getAuthenticatedUserId();
    if (uid != null) {
      final snapshot =
          await db.collection('result').doc(uid).collection('word_game').get();
      return snapshot.docs
          .map((doc) => WordGameResult.fromFirestore(doc.data()))
          .toList();
    } else {
      return [];
    }
  }
}
