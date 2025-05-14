import '../entities/todo.dart';
import '../repositories/todo_repository.dart';

class AddTodoUseCase {
  final TodoRepository todoRepository;

  AddTodoUseCase(this.todoRepository);

  Future<void> execute(String userId, Todo todo) async {
    return todoRepository.addTodo(userId, todo);
  }
}