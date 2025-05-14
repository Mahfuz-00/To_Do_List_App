import '../entities/todo.dart';
import '../repositories/todo_repository.dart';

class GetTodosUseCase {
  final TodoRepository todoRepository;

  GetTodosUseCase(this.todoRepository);

  Stream<List<Todo>> execute(String userId) {
    return todoRepository.getTodos(userId);
  }
}