import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:myapp/domain/entities/todo.dart';
import 'package:myapp/domain/usecases/add_todo.dart';
import 'package:myapp/domain/usecases/delete_todo.dart';
import 'package:myapp/domain/usecases/get_todos.dart';
import 'package:myapp/domain/usecases/update_todo.dart';
import 'package:myapp/presentation/blocs/auth/auth_bloc.dart';
import 'package:myapp/presentation/blocs/auth/auth_state.dart';
import 'package:myapp/presentation/blocs/todo_list/todo_list_bloc.dart';
import 'package:myapp/presentation/blocs/todo_list/todo_list_event.dart';
import 'package:myapp/presentation/blocs/todo_list/todo_list_state.dart';
import 'package:myapp/domain/entities/user.dart';

import '../../../../Widget/presentation/screens/home_screen_test.dart'; // Import the User entity

// Create mock classes for the dependencies
class MockGetTodosUseCase extends Mock implements GetTodosUseCase {}

class MockAddTodoUseCase extends Mock implements AddTodoUseCase {}

class MockUpdateTodoUseCase extends Mock implements UpdateTodoUseCase {}

class MockDeleteTodoUseCase extends Mock implements DeleteTodoUseCase {}

class MockAuthBloc extends Mock implements AuthBloc {}

void main() {
  late MockGetTodosUseCase mockGetTodosUseCase;
  late MockAddTodoUseCase mockAddTodoUseCase;
  late MockUpdateTodoUseCase mockUpdateTodoUseCase;
  late MockDeleteTodoUseCase mockDeleteTodoUseCase;
  late MockAuthBloc mockAuthBloc;

  setUp(() {
    mockGetTodosUseCase = MockGetTodosUseCase();
    mockAddTodoUseCase = MockAddTodoUseCase();
    mockUpdateTodoUseCase = MockUpdateTodoUseCase();
    mockDeleteTodoUseCase = MockDeleteTodoUseCase();
    mockAuthBloc = MockAuthBloc();
  });

  group('TodoListBloc', () {
    final mockFirebaseUser = MockFirebaseUser();
    when(mockFirebaseUser.uid).thenReturn('testUserId');
    final tAuthenticatedState = Authenticated(user: mockFirebaseUser);
    final tTodoList = [
      Todo(id: '1', title: 'Test Todo 1', isCompleted: false),
      Todo(id: '2', title: 'Test Todo 2', isCompleted: true),
    ];

    blocTest<TodoListBloc, TodoListState>(
      'emits [TodoListLoading, TodoListLoaded] when LoadTodos is added and authentication is successful',
      build: () {
        when(mockAuthBloc.state).thenReturn(tAuthenticatedState);
        when(mockGetTodosUseCase.execute(tUser.uid))
            .thenAnswer((_) => Stream.value(tTodoList));
        return TodoListBloc(
          getTodosUseCase: mockGetTodosUseCase,
          addTodoUseCase: mockAddTodoUseCase,
          updateTodoUseCase: mockUpdateTodoUseCase,
          deleteTodoUseCase: mockDeleteTodoUseCase,
          authBloc: mockAuthBloc,
        );
      },
      act: (bloc) => bloc.add(LoadTodos()),
      expect: () => [TodoListLoading(), TodoListLoaded(tTodoList)],
    );

    blocTest<TodoListBloc, TodoListState>(
      'emits [TodoListError] when LoadTodos is added and authentication fails',
      build: () {
        when(mockAuthBloc.state).thenReturn(Unauthenticated());
        return TodoListBloc(
          getTodosUseCase: mockGetTodosUseCase,
          addTodoUseCase: mockAddTodoUseCase,
          updateTodoUseCase: mockUpdateTodoUseCase,
          deleteTodoUseCase: mockDeleteTodoUseCase,
          authBloc: mockAuthBloc,
        );
      },
      act: (bloc) => bloc.add(LoadTodos()),
      expect: () =>
          [TodoListLoading(), TodoListError("User not authenticated.")],
    );

    blocTest<TodoListBloc, TodoListState>(
      'emits [TodoListError] when GetTodosUseCase throws an error',
      build: () {
        when(mockAuthBloc.state).thenReturn(tAuthenticatedState);
        when(mockGetTodosUseCase.execute(tUser.uid))
            .thenAnswer((_) => Stream.error(Exception('Failed to load todos')));
        return TodoListBloc(
          getTodosUseCase: mockGetTodosUseCase,
          addTodoUseCase: mockAddTodoUseCase,
          updateTodoUseCase: mockUpdateTodoUseCase,
          deleteTodoUseCase: mockDeleteTodoUseCase,
          authBloc: mockAuthBloc,
        );
      },
      act: (bloc) => bloc.add(LoadTodos()),
      expect: () => [
        TodoListLoading(),
        isA<TodoListError>()
      ], // Expecting any TodoListError
    );

    blocTest<TodoListBloc, TodoListState>(
      'calls AddTodoUseCase when AddTodo is added and authentication is successful',
      build: () {
        when(mockAuthBloc.state).thenReturn(tAuthenticatedState);
        when(mockAddTodoUseCase.execute(any, any))
            .thenAnswer((_) async => Future.value(null));
        return TodoListBloc(
          getTodosUseCase: mockGetTodosUseCase,
          addTodoUseCase: mockAddTodoUseCase,
          updateTodoUseCase: mockUpdateTodoUseCase,
          deleteTodoUseCase: mockDeleteTodoUseCase,
          authBloc: mockAuthBloc,
        );
      },
      act: (bloc) => bloc.add(AddTodo(tTodoList[0])),
      verify: (_) {
        verify(mockAddTodoUseCase.execute(tUser.uid, tTodoList[0])).called(1);
      },
    );

    blocTest<TodoListBloc, TodoListState>(
      'emits [TodoListError] when AddTodo is added and authentication fails',
      build: () {
        when(mockAuthBloc.state).thenReturn(Unauthenticated());
        return TodoListBloc(
          getTodosUseCase: mockGetTodosUseCase,
          addTodoUseCase: mockAddTodoUseCase,
          updateTodoUseCase: mockUpdateTodoUseCase,
          deleteTodoUseCase: mockDeleteTodoUseCase,
          authBloc: mockAuthBloc,
        );
      },
      act: (bloc) => bloc.add(AddTodo(tTodoList[0])),
      expect: () => [isA<TodoListError>()], // Expecting any TodoListError
    );

    blocTest<TodoListBloc, TodoListState>(
      'calls UpdateTodoUseCase when UpdateTodo is added and authentication is successful',
      build: () {
        when(mockAuthBloc.state).thenReturn(tAuthenticatedState);
        when(mockUpdateTodoUseCase.execute(any, any))
            .thenAnswer((_) async => Future.value(null));
        return TodoListBloc(
          getTodosUseCase: mockGetTodosUseCase,
          addTodoUseCase: mockAddTodoUseCase,
          updateTodoUseCase: mockUpdateTodoUseCase,
          deleteTodoUseCase: mockDeleteTodoUseCase,
          authBloc: mockAuthBloc,
        );
      },
      act: (bloc) => bloc.add(UpdateTodo(tTodoList[0])),
      verify: (_) {
        verify(mockUpdateTodoUseCase.execute(tUser.uid, tTodoList[0]))
            .called(1);
      },
    );

    blocTest<TodoListBloc, TodoListState>(
      'emits [TodoListError] when UpdateTodo is added and authentication fails',
      build: () {
        when(mockAuthBloc.state).thenReturn(Unauthenticated());
        return TodoListBloc(
          getTodosUseCase: mockGetTodosUseCase,
          addTodoUseCase: mockAddTodoUseCase,
          updateTodoUseCase: mockUpdateTodoUseCase,
          deleteTodoUseCase: mockDeleteTodoUseCase,
          authBloc: mockAuthBloc,
        );
      },
      act: (bloc) => bloc.add(UpdateTodo(tTodoList[0])),
      expect: () => [isA<TodoListError>()], // Expecting any TodoListError
    );

    blocTest<TodoListBloc, TodoListState>(
      'calls DeleteTodoUseCase when DeleteTodo is added and authentication is successful',
      build: () {
        when(mockAuthBloc.state).thenReturn(tAuthenticatedState);
        when(mockDeleteTodoUseCase.execute(any, any))
            .thenAnswer((_) async => Future.value(null));
        return TodoListBloc(
          getTodosUseCase: mockGetTodosUseCase,
          addTodoUseCase: mockAddTodoUseCase,
          updateTodoUseCase: mockUpdateTodoUseCase,
          deleteTodoUseCase: mockDeleteTodoUseCase,
          authBloc: mockAuthBloc,
        );
      },
      act: (bloc) => bloc.add(DeleteTodo('1')),
      verify: (_) {
        verify(mockDeleteTodoUseCase.execute(tUser.uid, '1')).called(1);
      },
    );

    blocTest<TodoListBloc, TodoListState>(
      'emits [TodoListError] when DeleteTodo is added and authentication fails',
      build: () {
        when(mockAuthBloc.state).thenReturn(Unauthenticated());
        return TodoListBloc(
          getTodosUseCase: mockGetTodosUseCase,
          addTodoUseCase: mockAddTodoUseCase,
          updateTodoUseCase: mockUpdateTodoUseCase,
          deleteTodoUseCase: mockDeleteTodoUseCase,
          authBloc: mockAuthBloc,
        );
      },
      act: (bloc) => bloc.add(DeleteTodo('1')),
      expect: () => [isA<TodoListError>()], // Expecting any TodoListError
    );

    // Add more test cases for error handling in Add, Update, and Delete
  });
}
