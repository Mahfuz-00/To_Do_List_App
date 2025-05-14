import 'package:equatable/equatable.dart';
import 'package:myapp/domain/entities/todo.dart';

abstract class TodoListEvent extends Equatable {
  const TodoListEvent();

  @override
  List<Object> get props => [];
}
class AddTodo extends TodoListEvent {
  final Todo todo;

  const AddTodo(this.todo);

  @override
  List<Object> get props => [todo];
}

class DeleteTodo extends TodoListEvent {
  final String id;

  const DeleteTodo(this.id);

  @override
  List<Object> get props => [id];
}

class UpdateTodo extends TodoListEvent {
  final Todo todo;

  const UpdateTodo(this.todo);

  @override
  List<Object> get props => [todo];
}
class LoadTodos extends TodoListEvent {
  const LoadTodos();
}
