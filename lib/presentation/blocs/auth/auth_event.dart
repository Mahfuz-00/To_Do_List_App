import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Assuming Firebase User

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  const LoginRequested({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}

class RegisterRequested extends AuthEvent {
  final String email;
  final String password;

  const RegisterRequested({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}

class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}

class AuthStateChanged extends AuthEvent {
  final User? user;

  const AuthStateChanged(this.user);
 @override
 List<Object> get props => [user ?? 'unauthenticated']; // Provide a non-null default value
}