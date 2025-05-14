import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:myapp/domain/repositories/todo_repository.dart';
import 'package:myapp/domain/usecases/delete_todo.dart';

// Create a mock TodoRepository
class MockTodoRepository extends Mock implements TodoRepository {}

void main() {
  late DeleteTodoUseCase deleteTodoUseCase;
  late MockTodoRepository mockTodoRepository;

  setUp(() {
    mockTodoRepository = MockTodoRepository();
    deleteTodoUseCase = DeleteTodoUseCase(mockTodoRepository);
  });

  group('DeleteTodoUseCase', () {
    test('should call the repository\'s deleteTodo method with the correct ID',
        () async {
      // Arrange
      const todoId = 'test-id';
      when(mockTodoRepository.deleteTodo(any, any)).thenAnswer((_) async => Future.value(null)); // Mock successful deletion

      // Act
      await deleteTodoUseCase.execute('user-id', todoId);

      // Assert
      verify(mockTodoRepository.deleteTodo('user-id', todoId)).called(1);
    });

    test('should throw an exception if the repository throws an exception', () async {
      // Arrange
      const todoId = 'test-id';
      final expectedException = Exception('Deletion failed');
      when(mockTodoRepository.deleteTodo(any, any)).thenThrow(expectedException);

      // Act & Assert
      expect(() => deleteTodoUseCase.execute('user-id', todoId), throwsA(equals(expectedException)));
      verify(mockTodoRepository.deleteTodo('user-id', todoId)).called(1);
    });
  });
}