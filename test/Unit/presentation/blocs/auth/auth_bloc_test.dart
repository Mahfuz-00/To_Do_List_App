import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:myapp/domain/repositories/auth_repository.dart';
import 'package:myapp/presentation/blocs/auth/auth_bloc.dart';
import 'package:myapp/presentation/blocs/auth/auth_event.dart';
import 'package:myapp/presentation/blocs/auth/auth_state.dart';

// Create a mock AuthRepository
class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
  });

  group('AuthBloc', () {
    test('initial state is AuthInitial', () {
      expect(AuthBloc(authRepository: mockAuthRepository).state, AuthInitial());
    });

    blocTest<
        AuthBloc, AuthState>(
      'emits [Authenticated] when successful SignInRequested',
      build: () {
        when(mockAuthRepository.signIn(any, any))
            .thenAnswer((_) async => Future.value(null)); // Mock successful sign in
        return AuthBloc(authRepository: mockAuthRepository);
      },
      act: (bloc) => bloc.add(SignInRequested(email: 'test@test.com', password: 'password')),
      expect: () => [Authenticated()], // Assuming Authenticated state is emitted after successful sign in
    );

    blocTest<
        AuthBloc, AuthState>(
      'emits [Unauthenticated] when SignInRequested fails',
      build: () {
        when(mockAuthRepository.signIn(any, any))
            .thenThrow(Exception('Sign in failed')); // Mock failed sign in
        return AuthBloc(authRepository: mockAuthRepository);
      },
      act: (bloc) => bloc.add(SignInRequested(email: 'test@test.com', password: 'password')),
      expect: () => [Unauthenticated()], // Assuming Unauthenticated state is emitted after failed sign in
    );

    blocTest<
        AuthBloc, AuthState>(
      'emits [Unauthenticated] when LogoutRequested',
      build: () {
        when(mockAuthRepository.signOut())
            .thenAnswer((_) async => Future.value(null)); // Mock successful sign out
        return AuthBloc(authRepository: mockAuthRepository);
      },
      act: (bloc) => bloc.add(LogoutRequested()),
      expect: () => [Unauthenticated()], // Assuming Unauthenticated state is emitted after logout
    );

    // Add more tests for RegisterRequested and other scenarios
  });
}