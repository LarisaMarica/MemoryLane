import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  static const String _userIdKey = 'authenticatedUserId';

  Future<void> storeAuthenticatedUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userIdKey);
    await prefs.setString(_userIdKey, userId);
  }

  Future<void> removeAuthenticatedUserId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userIdKey);
  }

  Future<String?> getCurrentEmail() async {
    User? user = await getCurrentUser();
    if (user != null) {
      return user.email;
    }
    return null;
  }

  Future<String?> getAuthenticatedUserId() async {
    User? user = await getCurrentUser();
    if (user != null) {
      return user.uid;
    }
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey);
  }

  Future<bool> authenticateUser(String userId) async {
    var logger = Logger();
    try {
      User? user = await getCurrentUser();
      if (user != null && user.uid == userId) {
        return true;
      }
      return false;
    } catch (e) {
      logger.e(e);
      return false;
    }
  }

  Future<User?> getCurrentUser() async {
    var logger = Logger();
    try {
      return _auth.currentUser;
    } catch (e) {
      logger.e(e);
      return null;
    }
  }

  Stream<User?> get user {
    return _auth.authStateChanges().map((firebaseUser) => firebaseUser);
  }

  Future<User?> signInWithEmailPassword(
      String email, String password) async {
    var logger = Logger();
    try {
      UserCredential result = await _auth
          .signInWithEmailAndPassword(email: email, password: password);
      User? user = result.user;
      storeAuthenticatedUserId(user!.uid);
      return user;
    } catch (e) {
      logger.e(e);
      return null;
    }
  }

  Future<User?> registerWithEmailPassword(
      String email, String password) async {
    signOut();
    var logger = Logger();
    try {
      UserCredential result = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      User? user = result.user;
      storeAuthenticatedUserId(user!.uid);
      return user;
    } catch (e) {
      logger.e(e);
      return null;
    }
  }

  Future<bool> isEmailInUse(String email) async {
    var logger = Logger();
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: 'password');
      await result.user!.delete();
      return false;
    } catch (e) {
      logger.e(e);
      return true;
    }
  }

  Future<void> signOut() async {
    var logger = Logger();
    try {
      await _auth.signOut();
    } catch (e) {
      logger.e(e);
    }
  }
}
