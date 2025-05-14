import '../entities/todo.dart';
import '../repositories/todo_repository.dart';

class UpdateTodoUseCase {
  final TodoRepository repository;

  UpdateTodoUseCase(this.repository);

  Future<void> execute(String userId, Todo todo) async {
    return repository.updateTodo(userId, todo);
  }
}