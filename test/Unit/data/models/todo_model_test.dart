import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/data/models/todo_model.dart';

// Create a mock for DocumentSnapshot
class MockDocumentSnapshot extends Mock implements DocumentSnapshot<Map<String, dynamic>> {}
class MockDocumentSnapshotData extends Mock implements Map<String, dynamic> {}


void main() {
  group('TodoModel', () {
    test('fromDocument should correctly convert a DocumentSnapshot to a TodoModel', () {
      // Arrange
      final mockSnapshot = MockDocumentSnapshot();
      final mockData = MockDocumentSnapshotData();

      when(mockSnapshot.id).thenReturn('test_id');
      when(mockSnapshot.data()).thenReturn(mockData);
      when(mockData['title']).thenReturn('Test Title');
      when(mockData['description']).thenReturn('Test Description');
      when(mockData['isCompleted']).thenReturn(false);

      // Act
      final todoModel = TodoModel.fromDocument(mockSnapshot);

      // Assert
      expect(todoModel.id, 'test_id');
      expect(todoModel.title, 'Test Title');
      expect(todoModel.description, 'Test Description');
      expect(todoModel.isCompleted, false);
    });

     test('fromDocument should handle missing description and isCompleted fields', () {
      // Arrange
      final mockSnapshot = MockDocumentSnapshot();
      final mockData = MockDocumentSnapshotData();

      when(mockSnapshot.id).thenReturn('test_id_missing');
      when(mockSnapshot.data()).thenReturn(mockData);
      when(mockData['title']).thenReturn('Test Title Missing');
      when(mockData.containsKey('description')).thenReturn(false);
      when(mockData.containsKey('isCompleted')).thenReturn(false);


      // Act
      final todoModel = TodoModel.fromDocument(mockSnapshot);

      // Assert
      expect(todoModel.id, 'test_id_missing');
      expect(todoModel.title, 'Test Title Missing');
      expect(todoModel.description, ''); // Default value
      expect(todoModel.isCompleted, false); // Default value
    });

    test('toDocument should correctly convert a TodoModel to a Map<String, dynamic>', () {
      // Arrange
      const todoModel = TodoModel(
        id: 'test_id',
        title: 'Test Title',
        description: 'Test Description',
        isCompleted: true,
      );

      // Act
      final result = todoModel.toDocument();

      // Assert
      expect(result, isA<Map<String, dynamic>>());
      expect(result['title'], 'Test Title');
      expect(result['description'], 'Test Description');
      expect(result['isCompleted'], true);
      // Note: 'id' is typically not stored within the document data itself in Firestore,
      // but as the document ID, so it's not expected in toDocument output.
      expect(result.containsKey('id'), isFalse);
    });
  });
}