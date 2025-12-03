import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/anime.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection Reference
  CollectionReference _userCollection() {
    return _firestore.collection('users');
  }

  // Get favorite stream
  Stream<List<Anime>> getFavoriteStream(String userID) {
    return _userCollection()
        .doc(userID)
        .collection('favorites')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Anime.fromFavoritesJson(doc.data());
      }).toList();
    });
  }

  // Add favorites
  Future<void> addToFavorites(String userID, Anime anime) async {
    await _userCollection()
        .doc(userID)
        .collection('favorites')
        .doc(anime.malId.toString())
        .set(anime.toJson());
  }

  // Remove favorites
  Future<void> removeFromFavorites(String userID, int malId) async {
    await _userCollection()
        .doc(userID)
        .collection('favorites')
        .doc(malId.toString())
        .delete();
  }
}


