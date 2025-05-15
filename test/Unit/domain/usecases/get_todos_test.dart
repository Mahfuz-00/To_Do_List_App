import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:myapp/domain/entities/todo.dart';
import 'package:myapp/domain/repositories/todo_repository.dart';
import 'package:myapp/domain/usecases/get_todos.dart';

// Create a mock TodoRepository
class MockTodoRepository extends Mock implements TodoRepository {}

void main() {
  late GetTodosUseCase getTodosUseCase;
  late MockTodoRepository mockTodoRepository;

  setUp(() {
    mockTodoRepository = MockTodoRepository();
    getTodosUseCase = GetTodosUseCase(mockTodoRepository);
  });

  group('GetTodosUseCase', () {
    final userId = 'testUserId';
    final mockTodos = [
      Todo(id: '1', title: 'Task 1', isCompleted: false),
      Todo(id: '2', title: 'Task 2', isCompleted: true),
    ];

    test('should call TodoRepository.getTodos and return a stream of todos', () {
      // Arrange
      when(mockTodoRepository.getTodos(userId))
          .thenAnswer((_) => Stream.fromIterable([mockTodos]));

      // Act
      final result = getTodosUseCase.execute(userId);

      // Assert
      expect(result, isA<Stream<List<Todo>>>());
      expect(result, emitsInOrder([mockTodos]));
      verify(mockTodoRepository.getTodos(userId)).called(1);
      verifyNoMoreInteractions(mockTodoRepository);
    });

    test('should handle errors from TodoRepository', () async {
      // Arrange
      when(mockTodoRepository.getTodos(userId))
          .thenAnswer((_) => Stream.error(Exception('Failed to get todos')));

      // Act
      final result = getTodosUseCase.execute(userId);

      // Assert
      expect(result, emitsError(isA<Exception>()));
      verify(mockTodoRepository.getTodos(userId)).called(1);
      verifyNoMoreInteractions(mockTodoRepository);
    });
  });
}