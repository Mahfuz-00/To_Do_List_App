import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:myapp/domain/entities/user.dart';
import 'package:myapp/data/repositories/auth_repository.dart'; // Assuming your AuthRepository is here
import 'package:myapp/data/repositories/auth_repository_impl.dart';
import 'package:myapp/domain/repositories/auth_repository.dart'; // Assuming your AuthRepositoryImpl is here

// Create a mock for the authentication service dependency (adjust based on your actual implementation)
class MockAuthService extends Mock implements AuthService {} // Replace AuthService with your actual service interface

void main() {
  late AuthRepository authRepository;
  late MockAuthService mockAuthService;

  setUp(() {
    mockAuthService = MockAuthService();
    authRepository = AuthRepositoryImpl(authService: mockAuthService); // Assuming AuthRepositoryImpl is your implementation
  });

  group('AuthRepository', () {
    test('signIn calls auth service signIn with correct credentials', () async {
      const email = 'test@test.com';
      const password = 'password123';

      // Mock the auth service's signIn method to return a dummy user or null
      when(mockAuthService.signInWithEmailAndPassword(email, password))
          .thenAnswer((_) async => Future.value(User(uid: 'someUserId', email: email)));

      await authRepository.signIn(email, password);

      verify(mockAuthService.signInWithEmailAndPassword(email, password)).called(1);
    });

    test('signUp calls auth service signUp with correct credentials', () async {
      const email = 'newuser@test.com';
      const password = 'newpassword';

      // Mock the auth service's signUp method
      when(mockAuthService.createUserWithEmailAndPassword(email, password))
          .thenAnswer((_) async => Future.value(User(uid: 'newUserUid', email: email)));

      await authRepository.signUp(email, password);

      verify(mockAuthService.createUserWithEmailAndPassword(email, password)).called(1);
    });

    test('signOut calls auth service signOut', () async {
      // Mock the auth service's signOut method
      when(mockAuthService.signOut()).thenAnswer((_) async => Future.value(null));

      await authRepository.signOut();

      verify(mockAuthService.signOut()).called(1);
    });

    test('getUser returns user from auth service stream', () {
      final user = User(uid: 'loggedInUser', email: 'logged@in.com');
      // Mock the auth service's user stream
      when(mockAuthService.user).thenAnswer((_) => Stream.value(user));

      expect(authRepository.getUser(), emits(user));
    });

    test('getUser returns null from auth service stream when not authenticated', () {
      // Mock the auth service's user stream to emit null
      when(mockAuthService.user).thenAnswer((_) => Stream.value(null));

      expect(authRepository.getUser(), emits(null));
    });

    // Add tests for error handling scenarios for each method
    test('signIn throws exception when auth service signIn fails', () async {
      const email = 'test@test.com';
      const password = 'password123';
      final signInError = Exception('Invalid credentials');

      when(mockAuthService.signInWithEmailAndPassword(email, password))
          .thenThrow(signInError);

      expect(() => authRepository.signIn(email, password), throwsA(signInError));
      verify(mockAuthService.signInWithEmailAndPassword(email, password)).called(1);
    });

     test('signUp throws exception when auth service signUp fails', () async {
      const email = 'newuser@test.com';
      const password = 'newpassword';
      final signUpError = Exception('Email already in use');

      when(mockAuthService.createUserWithEmailAndPassword(email, password))
          .thenThrow(signUpError);

      expect(() => authRepository.signUp(email, password), throwsA(signUpError));
      verify(mockAuthService.createUserWithEmailAndPassword(email, password)).called(1);
    });

     test('signOut throws exception when auth service signOut fails', () async {
      final signOutError = Exception('Sign out error');

      when(mockAuthService.signOut()).thenThrow(signOutError);

      expect(() => authRepository.signOut(), throwsA(signOutError));
      verify(mockAuthService.signOut()).called(1);
    });

  });
}

// Define a dummy AuthService interface or abstract class
// that mirrors the methods your AuthRepository implementation calls.
// Example:
abstract class AuthService {
  Future<User?> signInWithEmailAndPassword(String email, String password);
  Future<User?> createUserWithEmailAndPassword(String email, String password);
  Future<void> signOut();
  Stream<User?> get user;
}

// You might need to adjust the import path and class names
// based on your actual project structure and implementation.
// For example, if your AuthRepository implementation is named AuthRepositoryImpl
// and your authentication service interface is named AuthService,
// the imports and class names in the test file should match.