import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:tour_guide/models/UserModel.dart';
class Authservice {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<Usermodel?> signUp(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      User? user = result.user;

      Usermodel newUser = Usermodel(
        uid: user!.uid,
        email: email,
        password: password,
      );

      return newUser;
    } catch (e) {
      print('Error in sign up: $e');
      return null;
    }
  }

}