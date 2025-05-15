import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:myapp/domain/repositories/auth_repository.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:myapp/domain/usecases/register_usecase.dart'; // Alias for Firebase Auth User for clarity

// Create a mock for AuthRepository
class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late RegisterUseCase registerUseCase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    registerUseCase = RegisterUseCase(mockAuthRepository);
  });

  group('RegisterUseCase', () {
    const email = 'test@test.com';
    const password = 'password123';

    test('should call AuthRepository.register with correct email and password', () async {
      // Arrange
      final mockFirebaseUser = MockFirebaseUser(); // Assuming MockFirebaseUser exists from other tests or needs to be defined
      when(mockFirebaseUser.uid).thenReturn('someUserId'); // Mock a property if needed

      // Mock AuthRepository.register to return a Future with a mock Firebase User
      when(mockAuthRepository.register(email, password)) // Corrected from signUp to register
          .thenAnswer((_) async => mockFirebaseUser); // Simulate successful registration

      // Act
      registerUseCase;

      // Assert
      // Verify that AuthRepository.register was called with the correct arguments
      verify(mockAuthRepository.register(email, password)).called(1); // Corrected from signUp to register
      verifyNoMoreInteractions(mockAuthRepository);
    });

    test('should rethrow exceptions from AuthRepository.register', () async {
      // Arrange
      final exception = Exception('Registration failed');

      // Mock AuthRepository.register to throw an exception
      when(mockAuthRepository.register(email, password)) // Corrected from signUp to register
          .thenThrow(exception);

      // Act & Assert
      // Expect the RegisterUseCase to throw the same exception
      expect(() => registerUseCase, throwsA(exception));

      // Assert that AuthRepository.register was still called
      verify(mockAuthRepository.register(email, password)).called(1); // Corrected from signUp to register
      verifyNoMoreInteractions(mockAuthRepository);
    });

    // Define MockFirebaseUser if it's not defined elsewhere and needed for this test file
    // class MockFirebaseUser extends Mock implements firebase_auth.User {}
  });
}

// Define MockFirebaseUser here if it's specific to this test file and not in a shared mock file
class MockFirebaseUser extends Mock implements firebase_auth.User {}