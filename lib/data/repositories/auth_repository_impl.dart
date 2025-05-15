import 'package:firebase_auth/firebase_auth.dart';
import 'package:myapp/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _firebaseAuth;

  AuthRepositoryImpl(this._firebaseAuth);

  @override
  Future<User?> signIn(String email, String password) async {
    try {
      final result = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      // Handle specific FirebaseAuthExceptions here (e.g., invalid-email, user-not-found, wrong-password)
      rethrow; // Rethrow the exception after handling if necessary
    } catch (e) {
      // Handle other potential errors
      print('Error signing in: $e'); // Example: print error
      rethrow;
    }
  }

  @override
  Future<User?> register(String email, String password) async {
    try {
      final result = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      // Handle specific FirebaseAuthExceptions here
      rethrow; // Rethrow the exception after handling if necessary
    } catch (e) {
      // Handle other potential errors
      print('Error registering: $e'); // Example: print error
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      print('Error signing out: $e');
      rethrow;
    }
  }

  @override
  Stream<User?> getUser() {
    try {
      return _firebaseAuth.authStateChanges();
    } catch (e) {
      print('Error get user: $e');
      rethrow;
    }
  }
}
