import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:myapp/domain/entities/todo.dart';
import 'package:myapp/domain/repositories/todo_repository.dart';
import 'package:myapp/domain/usecases/update_todo.dart';

// Create a mock TodoRepository
class MockTodoRepository extends Mock implements TodoRepository {}

void main() {
  late UpdateTodoUseCase updateTodoUseCase;
  late MockTodoRepository mockTodoRepository;

  setUp(() {
    mockTodoRepository = MockTodoRepository();
    updateTodoUseCase = UpdateTodoUseCase(mockTodoRepository);
  });

  group('UpdateTodoUseCase', () {
    test('should call updateTodo on the repository with correct parameters', () async {
      // Arrange
      const userId = 'testUserId';
      final todoToUpdate = Todo(
        id: '1',
        task: 'Update task',
        isCompleted: true,
        dueDate: DateTime.now(),
        priority: 'High',
      );

      when(mockTodoRepository.updateTodo(userId, todoToUpdate)).thenAnswer((_) async => Future.value(null));

      // Act
      await updateTodoUseCase.execute(userId, todoToUpdate);

      // Assert
      verify(mockTodoRepository.updateTodo(userId, todoToUpdate)).called(1);
    });

    test('should throw an exception if the repository throws an exception', () async {
      // Arrange
      const userId = 'testUserId';
      final todoToUpdate = Todo(
        id: '1',
        task: 'Update task',
        isCompleted: true,
        dueDate: DateTime.now(),
        priority: 'High',
      );
      final expectedException = Exception('Failed to update todo');

      when(mockTodoRepository.updateTodo(userId, todoToUpdate)).thenThrow(expectedException);

      // Act & Assert
      expect(() async => updateTodoUseCase.execute(userId, todoToUpdate), throwsA(equals(expectedException)));
      verify(mockTodoRepository.updateTodo(userId, todoToUpdate)).called(1);
    });
  });
}