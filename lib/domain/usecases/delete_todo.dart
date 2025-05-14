import '../repositories/todo_repository.dart';

class DeleteTodoUseCase {
  final TodoRepository todoRepository;

  DeleteTodoUseCase(this.todoRepository);

  Future<void> execute(String userId, String todoId) async {
    return todoRepository.deleteTodo(userId, todoId);
  }
}