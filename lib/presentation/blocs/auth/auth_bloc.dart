import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import for User
import 'package:myapp/presentation/blocs/auth/auth_event.dart';
import 'package:myapp/presentation/blocs/auth/auth_state.dart';

import '../../../domain/usecases/sign_in_usecase.dart'; // Import SignInUseCase
import '../../../domain/usecases/register_usecase.dart'; // Import RegisterUseCase
import '../../../domain/usecases/sign_out_usecase.dart'; // Import SignOutUseCase
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';



class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignInUseCase signInUseCase;
  final RegisterUseCase registerUseCase;
  final SignOutUseCase signOutUseCase;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance; // Listen to auth state changes

  AuthBloc({required this.signInUseCase, required this.registerUseCase, required this.signOutUseCase}) : super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<AuthStateChanged>(_onAuthStateChanged); // Added handler for AuthStateChanged
  }

  void _onLoginRequested(LoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final User? user = await signInUseCase.execute(event.email, event.password);
      if (user != null) emit(Authenticated(user: user)); else emit(Unauthenticated());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  void _onRegisterRequested(RegisterRequested event, Emitter<AuthState> emit) async {
     emit(AuthLoading());
    try {
      final User? user = await registerUseCase.execute(event.email, event.password);
      if (user != null) emit(Authenticated(user: user)); else emit(Unauthenticated());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  void _onLogoutRequested(LogoutRequested event, Emitter<AuthState> emit) async {
     emit(AuthLoading());
    try {
      await signOutUseCase.execute();
      emit(Unauthenticated());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  void _onAuthStateChanged(AuthStateChanged event, Emitter<AuthState> emit) {
    if (event.user != null) {
      emit(Authenticated(user: event.user!));
    } else {
      emit(Unauthenticated());
    }
  }
}