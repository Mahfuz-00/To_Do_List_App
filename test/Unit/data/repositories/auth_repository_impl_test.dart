import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:myapp/data/repositories/auth_repository_impl.dart';
import 'package:myapp/domain/repositories/auth_repository.dart';
import 'dart:async';

// Mocks for Firebase dependencies
class MockFirebaseAuth extends Mock implements FirebaseAuth {}
class MockUserCredential extends Mock implements UserCredential {}
class MockUser extends Mock implements User {}
class MockAuthStateChanges extends Mock implements Stream<User?> {}


void main() {
  late AuthRepositoryImpl authRepository;
  late MockFirebaseAuth mockFirebaseAuth;

  setUp(() {
    mockFirebaseAuth = MockFirebaseAuth();
    // Instantiate AuthRepositoryImpl with the positional argument
    authRepository = AuthRepositoryImpl(mockFirebaseAuth);
  });

  group('AuthRepositoryImpl', () {
    final tEmail = 'test@example.com';
    final tPassword = 'password123';

    test('signIn calls firebaseAuth.signInWithEmailAndPassword', () async {
      final mockUserCredential = MockUserCredential();
      final mockUser = MockUser();

      when(mockUserCredential.user).thenReturn(mockUser);
      when(mockFirebaseAuth.signInWithEmailAndPassword(
        email: tEmail,
        password: tPassword,
      )).thenAnswer((_) async => mockUserCredential);

      final result = await authRepository.signIn(tEmail, tPassword);

      verify(mockFirebaseAuth.signInWithEmailAndPassword(
        email: tEmail,
        password: tPassword,
      )).called(1);
      expect(result, mockUser);
    });

    test('register calls firebaseAuth.createUserWithEmailAndPassword', () async {
      final mockUserCredential = MockUserCredential();
      final mockUser = MockUser();

      when(mockUserCredential.user).thenReturn(mockUser);
      when(mockFirebaseAuth.createUserWithEmailAndPassword(
        email: tEmail,
        password: tPassword,
      )).thenAnswer((_) async => mockUserCredential);

      final result = await authRepository.register(tEmail, tPassword);

      verify(mockFirebaseAuth.createUserWithEmailAndPassword(
        email: tEmail,
        password: tPassword,
      )).called(1);
      expect(result, mockUser);
    });

    test('signOut calls firebaseAuth.signOut', () async {
      when(mockFirebaseAuth.signOut()).thenAnswer((_) async => Future.value());

      await authRepository.signOut();

      verify(mockFirebaseAuth.signOut()).called(1);
    });

    test('getUser returns firebaseAuth.authStateChanges', () {
       final mockAuthStateChanges = MockAuthStateChanges();
       when(mockFirebaseAuth.authStateChanges()).thenReturn(mockAuthStateChanges as Stream<User?>);


       final result = authRepository.getUser();


       expect(result, mockAuthStateChanges);
       verify(mockFirebaseAuth.authStateChanges()).called(1);
     });

    // Add tests for error handling scenarios if your repository handles them
    test('signIn handles firebaseAuth errors', () async {
      final error = FirebaseAuthException(code: 'user-not-found', message: 'No user found for that email.');
      when(mockFirebaseAuth.signInWithEmailAndPassword(
        email: tEmail,
        password: tPassword,
      )).thenThrow(error);

      expect(() => authRepository.signIn(tEmail, tPassword), throwsA(isA<FirebaseAuthException>()));
      verify(mockFirebaseAuth.signInWithEmailAndPassword(
        email: tEmail,
        password: tPassword,
      )).called(1);
    });

     test('register handles firebaseAuth errors', () async {
       final error = FirebaseAuthException(code: 'email-already-in-use', message: 'The account already exists for that email.');
       when(mockFirebaseAuth.createUserWithEmailAndPassword(
         email: tEmail,
         password: tPassword,
       )).thenThrow(error);

       expect(() => authRepository.register(tEmail, tPassword), throwsA(isA<FirebaseAuthException>()));
       verify(mockFirebaseAuth.createUserWithEmailAndPassword(
         email: tEmail,
         password: tPassword,
       )).called(1);
     });


     test('signOut handles firebaseAuth errors', () async {
       final error = Exception('Sign out failed');
       when(mockFirebaseAuth.signOut()).thenThrow(error);

       expect(() => authRepository.signOut(), throwsA(isA<Exception>()));
       verify(mockFirebaseAuth.signOut()).called(1);
     });
  });
}