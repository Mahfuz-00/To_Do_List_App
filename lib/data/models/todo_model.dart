import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/domain/entities/todo.dart';

class TodoModel extends Todo {
  const TodoModel({
    required String id,
    required String title,
    String? description,
    required bool isCompleted,
  }) : super(
          id: id,
          title: title,
          description: description ?? '',
          isCompleted: isCompleted,
        );

  factory TodoModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TodoModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'],
      isCompleted: data['isCompleted'] ?? false,
    );
  }

  Map<String, dynamic> toDocument() {
    return {
      'title': title,
      'description': description,
      'isCompleted': isCompleted,
    };
  }
}