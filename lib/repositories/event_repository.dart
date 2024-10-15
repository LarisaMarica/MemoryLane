import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:licenta/firebase/auth_service.dart';
import 'package:licenta/models/event.dart';

class EventsRepository {
  final db = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();

  Future<List<Event>> getEvents() async {
    String? uid = await _authService.getAuthenticatedUserId();
    if (uid != null) {
      QuerySnapshot querySnapshot =
          await db.collection('events').doc(uid).collection('events').get();
      return querySnapshot.docs
          .map((doc) => Event.fromFirestore(doc.data() as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  Future<void> addEvent(Event event) async {
    String? uid = await _authService.getAuthenticatedUserId();
    if (uid != null) {
      await db
          .collection('events')
          .doc(uid)
          .collection('events')
          .add(event.toFirestore());
    }
  }

  Future<void> updateEvent(Event oldEvent, Event newEvent) async {
    String? uid = await _authService.getAuthenticatedUserId();
    if (uid != null) {
      await db
          .collection('events')
          .doc(uid)
          .collection('events')
          .where('title', isEqualTo: oldEvent.title)
          .get()
          .then((querySnapshot) {
        for (var doc in querySnapshot.docs) {
          doc.reference.delete(); 
          db
              .collection('events')
              .doc(uid)
              .collection('events')
              .add(newEvent.toFirestore());
        }
      });
    }
  }


  Future<void> deleteEvent(Event event) async {
    String? uid = await _authService.getAuthenticatedUserId();
    if (uid != null) {
      await db
          .collection('events')
          .doc(uid)
          .collection('events')
          .where('title', isEqualTo: event.title) 
          .get()
          .then((querySnapshot) {
        for (var doc in querySnapshot.docs) {
          doc.reference.delete();
        }
      });
    }
  }
}
