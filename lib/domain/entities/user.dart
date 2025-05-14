import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String uid;

  const User({required this.uid});

  @override
  List<Object?> get props => [uid];
}