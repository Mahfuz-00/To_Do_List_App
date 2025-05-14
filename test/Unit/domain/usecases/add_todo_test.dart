import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:myapp/domain/entities/todo.dart';
import 'package:myapp/domain/repositories/todo_repository.dart';
import 'package:myapp/domain/usecases/add_todo.dart';

// Create a mock TodoRepository
class MockTodoRepository extends Mock implements TodoRepository {}

void main() {
  late AddTodoUseCase addTodoUseCase;
  late MockTodoRepository mockTodoRepository;

  setUp(() {
    mockTodoRepository = MockTodoRepository();
    addTodoUseCase = AddTodoUseCase(mockTodoRepository);
  });

  group('AddTodoUseCase', () {
    test('should call TodoRepository.addTodo with the correct data', () async {
      // Arrange
      const userId = 'testUserId';
      final todo = Todo(id: '1', title: 'Test Todo', isCompleted: false);

      // Mock the repository method
      when(mockTodoRepository.addTodo(userId, todo))
          .thenAnswer((_) async => Future.value(null)); // Simulate successful addition

      // Act
      await addTodoUseCase.execute(userId, todo);

      // Assert
      verify(mockTodoRepository.addTodo(userId, todo)).called(1);
    });

    test('should throw an exception if the repository call fails', () async {
      // Arrange
      const userId = 'testUserId';
      final todo = Todo(id: '1', title: 'Test Todo', isCompleted: false);
      final exception = Exception('Failed to add todo');

      // Mock the repository method to throw an exception
      when(mockTodoRepository.addTodo(userId, todo))
          .thenThrow(exception);

      // Act & Assert
      expect(() async => addTodoUseCase.execute(userId, todo),
          throwsA(isA<Exception>()));

      verify(mockTodoRepository.addTodo(userId, todo)).called(1);
    });
  });
}