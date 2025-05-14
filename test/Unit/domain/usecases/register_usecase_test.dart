import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:myapp/domain/repositories/auth_repository.dart';
import 'package:myapp/domain/usecases/register_usecase.dart';

// Create a mock AuthRepository
class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late RegisterUseCase registerUseCase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    registerUseCase = RegisterUseCase(mockAuthRepository);
  });

  group('RegisterUseCase', () {
    const email = 'test@example.com';
    const password = 'password123';

    test('should call AuthRepository.signUp with correct email and password', () async {
      // Arrange
      when(mockAuthRepository.signUp(email, password))
          .thenAnswer((_) async => Future.value(null)); // Simulate successful registration

      // Act
      await registerUseCase.execute(email, password);

      // Assert
      verify(mockAuthRepository.signUp(email, password)).called(1);
    });

    test('should throw an exception if AuthRepository.signUp throws an exception', () async {
      // Arrange
      final registerError = Exception('Registration failed');
      when(mockAuthRepository.signUp(email, password))
          .thenThrow(registerError);

      // Act & Assert
      expect(() => registerUseCase.execute(email, password), throwsA(registerError));

      verify(mockAuthRepository.signUp(email, password)).called(1);
    });
  });
}