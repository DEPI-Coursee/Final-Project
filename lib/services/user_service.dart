import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/UserModel.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'users';

  // Save user data to Firestore
  Future<void> saveUser(Usermodel user) async {
    try {
      final userData = user.toJson();
      await _firestore
          .collection(_collectionName)
          .doc(user.uid)
          .set(userData);
      print('User saved to Firestore: ${user.uid}');
      print('  - favoritePlaces slot: ${userData['favoritePlaces']}');
      print('  - visitedPlaces slot: ${userData['visitedPlaces']}');
    } catch (e) {
      print('Error saving user to Firestore: $e');
      rethrow;
    }
  }

  // Get user data from Firestore
  Future<Usermodel?> getUser(String uid) async {
    try {
      final doc = await _firestore.collection(_collectionName).doc(uid).get();
      if (doc.exists) {
        return Usermodel.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      print('Error getting user from Firestore: $e');
      return null;
    }
  }

  // Update user's favorite places
  Future<void> updateFavoritePlaces(String uid, List<String> favoritePlaces) async {
    try {
      await _firestore
          .collection(_collectionName)
          .doc(uid)
          .update({'favoritePlaces': favoritePlaces});
      print('Favorite places updated for user: $uid');
    } catch (e) {
      print('Error updating favorite places: $e');
      rethrow;
    }
  }

  // Update user's visited places
  Future<void> updateVisitedPlaces(String uid, List<String> visitedPlaces) async {
    try {
      await _firestore
          .collection(_collectionName)
          .doc(uid)
          .update({'visitedPlaces': visitedPlaces});
      print('Visited places updated for user: $uid');
    } catch (e) {
      print('Error updating visited places: $e');
      rethrow;
    }
  }

  // Add a place to favorites
  Future<void> addToFavorites(String uid, String placeId) async {
    try {
      final user = await getUser(uid);
      if (user != null) {
        final favorites = List<String>.from(user.favoritePlaces ?? []);
        if (!favorites.contains(placeId)) {
          favorites.add(placeId);
          await updateFavoritePlaces(uid, favorites);
        }
      }
    } catch (e) {
      print('Error adding to favorites: $e');
      rethrow;
    }
  }

  // Remove a place from favorites
  Future<void> removeFromFavorites(String uid, String placeId) async {
    try {
      final user = await getUser(uid);
      if (user != null) {
        final favorites = List<String>.from(user.favoritePlaces ?? []);
        favorites.remove(placeId);
        await updateFavoritePlaces(uid, favorites);
      }
    } catch (e) {
      print('Error removing from favorites: $e');
      rethrow;
    }
  }

  // Add a place to visit list
  Future<void> addToVisitList(String uid, String placeId) async {
    try {
      final user = await getUser(uid);
      if (user != null) {
        final visited = List<String>.from(user.visitedPlaces ?? []);
        if (!visited.contains(placeId)) {
          visited.add(placeId);
          await updateVisitedPlaces(uid, visited);
        }
      }
    } catch (e) {
      print('Error adding to visit list: $e');
      rethrow;
    }
  }

  // Remove a place from visit list
  Future<void> removeFromVisitList(String uid, String placeId) async {
    try {
      final user = await getUser(uid);
      if (user != null) {
        final visited = List<String>.from(user.visitedPlaces ?? []);
        visited.remove(placeId);
        await updateVisitedPlaces(uid, visited);
      }
    } catch (e) {
      print('Error removing from visit list: $e');
      rethrow;
    }
  }

  // Update user's current location
  Future<void> updateLocation(String uid, double lat, double lng) async {
    try {
      await _firestore
          .collection(_collectionName)
          .doc(uid)
          .update({
        'currentLat': lat,
        'currentLng': lng,
      });
    } catch (e) {
      print('Error updating location: $e');
      rethrow;
    }
  }

  // Check if visit list and favorite places slots exist
  Future<bool> checkSlotsExist(String uid) async {
    try {
      final doc = await _firestore.collection(_collectionName).doc(uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        final hasFavoritePlaces = data.containsKey('favoritePlaces');
        final hasVisitedPlaces = data.containsKey('visitedPlaces');
        
        print('\n=== SLOT VERIFICATION ===');
        print('User ID: $uid');
        print('favoritePlaces slot exists: $hasFavoritePlaces');
        print('visitedPlaces slot exists: $hasVisitedPlaces');
        if (hasFavoritePlaces) {
          print('  favoritePlaces value: ${data['favoritePlaces']}');
        }
        if (hasVisitedPlaces) {
          print('  visitedPlaces value: ${data['visitedPlaces']}');
        }
        print('========================\n');
        
        return hasFavoritePlaces && hasVisitedPlaces;
      }
      print('User document does not exist');
      return false;
    } catch (e) {
      print('Error checking slots: $e');
      return false;
    }
  }
}

