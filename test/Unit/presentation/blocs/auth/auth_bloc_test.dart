import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:myapp/domain/usecases/sign_in_usecase.dart';
import 'package:myapp/domain/usecases/register_usecase.dart';
import 'package:myapp/domain/usecases/sign_out_usecase.dart';
import 'package:myapp/presentation/blocs/auth/auth_bloc.dart';
import 'package:myapp/presentation/blocs/auth/auth_event.dart';
import 'package:myapp/presentation/blocs/auth/auth_state.dart';

// Alias for Firebase Auth User for clarity
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

// Needed for mocking Firebase User
import 'package:firebase_auth/firebase_auth.dart';

// Create a mock Firebase User
class MockFirebaseUser extends Mock implements firebase_auth.User {}
// Note: If your AuthBloc uses a domain-specific User entity,
// you might need a mock for that instead.
// Create mocks for Use Cases
class MockSignInUseCase extends Mock implements SignInUseCase {} // Added missing import implicitly
class MockRegisterUseCase extends Mock implements RegisterUseCase {}
class MockSignOutUseCase extends Mock implements SignOutUseCase {}

void main() {
  late AuthBloc authBloc;
  late MockSignInUseCase mockSignInUseCase;
  late MockRegisterUseCase mockRegisterUseCase;
  late MockSignOutUseCase mockSignOutUseCase;

  setUp(() {
    mockSignInUseCase = MockSignInUseCase();
    mockRegisterUseCase = MockRegisterUseCase();
    mockSignOutUseCase = MockSignOutUseCase();
    authBloc = AuthBloc(
      signInUseCase: mockSignInUseCase,
      registerUseCase: mockRegisterUseCase,
      signOutUseCase: mockSignOutUseCase,
    );
  });

  tearDown(() {
    authBloc.close();
  });

  group('AuthBloc', () {
    const email = 'test@example.com';
    const password = 'password123';
    final mockUser = MockFirebaseUser();
    final signInError = Exception('Sign in failed');
    final registerError = Exception('Registration failed');
    final signOutError = Exception('Sign out failed');

    test('initial state is AuthInitial', () {
      expect(authBloc.state, AuthInitial());
    });

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, Authenticated] when LoginRequested is added and sign in is successful',
      build: () {
        when(mockUser.uid).thenReturn('testUserId');
        when(mockSignInUseCase.execute(email, password)).thenAnswer((_) async => mockUser);
        return authBloc;
      },
      act: (bloc) => bloc.add(LoginRequested(email: email, password: password)),
      expect: () => [
        AuthLoading(),
        Authenticated(user: mockUser), // Expect Authenticated with the mock user
      ],
      verify: (_) {
        verify(mockSignInUseCase.execute(email, password)).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, Unauthenticated] when LoginRequested is added and sign in fails (user is null)',
      build: () {
        when(mockSignInUseCase.execute(email, password)).thenAnswer((_) async => null); // Simulate null user on failure
        return authBloc;
      },
      act: (bloc) => bloc.add(LoginRequested(email: email, password: password)),
      expect: () => [
        AuthLoading(),
        Unauthenticated(), // Expect Unauthenticated state when user is null
      ],
      verify: (_) {
        verify(mockSignInUseCase.execute(email, password)).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] when LoginRequested is added and sign in throws an exception',
      build: () {
        when(mockSignInUseCase.execute(email, password)).thenThrow(signInError);
        return authBloc;
      },
      act: (bloc) => bloc.add(LoginRequested(email: email, password: password)),
      expect: () => [
        AuthLoading(),
        AuthError(signInError.toString()), // Expect AuthError state with the error message
      ],
      verify: (_) {
        verify(mockSignInUseCase.execute(email, password)).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, Authenticated] when RegisterRequested is added and registration is successful',
      build: () {
        when(mockUser.uid).thenReturn('newUserId');
        when(mockRegisterUseCase.execute(email, password)).thenAnswer((_) async => mockUser);
        return authBloc;
      },
      act: (bloc) => bloc.add(RegisterRequested(email: email, password: password)),
      expect: () => [
        AuthLoading(),
        Authenticated(user: mockUser), // Expect Authenticated with the mock user
      ],
      verify: (_) {
        verify(mockRegisterUseCase.execute(email, password)).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, Unauthenticated] when RegisterRequested is added and registration fails (user is null)',
      build: () {
        when(mockRegisterUseCase.execute(email, password)).thenAnswer((_) async => null); // Simulate null user on failure
        return authBloc;
      },
      act: (bloc) => bloc.add(RegisterRequested(email: email, password: password)),
      expect: () => [
        AuthLoading(),
        Unauthenticated(), // Expect Unauthenticated state when user is null
      ],
      verify: (_) {
        verify(mockRegisterUseCase.execute(email, password)).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] when RegisterRequested is added and registration throws an exception',
      build: () {
        when(mockRegisterUseCase.execute(email, password)).thenThrow(registerError);
        return authBloc;
      },
      act: (bloc) => bloc.add(RegisterRequested(email:email, password: password)),
      expect: () => [
        AuthLoading(),
        AuthError(registerError.toString()), // Expect AuthError state with the error message
      ],
      verify: (_) {
        verify(mockRegisterUseCase.execute(email, password)).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, Unauthenticated] when LogoutRequested is added and sign out is successful',
      build: () {
        when(mockSignOutUseCase.execute()).thenAnswer((_) async => Future.value(null));
        return authBloc;
      },
      act: (bloc) => bloc.add(LogoutRequested()),
      expect: () => [
        AuthLoading(),
        Unauthenticated(), // Expect Unauthenticated state after successful logout
      ],
      verify: (_) {
        verify(mockSignOutUseCase.execute()).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] when LogoutRequested is added and sign out fails',
      build: () {
        when(mockSignOutUseCase.execute()).thenThrow(signOutError);
        return authBloc;
      },
      act: (bloc) => bloc.add(LogoutRequested()),
      expect: () => [
        AuthLoading(),
        AuthError(signOutError.toString()), // Expect AuthError state with the error message
      ],
      verify: (_) {
        verify(mockSignOutUseCase.execute()).called(1);
      },
    );

    // Add tests for AuthStateChanged event based on your implementation
    // If your bloc listens to a stream (like from FirebaseAuth.instance.authStateChanges()),
    // you would mock that stream and add AuthStateChanged events to the bloc in the act.
  });
}