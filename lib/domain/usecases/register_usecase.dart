import '../repositories/auth_repository.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import User

class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  Future<User?> execute(String email, String password) async {
    return await repository.register(email, password);
  }
}