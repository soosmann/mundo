import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService with ChangeNotifier {
  // makes AuthService a singleton
  static final AuthService _instance = AuthService._internal();
  factory AuthService() {
    return _instance;
  }
  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<void> signInWithEmailAndPassword({
    required String email, 
    required String password
  }) async {
    await _auth.signInWithEmailAndPassword(
      email: email, 
      password: password
    );
  }
  
  Future<void> createUserWithEmailAndPassword({
    required String email, 
    required String password
  }) async {
    await _auth.createUserWithEmailAndPassword(
      email: email, 
      password: password
    );
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<bool> isEmailInUse(String email) async {
    try {
      List<String> signInMethods = await _auth.fetchSignInMethodsForEmail(email);
      return signInMethods.contains("password"); // usual auth method is "password"
    } catch (error) {
      throw Exception(error);
    }
  }
}
