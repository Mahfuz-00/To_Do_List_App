import 'package:firebase_auth/firebase_auth.dart';
import 'package:myapp/domain/repositories/auth_repository.dart' as domain;

class AuthRepositoryImpl implements domain.AuthRepository {
  final FirebaseAuth _firebaseAuth;
  
  AuthRepositoryImpl({FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  Future<User?> signIn(String email, String password) async {
    try {
      final UserCredential userCredential =
          await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      print('Error signing in: $e');
      rethrow;
    }
  }

  Future<User?> register(String email, String password) async {
    try {
      final UserCredential userCredential =
          await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      print('Error registering: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      print('Error signing out: $e');
      rethrow;
    }
  }
}