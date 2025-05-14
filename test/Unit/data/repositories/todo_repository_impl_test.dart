import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:myapp/data/repositories/todo_repository_impl.dart';
import 'package:myapp/domain/entities/todo.dart';
import 'package:myapp/data/models/todo_model.dart'; // Assuming you have a TodoModel
import 'dart:async';

// Create a mock data source (e.g., a mock API client or database helper)
class MockTodoDataSource extends Mock {
  // Define mock methods that your repository calls
  Stream<List<TodoModel>> getTodosStream(String userId);
  Future<void> addTodo(String userId, TodoModel todo);
  Future<void> updateTodo(String userId, TodoModel todo);
  Future<void> deleteTodo(String userId, String todoId);
}

void main() {
  late TodoRepositoryImpl todoRepository;
  late MockTodoDataSource mockTodoDataSource;

  setUp(() {
    mockTodoDataSource = MockTodoDataSource();
    todoRepository = TodoRepositoryImpl(mockTodoDataSource);
  });

  group('TodoRepositoryImpl', () {
    final userId = 'testUserId';
    final todo = Todo(id: '1', title: 'Test Todo', isDone: false, userId: userId);
    final todoModel = TodoModel(id: '1', title: 'Test Todo', isDone: false, userId: userId);
    final updatedTodo = Todo(id: '1', title: 'Updated Todo', isDone: true, userId: userId);
    final updatedTodoModel = TodoModel(id: '1', title: 'Updated Todo', isDone: true, userId: userId);

    test('getTodos returns a stream of Todos from the data source', () {
      final mockStreamController = StreamController<List<TodoModel>>();
      final mockStream = mockStreamController.stream;

      when(mockTodoDataSource.getTodosStream(userId))
          .thenAnswer((_) => mockStream);

      final result = todoRepository.getTodos(userId);

      expect(result, isA<Stream<List<Todo>>>());

      // Emit data from the mock data source stream
      mockStreamController.add([todoModel]);

      // Verify that the repository's stream emits the expected mapped Todo
      expect(
        result,
        emitsInOrder([
          [todo], // Expecting a list containing the mapped Todo
        ]),
      );
    });

    test('addTodo calls the data source to add a todo', () async {
      when(mockTodoDataSource.addTodo(userId, any))
          .thenAnswer((_) async => Future.value());

      await todoRepository.addTodo(userId, todo);

      verify(mockTodoDataSource.addTodo(userId, any)).called(1);
      // You could also verify that the correct TodoModel is passed if needed
      // verify(mockTodoDataSource.addTodo(userId, argThat(isA<TodoModel>())));
    });

    test('updateTodo calls the data source to update a todo', () async {
      when(mockTodoDataSource.updateTodo(userId, any))
          .thenAnswer((_) async => Future.value());

      await todoRepository.updateTodo(userId, updatedTodo);

      verify(mockTodoDataSource.updateTodo(userId, any)).called(1);
      // You could also verify that the correct TodoModel is passed if needed
      // verify(mockTodoDataSource.updateTodo(userId, argThat(isA<TodoModel>())));
    });

    test('deleteTodo calls the data source to delete a todo', () async {
      final todoId = 'todoToDeleteId';
      when(mockTodoDataSource.deleteTodo(userId, todoId))
          .thenAnswer((_) async => Future.value());

      await todoRepository.deleteTodo(userId, todoId);

      verify(mockTodoDataSource.deleteTodo(userId, todoId)).called(1);
    });

    // Add tests for error handling scenarios if your repository handles them
  });
}