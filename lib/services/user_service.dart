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
      print('  - visitListItems slot: ${userData['visitListItems']}');
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

  // Update user's favorite places (legacy - IDs only)
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

  // Update user's favorite places with full data
  Future<void> updateFavoritePlacesData(String uid, List<Map<String, dynamic>> favoritePlacesData) async {
    try {
      await _firestore
          .collection(_collectionName)
          .doc(uid)
          .update({'favoritePlacesData': favoritePlacesData});
      print('Favorite places data updated for user: $uid');
    } catch (e) {
      print('Error updating favorite places data: $e');
      rethrow;
    }
  }

  // Update user's visit list items (legacy - IDs only)
  Future<void> updateVisitListItems(String uid, Map<String, DateTime> visitListItems) async {
    try {
      // Convert DateTime to ISO string for Firestore
      final visitListItemsJson = visitListItems.map(
        (key, value) => MapEntry(key, value.toIso8601String())
      );
      
      await _firestore
          .collection(_collectionName)
          .doc(uid)
          .update({'visitListItems': visitListItemsJson});
          // If the field visitListItems already exists → it is replaced.
      print('Visit list items updated for user: $uid');
    } catch (e) {
      print('Error updating visit list items: $e');
      rethrow;
    }
  }

  // Update user's visit list items with full data
  Future<void> updateVisitListItemsData(String uid, Map<String, Map<String, dynamic>> visitListItemsData) async {
    try {
      await _firestore
          .collection(_collectionName)
          .doc(uid)
          .update({'visitListItemsData': visitListItemsData});
      print('Visit list items data updated for user: $uid');
    } catch (e) {
      print('Error updating visit list items data: $e');
      rethrow;
    }
  }

  // Add a place to favorites (legacy - ID only)
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

  // Add a place to favorites with full data
  Future<void> addToFavoritesWithData(String uid, Map<String, dynamic> placeData) async {
    try {
      final user = await getUser(uid);
      if (user != null) {
        final placeId = placeData['placeId'] as String? ?? '';
        final favoritesData = List<Map<String, dynamic>>.from(user.favoritePlacesData ?? []);
        
        // Check if place already exists
        if (!favoritesData.any((p) => (p['placeId'] as String?) == placeId)) {
          favoritesData.add(placeData);
          await updateFavoritePlacesData(uid, favoritesData);
          
          // Also update legacy list for backward compatibility
          final favorites = List<String>.from(user.favoritePlaces ?? []);
          if (!favorites.contains(placeId)) {
            favorites.add(placeId);
            await updateFavoritePlaces(uid, favorites);
          }
        }
      }
    } catch (e) {
      print('Error adding to favorites with data: $e');
      rethrow;
    }
  }

  // Remove a place from favorites
  Future<void> removeFromFavorites(String uid, String placeId) async {
    try {
      final user = await getUser(uid);
      if (user != null) {
        // Remove from new data structure
        final favoritesData = List<Map<String, dynamic>>.from(user.favoritePlacesData ?? []);
        favoritesData.removeWhere((p) => (p['placeId'] as String?) == placeId);
        await updateFavoritePlacesData(uid, favoritesData);
        
        // Also remove from legacy list
        final favorites = List<String>.from(user.favoritePlaces ?? []);
        favorites.remove(placeId);
        await updateFavoritePlaces(uid, favorites);
      }
    } catch (e) {
      print('Error removing from favorites: $e');
      rethrow;
    }
  }

  // Add a place to visit list with date/time (legacy - ID only)
  Future<void> addToVisitListWithDateTime(String uid, String placeId, DateTime visitDateTime) async {
    try {
      final user = await getUser(uid);
      if (user != null) {
        //flow : gets the user current visitListItems -> add to it -> propogate the updated visitListItems to the database
        final visitListItems = Map<String, DateTime>.from(user.visitListItems ?? {});
        visitListItems[placeId] = visitDateTime; // Add or update
        await updateVisitListItems(uid, visitListItems);
        print('Added place $placeId to visit list with date/time: $visitDateTime');
      }
    } catch (e) {
      print('Error adding to visit list with date/time: $e');
      rethrow;
    }
  }

  // Add a place to visit list with full data and date/time
  Future<void> addToVisitListWithData(String uid, Map<String, dynamic> placeData, DateTime visitDateTime) async {
    try {
      final user = await getUser(uid);
      if (user != null) {
        final placeId = placeData['placeId'] as String? ?? '';
        final visitListItemsData = Map<String, Map<String, dynamic>>.from(user.visitListItemsData ?? {});
        
        // Store place data with visit date/time
        visitListItemsData[placeId] = {
          ...placeData,
          'visitDateTime': visitDateTime.toIso8601String(),
        };
        
        await updateVisitListItemsData(uid, visitListItemsData);
        
        // Also update legacy structure for backward compatibility
        final visitListItems = Map<String, DateTime>.from(user.visitListItems ?? {});
        visitListItems[placeId] = visitDateTime;
        await updateVisitListItems(uid, visitListItems);
        
        print('Added place $placeId to visit list with full data and date/time: $visitDateTime');
      }
    } catch (e) {
      print('Error adding to visit list with data: $e');
      rethrow;
    }
  }

  // Remove a place from visit list
  Future<void> removeFromVisitList(String uid, String placeId) async {
    try {
      final user = await getUser(uid);
      if (user != null) {
        // Remove from new data structure
        final visitListItemsData = Map<String, Map<String, dynamic>>.from(user.visitListItemsData ?? {});
        visitListItemsData.remove(placeId);
        await updateVisitListItemsData(uid, visitListItemsData);
        
        // Also remove from legacy structure
        final visitListItems = Map<String, DateTime>.from(user.visitListItems ?? {});
        visitListItems.remove(placeId);
        await updateVisitListItems(uid, visitListItems);
        print('Removed place $placeId from visit list');
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
        final hasVisitListItems = data.containsKey('visitListItems');
        
        print('\n=== SLOT VERIFICATION ===');
        print('User ID: $uid');
        print('favoritePlaces slot exists: $hasFavoritePlaces');
        print('visitListItems slot exists: $hasVisitListItems');
        if (hasFavoritePlaces) {
          print('  favoritePlaces value: ${data['favoritePlaces']}');
        }
        if (hasVisitListItems) {
          print('  visitListItems value: ${data['visitListItems']}');
        }
        print('========================\n');
        
        return hasFavoritePlaces && hasVisitListItems;
      }
      print('User document does not exist');
      return false;
    } catch (e) {
      print('Error checking slots: $e');
      return false;
    }
  }
}

