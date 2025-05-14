import 'package:equatable/equatable.dart';
import 'package:myapp/domain/entities/todo.dart'; // Adjust import based on your structure

abstract class TodoListState extends Equatable {
  const TodoListState();

  @override
  List<Object?> get props => [];
}

class TodoListInitial extends TodoListState {}

class TodoListLoading extends TodoListState {}

class TodoListLoaded extends TodoListState {
  final List<Todo> todos;

  const TodoListLoaded(this.todos);

  @override
  List<Object?> get props => [todos];
}

class TodoListError extends TodoListState {
  final String message;

  const TodoListError(this.message);

  @override
  List<Object?> get props => [message];
}