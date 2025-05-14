import '../entities/todo.dart';

abstract class TodoRepository {
  Stream<List<Todo>> getTodos(String userId);
  Future<void> addTodo(String userId, Todo todo);
  Future<void> updateTodo(String userId, Todo todo);
  Future<void> deleteTodo(String userId, String todoId);
}