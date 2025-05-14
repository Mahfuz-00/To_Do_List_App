import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:myapp/presentation/blocs/auth/auth_bloc.dart';
import 'package:myapp/domain/entities/todo.dart';
import 'package:myapp/domain/usecases/add_todo.dart';
import 'package:myapp/domain/usecases/delete_todo.dart';
import 'package:myapp/domain/usecases/get_todos.dart';
import 'package:myapp/domain/usecases/update_todo.dart';
import 'package:myapp/presentation/blocs/auth/auth_state.dart';
// Remove or comment out these imports as definitions will be local
import 'package:myapp/presentation/blocs/todo_list/todo_list_event.dart';
import 'package:myapp/presentation/blocs/todo_list/todo_list_state.dart';


// Define TodoList Events (These are now back in this file)
// Define TodoList States (These are now back in this file)


class TodoListBloc extends Bloc<TodoListEvent, TodoListState> {
  final GetTodosUseCase getTodosUseCase;
  final AddTodoUseCase addTodoUseCase;
  final UpdateTodoUseCase updateTodoUseCase;
  final DeleteTodoUseCase deleteTodoUseCase;
  final AuthBloc authBloc;

  TodoListBloc({
    required this.getTodosUseCase,
    required this.addTodoUseCase,
    required this.updateTodoUseCase,
    required this.deleteTodoUseCase,
    required this.authBloc,
  }) : super(TodoListInitial()) {
    on<LoadTodos>(_onLoadTodos);
    on<AddTodo>(_onAddTodo);
    on<UpdateTodo>(_onUpdateTodo);
    on<DeleteTodo>(_onDeleteTodo);
  }

  void _onLoadTodos(LoadTodos event, Emitter<TodoListState> emit) async {
    emit(TodoListLoading());
    try {
      if (authBloc.state is! Authenticated) {
        emit(TodoListError("User not authenticated."));
        return;
      }
      final authenticatedState = authBloc.state as Authenticated;
      final userId = authenticatedState.user.uid;

      await emit.forEach<List<Todo>>(
        getTodosUseCase.execute(userId),
        onData: (todos) => TodoListLoaded(todos),
        onError: (error, stackTrace) => TodoListError(error.toString()),
      );
    } catch (e) {
      emit(TodoListError(e.toString()));
    }
  }

  void _onAddTodo(AddTodo event, Emitter<TodoListState> emit) async {
    try {
      if (authBloc.state is! Authenticated) {
        emit(TodoListError("User not authenticated."));
        return;
      }
      final authenticatedState = authBloc.state as Authenticated;
      final userId = authenticatedState.user.uid;
      await addTodoUseCase.execute(userId, event.todo);
    } catch (e) {
      if (state is TodoListLoaded) {
        emit(TodoListError(e.toString()));
        // Optionally re-emit the previous state if adding fails
        emit(TodoListLoaded((state as TodoListLoaded).todos));
      } else {
         emit(TodoListError(e.toString()));
      }
    }
  }

  void _onUpdateTodo(UpdateTodo event, Emitter<TodoListState> emit) async {
    try {
      if (authBloc.state is! Authenticated) {
        emit(TodoListError("User not authenticated."));
        return;
      }
      final authenticatedState = authBloc.state as Authenticated;
      final userId = authenticatedState.user.uid;
      await updateTodoUseCase.execute(userId, event.todo);
    } catch (e) {
       if (state is TodoListLoaded) {
        emit(TodoListError(e.toString()));
        // Optionally re-emit the previous state if updating fails
        emit(TodoListLoaded((state as TodoListLoaded).todos));
      } else {
         emit(TodoListError(e.toString()));
      }
    }
  }

  void _onDeleteTodo(DeleteTodo event, Emitter<TodoListState> emit) async {
    try {
      if (authBloc.state is! Authenticated) {
        emit(TodoListError("User not authenticated."));
        return;
      }
      final authenticatedState = authBloc.state as Authenticated;
      final userId = authenticatedState.user.uid;
      await deleteTodoUseCase.execute(userId, event.id);
    } catch (e) {
      if (state is TodoListLoaded) {
        emit(TodoListError(e.toString()));
        // Optionally re-emit the previous state if deleting fails
        emit(TodoListLoaded((state as TodoListLoaded).todos));
      } else {
         emit(TodoListError(e.toString()));
      }
    }
  }
}