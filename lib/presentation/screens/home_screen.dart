import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myapp/domain/entities/todo.dart';
import 'package:myapp/presentation/blocs/auth/auth_bloc.dart';
import 'package:myapp/presentation/blocs/auth/auth_event.dart';
import 'package:myapp/presentation/blocs/auth/auth_state.dart';
import 'package:myapp/presentation/blocs/todo_list/todo_list_bloc.dart';
import 'package:myapp/presentation/blocs/todo_list/todo_list_event.dart';
import 'package:myapp/presentation/blocs/todo_list/todo_list_state.dart';
import 'package:uuid/uuid.dart'; // Import uuid package

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Screen'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthBloc>().add(LogoutRequested());
            },
          ),
        ],
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Unauthenticated) {
            Navigator.of(
              context,
            ).pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
          }
        },
        child: const Center(child: TodoListView()),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTodoDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddTodoDialog(BuildContext context) {
    final TextEditingController _titleController = TextEditingController();
    final TextEditingController _descriptionController =
        TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Todo'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (_titleController.text.isNotEmpty) {
                  const uuid = Uuid(); // Create a Uuid instance
                  final newTodo = Todo(
                    id: uuid.v4(), // Generate a unique ID
                    title: _titleController.text,
                    description:
                        _descriptionController.text.isNotEmpty
                            ? _descriptionController.text
                            : '', // Handle empty description
                    isCompleted: false,
                  );
                  context.read<TodoListBloc>().add(AddTodo(newTodo));
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
}

class TodoListView extends StatelessWidget {
  const TodoListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TodoListBloc, TodoListState>(
      builder: (context, state) {
        if (state is TodoListLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is TodoListLoaded) {
          return ListView.builder(
            itemCount: state.todos.length,
            itemBuilder: (context, index) {
              final todo = state.todos[index];
              return Dismissible(
                key: Key(todo.id),
                direction: DismissDirection.horizontal,
                onDismissed: (direction) {
                  if (direction == DismissDirection.startToEnd) {
                    context.read<TodoListBloc>().add(
                      UpdateTodo(todo.copyWith(isCompleted: true)),
                    );
                  } else if (direction == DismissDirection.endToStart) {
                    // Handle delete
                    context.read<TodoListBloc>().add(DeleteTodo(todo.id));
                  }
                },
                background: Container(
                  color: Colors.green,
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: const Icon(Icons.check, color: Colors.white),
                ),
                secondaryBackground: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                child: ListTile(
                  title: Text(
                    todo.title,
                    style: TextStyle(
                      decoration:
                          todo.isCompleted ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  subtitle: Text(todo.description),
                  trailing:
                      todo.isCompleted
                          ? const Icon(Icons.check_circle, color: Colors.green)
                          : null,
                ),
              );
            },
          );
        } else if (state is TodoListError) {
          return Center(child: Text('Error: ${state.message}'));
        }
        return const Center(child: Text('Press the + button to add a todo'));
      },
    );
  }
}
