import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/entities/todo.dart';
import '../../domain/repositories/todo_repository.dart';
import '../models/todo_model.dart';

class TodoRepositoryImpl implements TodoRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  TodoRepositoryImpl({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  @override
  Stream<List<Todo>> getTodos(String userId) {
    return _firestore
        .collection('todos')
        .doc(userId)
        .collection('userTodos')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => TodoModel.fromDocument(doc))
              .toList();
        })
        .handleError((error) {
          print('Error getting todos: $error');
          throw error; // Re-throw for bloc to handle
        });
  }

  @override
  Future<void> addTodo(String userId, Todo todo) async {
    try {
      await _firestore
          .collection('todos')
          .doc(userId)
          .collection('userTodos')
          .add(
            TodoModel(
              id: todo.id,
              title: todo.title,
              description: todo.description,
              isCompleted: todo.isCompleted,
            ).toDocument(),
          );
    } catch (e) {
      print('Error adding todo: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateTodo(String userId, Todo todo) async {
    try {
      await _firestore
          .collection('todos')
          .doc(userId)
          .collection('userTodos')
          .doc(todo.id)
          .update(
            TodoModel(
              id: todo.id,
              title: todo.title,
              description: todo.description,
              isCompleted: todo.isCompleted,
            ).toDocument(),
          );
    } catch (e) {
      print('Error updating todo: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteTodo(String userId, String todoId) async {
    try {
      await _firestore
          .collection('todos')
          .doc(userId)
          .collection('userTodos')
          .doc(todoId)
          .delete();
    } catch (e) {
      print('Error deleting todo: $e');
      rethrow;
    }
  }
}
