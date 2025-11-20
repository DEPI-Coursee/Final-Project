import 'package:firebase_auth/firebase_auth.dart';
import 'package:tour_guide/models/UserModel.dart';
import 'package:tour_guide/services/user_service.dart';

class Authservice {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserService _userService = UserService();

  Future<Usermodel?> signUp(String name, String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      User? user = result.user;

      if (user == null) {
        print('Error: User is null after sign up');
        return null;
      }

      Usermodel newUser = Usermodel(
        uid: user.uid,
        fullName: name,
        email: email,
        password: password,
        // Initialize empty lists for favoritePlaces and visitedPlaces
        favoritePlaces: [],
        visitedPlaces: [],
      );

      // Save user data to Firestore with empty lists
      try {
        await _userService.saveUser(newUser);
        print('User successfully saved to Firestore');
        // Verify slots were saved
        await _userService.checkSlotsExist(newUser.uid);
      } catch (firestoreError) {
        // If Firestore save fails, log it but don't fail the entire signup
        // The user is already created in Firebase Auth
        print('Warning: Failed to save user to Firestore: $firestoreError');
        // You might want to retry saving later or handle this differently
      }

      return newUser;
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth Error in sign up: ${e.code} - ${e.message}');
      rethrow; // Re-throw to let the controller handle it
    } catch (e) {
      print('Error in sign up: $e');
      rethrow; // Re-throw to let the controller handle it
    }
  }
  Future<bool> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password); //stores token in local phone
      return true;
    } catch (e) {
      print('Error in sign up: $e');
      return false;
    }
  }
  Future<bool> signOut() async {
    try {
      await _auth.signOut(); //htshel el token from local phone
      return true;
    } catch (e) {
      print('Error in sign out: $e');
      return false;
    }
  }
  bool isLoggedIn() => _auth.currentUser != null;

  Future<bool> resetPassword(email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return true;
    } catch (e) {
      print('Error in resetPassword: $e');
      return false;
    }
  }
  String? getCurrentUserId() {
    return _auth.currentUser?.uid;
  }
  Future<Usermodel?> getCurrentUser() async {
    final userid = getCurrentUserId();
    if (userid == null) {
      return null;
    }
    return await _userService.getUser(userid);
  }
}

