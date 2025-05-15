import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

abstract class AuthRepository {
  Future<User?> signIn(String email, String password);
  Future<User?> register(String email, String password);
  Future<void> signOut();
  Stream<firebase_auth.User?> getUser();
}