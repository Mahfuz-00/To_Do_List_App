import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:myapp/domain/repositories/auth_repository.dart';
import 'package:myapp/domain/usecases/sign_in_usecase.dart';

// Create a mock AuthRepository
class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late SignInUseCase signInUseCase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    signInUseCase = SignInUseCase(mockAuthRepository);
  });

  group('SignInUseCase', () {
    const testEmail = 'test@example.com';
    const testPassword = 'password123';

    test('should call AuthRepository.signIn with the correct email and password', () async {
      // Arrange
      when(mockAuthRepository.signIn(testEmail, testPassword))
          .thenAnswer((_) async => Future.value(null)); // Simulate successful sign in

      // Act
      await signInUseCase.execute(testEmail, testPassword);

      // Assert
      verify(mockAuthRepository.signIn(testEmail, testPassword)).called(1);
    });

    test('should throw an exception if AuthRepository.signIn throws an exception', () async {
      // Arrange
      final signInError = Exception('Invalid credentials');

      when(mockAuthRepository.signIn(testEmail, testPassword))
          .thenThrow(signInError);

      // Act & Assert
      expect(() async => signInUseCase.execute(testEmail, testPassword),
          throwsA(equals(signInError)));

      verify(mockAuthRepository.signIn(testEmail, testPassword)).called(1);
    });
  });
}