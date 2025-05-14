import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:myapp/domain/repositories/auth_repository.dart'; // Adjust import as needed
import 'package:myapp/domain/usecases/sign_out_usecase.dart'; // Adjust import as needed

// Create a mock AuthRepository
class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late SignOutUseCase signOutUseCase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    signOutUseCase = SignOutUseCase(mockAuthRepository);
  });

  group('SignOutUseCase', () {
    test('should call AuthRepository.signOut', () async {
      // Arrange
      when(mockAuthRepository.signOut())
          .thenAnswer((_) async => Future.value(null)); // Mock successful sign out

      // Act
      await signOutUseCase.execute();

      // Assert
      verify(mockAuthRepository.signOut()).called(1);
      verifyNoMoreInteractions(mockAuthRepository);
    });

    test('should throw an exception if the repository call fails', () async {
      // Arrange
      final exception = Exception('Sign out failed');

      // Mock the repository method to throw an exception
      when(mockAuthRepository.signOut())
          .thenThrow(exception);

      // Act & Assert
      expect(() async => signOutUseCase.execute(),
          throwsA(isA<Exception>()));

      verify(mockAuthRepository.signOut()).called(1);
      verifyNoMoreInteractions(mockAuthRepository);
    });
  });
}