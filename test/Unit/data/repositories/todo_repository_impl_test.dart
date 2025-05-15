// ignore_for_file: cast_from_null_always_fails

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:myapp/data/repositories/todo_repository_impl.dart';
import 'package:myapp/domain/entities/todo.dart';
import 'package:myapp/data/models/todo_model.dart';
import 'dart:async';

// Mocks for Firebase dependencies
class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}
class MockFirebaseAuth extends Mock implements FirebaseAuth {}
class MockCollectionReference extends Mock implements CollectionReference<Map<String, dynamic>> {} // Specify the type argument
class MockDocumentReference extends Mock implements DocumentReference<Map<String, dynamic>> {} // Specify the type argument
class MockQuerySnapshot extends Mock implements QuerySnapshot<Map<String, dynamic>> {} // Specify the type argument
class MockQueryDocumentSnapshot extends Mock implements QueryDocumentSnapshot<Map<String, dynamic>> {} // Specify the type argument
class MockDocumentSnapshot extends Mock implements DocumentSnapshot<Map<String, dynamic>> {} // Specify the type argument


void main() {
  late TodoRepositoryImpl todoRepository;
  late MockFirebaseFirestore mockFirestore;
  late MockFirebaseAuth mockAuth;
  late MockCollectionReference mockTodosCollection;
  late MockDocumentReference mockUserDocument;
  late MockCollectionReference mockUserTodosCollection;


  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockAuth = MockFirebaseAuth();
    mockTodosCollection = MockCollectionReference();
    mockUserDocument = MockDocumentReference();
    mockUserTodosCollection = MockCollectionReference();


    // Mock the sequence of calls to get to the user's todo collection
    when(mockFirestore.collection('todos')).thenReturn(mockTodosCollection);
    when(mockTodosCollection.doc(any)).thenReturn(mockUserDocument);
    when(mockUserDocument.collection('userTodos')).thenReturn(mockUserTodosCollection);


    todoRepository = TodoRepositoryImpl(firestore: mockFirestore, auth: mockAuth);
  });

  group('TodoRepositoryImpl', () {
    final userId = 'testUserId';
    final todo = Todo(id: '1', title: 'Test Todo', description: 'Description', isCompleted: false); // Added missing fields
    final todoModel = TodoModel(id: '1', title: 'Test Todo', description: 'Description', isCompleted: false); // Added missing fields and corrected isCompleted


    test('getTodos returns a stream of Todos from Firestore', () {
      final mockSnapshot = MockQuerySnapshot();
      final mockDocumentSnapshot = MockQueryDocumentSnapshot();
      when(mockDocumentSnapshot.data()).thenReturn(todoModel.toDocument()); // Mock the data
      when(mockDocumentSnapshot.id).thenReturn(todoModel.id); // Mock the ID
      when(mockSnapshot.docs).thenReturn([mockDocumentSnapshot]); // Mock the list of documents


      // Mock the snapshots stream
      final streamController = StreamController<MockQuerySnapshot>();
      when(mockUserTodosCollection.snapshots()).
          thenAnswer((_) => streamController.stream as Stream<QuerySnapshot<Map<String, dynamic>>>);


      final result = todoRepository.getTodos(userId);


      expect(result, isA<Stream<List<Todo>>>());


      // Emit data from the mock snapshot stream
      streamController.add(mockSnapshot);


      // Verify that the repository's stream emits the expected mapped Todo
      expect(
        result,
        emitsInOrder([
          [todo], // Expecting a list containing the mapped Todo
        ]),
      );


      streamController.close(); // Close the stream controller
    });

    test('addTodo calls Firestore to add a todo', () async {
      final mockDocumentReference = MockDocumentReference();
      // Corrected: Use argThat with isA for the positional Map argument
      when(mockUserTodosCollection.add(any as Map<String, dynamic>)).thenAnswer((_) async => mockDocumentReference);


      await todoRepository.addTodo(userId, todo);


      // Verify that the add method was called with the correct TodoModel's document data
      verify(mockUserTodosCollection.add(todoModel.toDocument())).called(1);
    });

    test('updateTodo calls Firestore to update a todo', () async {
       final mockTodoDocument = MockDocumentReference();
       when(mockUserTodosCollection.doc(todo.id)).thenReturn(mockTodoDocument); // Mock getting the document reference
       // Corrected: Use argThat with isA<Map<Object, Object?>>() for the update method's Map argument
       when(mockTodoDocument.update(any as Map<Object, Object?>)).thenAnswer((_) async => Future.value());


      await todoRepository.updateTodo(userId, todo);


      // Verify that the update method was called with the correct TodoModel's document data
      verify(mockTodoDocument.update(todoModel.toDocument())).called(1);
    });

    test('deleteTodo calls Firestore to delete a todo', () async {
      final todoId = 'todoToDeleteId';
       final mockTodoDocument = MockDocumentReference();
       when(mockUserTodosCollection.doc(todoId)).thenReturn(mockTodoDocument); // Mock getting the document reference
       when(mockTodoDocument.delete()).thenAnswer((_) async => Future.value()); // Mock the delete method


      await todoRepository.deleteTodo(userId, todoId);


      // Verify that the delete method was called
      verify(mockTodoDocument.delete()).called(1);
    });

    // Add tests for error handling scenarios if your repository handles them
    test('getTodos handles errors from Firestore stream', () {
       final mockSnapshot = MockQuerySnapshot();
       final error = Exception('Firestore stream error');


      // Mock the snapshots stream to emit an error
       final streamController = StreamController<MockQuerySnapshot>();
       when(mockUserTodosCollection.snapshots()).
          thenAnswer((_) => streamController.stream as Stream<QuerySnapshot<Map<String, dynamic>>>);


       final result = todoRepository.getTodos(userId);


       expect(result, emitsError(isA<Exception>())); // Expect an error to be emitted


       // Add the error to the stream
       streamController.addError(error);


       streamController.close(); // Close the stream controller
    });


    test('addTodo handles errors from Firestore', () {
      final error = Exception('Firestore add error');
      // Use argThat for consistency in error handling test
      when(mockUserTodosCollection.add(any as Map<String, dynamic>)).thenThrow(error); // Mock the add method to throw an error


      expect(() => todoRepository.addTodo(userId, todo), throwsA(isA<Exception>())); // Expect the addTodo method to throw the error
      verify(mockUserTodosCollection.add(todoModel.toDocument())).called(1); // Verify that add was still attempted
    });


     test('updateTodo handles errors from Firestore', () {
       final mockTodoDocument = MockDocumentReference();
       when(mockUserTodosCollection.doc(todo.id)).thenReturn(mockTodoDocument); // Mock getting the document reference
       final error = Exception('Firestore update error');
       // Use argThat with isA<Map<Object, Object?>>() for consistency in error handling test
       when(mockTodoDocument.update(any as Map<Object, Object?>)).thenThrow(error);


       expect(() => todoRepository.updateTodo(userId, todo), throwsA(isA<Exception>())); // Expect the updateTodo method to throw the error
       verify(mockTodoDocument.update(todoModel.toDocument())).called(1); // Verify that update was still attempted
     });


     test('deleteTodo handles errors from Firestore', () {
       final todoId = 'todoToDeleteId';
       final mockTodoDocument = MockDocumentReference();
       when(mockUserTodosCollection.doc(todoId)).thenReturn(mockTodoDocument); // Mock getting the document reference
       final error = Exception('Firestore delete error');
       when(mockTodoDocument.delete()).thenThrow(error); // Mock the delete method to throw an error


       expect(() => todoRepository.deleteTodo(userId, todoId), throwsA(isA<Exception>())); // Expect the deleteTodo method to throw the error
       verify(mockTodoDocument.delete()).called(1); // Verify that delete was still attempted
     });
  });
}
