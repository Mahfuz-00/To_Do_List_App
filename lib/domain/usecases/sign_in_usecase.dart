import '../repositories/auth_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignInUseCase {
  final AuthRepository repository;

  SignInUseCase(this.repository);

  Future<User?> execute(String email, String password) async {
    return await repository.signIn(email, password);
  }
}