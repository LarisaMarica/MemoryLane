import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:licenta/firebase/auth_service.dart';
import 'package:licenta/models/task.dart';

class TaskRepository {
  final FirebaseFirestore db = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();

  Future<List<Task>> getTasks() async {
    String? uid = await _authService.getAuthenticatedUserId();
    if (uid != null) {
      QuerySnapshot snapshot =
          await db.collection('tasks').doc(uid).collection('tasks').get();
      return snapshot.docs
          .map((doc) => Task.fromFirestore(doc.data() as Map<String, dynamic>))
          .toList();
    }
    return [];
  }


  Future<void> addTask(Task task) async {
    String? uid = await _authService.getAuthenticatedUserId();
    if (uid != null) {
      await db
          .collection('tasks')
          .doc(uid)
          .collection('tasks')
          .add(task.toFirestore());
    }
  }

  Future<void> setTaskDone(Task task, DateTime selectedDate) async {
    String? uid = await _authService.getAuthenticatedUserId();
    if (uid != null) {
      await db
          .collection('tasks')
          .doc(uid)
          .collection('tasks')
          .where('title', isEqualTo: task.title)
          .get()
          .then((querySnapshot) {
        for (var doc in querySnapshot.docs) {
          doc.reference.update({
            'doneDates': {
              ...task.doneDates,
              selectedDate.toIso8601String():
                  task.doneDates[selectedDate.toIso8601String()] ?? false,
            }
          });
        }
      });
    }
  }

  Future<void> deleteTask(Task task) async {
    String? uid = await _authService.getAuthenticatedUserId();
    if (uid != null) {
      await db
          .collection('tasks')
          .doc(uid)
          .collection('tasks')
          .where('title', isEqualTo: task.title)
          .get()
          .then((querySnapshot) {
        for (var doc in querySnapshot.docs) {
          doc.reference.delete();
        }
      });
    }
  }

  Future<bool> isTitleExists(String text) async {
    String? uid = await _authService.getAuthenticatedUserId();
    if (uid != null) {
      final querySnapshot = await db
          .collection('tasks')
          .doc(uid)
          .collection('tasks')
          .where('title', isEqualTo: text)
          .get();

      return querySnapshot.docs.isNotEmpty;
    }
    return false;
  }
}
