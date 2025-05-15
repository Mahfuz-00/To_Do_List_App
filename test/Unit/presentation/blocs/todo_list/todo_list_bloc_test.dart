import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:myapp/domain/entities/todo.dart';
import 'package:myapp/domain/usecases/add_todo.dart';
import 'package:myapp/domain/usecases/delete_todo.dart';
import 'package:myapp/domain/usecases/get_todos.dart';
import 'package:myapp/domain/usecases/update_todo.dart';
import 'package:myapp/presentation/blocs/auth/auth_bloc.dart';
import 'package:myapp/presentation/blocs/auth/auth_event.dart';
import 'package:myapp/presentation/blocs/auth/auth_state.dart';
import 'package:myapp/presentation/blocs/todo_list/todo_list_bloc.dart';
import 'package:myapp/presentation/blocs/todo_list/todo_list_event.dart';
import 'package:myapp/presentation/blocs/todo_list/todo_list_state.dart';
import 'package:myapp/domain/entities/user.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

import '../../../../Widget/presentation/screens/home_screen_test.dart'; // Import the User entity

// Create mock classes for the dependencies
class MockGetTodosUseCase extends Mock implements GetTodosUseCase {}

class MockAddTodoUseCase extends Mock implements AddTodoUseCase {}

class MockUpdateTodoUseCase extends Mock implements UpdateTodoUseCase {}

class MockDeleteTodoUseCase extends Mock implements DeleteTodoUseCase {}

class MockAuthBloc extends Mock implements AuthBloc {}

class MockFirebaseUser extends Mock implements firebase_auth.User {}

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
      'initial state is TodoListInitial',
      build: () {
        // Mock the AuthBloc state to simulate initial unknown/unauthenticated state
        when(mockAuthBloc.state).thenReturn(AuthInitial());
        return TodoListBloc(
          getTodosUseCase: mockGetTodosUseCase,
          addTodoUseCase: mockAddTodoUseCase,
          updateTodoUseCase: mockUpdateTodoUseCase,
          deleteTodoUseCase: mockDeleteTodoUseCase,
          authBloc: mockAuthBloc,
        );
      },
      expect: () => [TodoListInitial()],
    );

    blocTest<TodoListBloc, TodoListState>(
        'emits [TodoListLoading, TodoListLoaded] when LoadTodos is added and authentication is successful',
        build: () {
          when(mockAuthBloc.state).thenReturn(tAuthenticatedState);
          when(mockGetTodosUseCase.execute(mockFirebaseUser
                  .uid)) // Corrected tUser.uid to mockFirebaseUser.uid
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
        verify: (_) {
          verify(mockAuthBloc.state)
              .called(1); // Verify that bloc checks auth state
          verify(mockGetTodosUseCase.execute(mockFirebaseUser.uid))
              .called(1); // Verify UseCase call
        });

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
        verify: (_) {
          verify(mockAuthBloc.state)
              .called(1); // Verify that bloc checks auth state
          verifyZeroInteractions(
              mockGetTodosUseCase); // Verify UseCase is not called
        });

    blocTest<TodoListBloc, TodoListState>(
        'emits [TodoListError] when GetTodosUseCase throws an error',
        build: () {
          when(mockAuthBloc.state).thenReturn(tAuthenticatedState);
          when(mockGetTodosUseCase.execute(mockFirebaseUser
                  .uid)) // Corrected tUser.uid to mockFirebaseUser.uid
              .thenAnswer(
                  (_) => Stream.error(Exception('Failed to load todos')));
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
        verify: (_) {
          verify(mockAuthBloc.state)
              .called(1); // Verify that bloc checks auth state
          verify(mockGetTodosUseCase.execute(mockFirebaseUser.uid))
              .called(1); // Verify UseCase call
        });

    blocTest<TodoListBloc, TodoListState>(
      'calls AddTodoUseCase when AddTodo is added and authentication is successful',
      build: () {
        when(mockAuthBloc.state).thenReturn(tAuthenticatedState);
        when(mockAddTodoUseCase.execute(any as String, any as Todo))
            .thenAnswer((_) async => Future.value(null));
        when(mockGetTodosUseCase.execute(mockFirebaseUser.uid)).thenAnswer(
            (_) => Stream.value(tTodoList)); // Mock stream for state after add
        return TodoListBloc(
          getTodosUseCase: mockGetTodosUseCase,
          addTodoUseCase: mockAddTodoUseCase,
          updateTodoUseCase: mockUpdateTodoUseCase,
          deleteTodoUseCase: mockDeleteTodoUseCase,
          authBloc: mockAuthBloc,
        );
      },
      act: (bloc) => bloc.add(AddTodo(tTodoList[0])),
      expect: () => [
        // Assuming AddTodo doesn't change state immediately but triggers a reload
        // If AddTodo has an immediate state change, adjust this expectation
        // TodoListLoading(), // If it emits loading before reloading
        // TodoListLoaded(tTodoList), // Assuming a reload happens and loads the list
      ],
      verify: (_) {
        verify(mockAuthBloc.state)
            .called(1); // Verify that bloc checks auth state
        verify(mockAddTodoUseCase.execute(mockFirebaseUser.uid, tTodoList[0]))
            .called(1); // Corrected tUser.uid to mockFirebaseUser.uid
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
        verify: (_) {
          verify(mockAuthBloc.state)
              .called(1); // Verify that bloc checks auth state
          verifyZeroInteractions(
              mockAddTodoUseCase); // Verify UseCase is not called
        });

    blocTest<TodoListBloc, TodoListState>(
        'emits [TodoListError] when AddTodoUseCase throws an error',
        build: () {
          when(mockAuthBloc.state).thenReturn(tAuthenticatedState);
          when(mockAddTodoUseCase.execute(any as String, any as Todo))
              .thenThrow(Exception('Failed to add todo'));
          when(mockGetTodosUseCase.execute(mockFirebaseUser.uid)).thenAnswer(
              (_) => Stream.value(
                  tTodoList)); // Mock stream for state after add error
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
        verify: (_) {
          verify(mockAuthBloc.state)
              .called(1); // Verify that bloc checks auth state
          verify(mockAddTodoUseCase.execute(mockFirebaseUser.uid, tTodoList[0]))
              .called(1); // Corrected tUser.uid to mockFirebaseUser.uid
        });

    blocTest<TodoListBloc, TodoListState>(
      'calls UpdateTodoUseCase when UpdateTodo is added and authentication is successful',
      build: () {
        when(mockAuthBloc.state).thenReturn(tAuthenticatedState);
        when(mockUpdateTodoUseCase.execute(any as String, any as Todo))
            .thenAnswer((_) async => Future.value(null));
        when(mockGetTodosUseCase.execute(mockFirebaseUser.uid)).thenAnswer(
            (_) =>
                Stream.value(tTodoList)); // Mock stream for state after update
        return TodoListBloc(
          getTodosUseCase: mockGetTodosUseCase,
          addTodoUseCase: mockAddTodoUseCase,
          updateTodoUseCase: mockUpdateTodoUseCase,
          deleteTodoUseCase: mockDeleteTodoUseCase,
          authBloc: mockAuthBloc,
        );
      },
      act: (bloc) => bloc.add(UpdateTodo(tTodoList[0])),
      expect: () => [
        // Assuming UpdateTodo doesn't change state immediately but triggers a reload
        // If UpdateTodo has an immediate state change, adjust this expectation
        // TodoListLoading(), // If it emits loading before reloading
        // TodoListLoaded(tTodoList), // Assuming a reload happens and loads the list
      ],
      verify: (_) {
        verify(mockAuthBloc.state)
            .called(1); // Verify that bloc checks auth state
        verify(mockUpdateTodoUseCase.execute(mockFirebaseUser.uid,
                tTodoList[0])) // Corrected tUser.uid to mockFirebaseUser.uid
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
        verify: (_) {
          verify(mockAuthBloc.state)
              .called(1); // Verify that bloc checks auth state
          verifyZeroInteractions(
              mockUpdateTodoUseCase); // Verify UseCase is not called
        });

    blocTest<TodoListBloc, TodoListState>(
        'emits [TodoListError] when UpdateTodoUseCase throws an error',
        build: () {
          when(mockAuthBloc.state).thenReturn(tAuthenticatedState);
          when(mockUpdateTodoUseCase.execute(any as String, any as Todo))
              .thenThrow(Exception('Failed to update todo'));
          when(mockGetTodosUseCase.execute(mockFirebaseUser.uid)).thenAnswer(
              (_) => Stream.value(
                  tTodoList)); // Mock stream for state after update error
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
        verify: (_) {
          verify(mockAuthBloc.state)
              .called(1); // Verify that bloc checks auth state
          verify(mockUpdateTodoUseCase.execute(
                  mockFirebaseUser.uid, tTodoList[0]))
              .called(1); // Corrected tUser.uid to mockFirebaseUser.uid
        });

    blocTest<TodoListBloc, TodoListState>(
      'calls DeleteTodoUseCase when DeleteTodo is added and authentication is successful',
      build: () {
        when(mockAuthBloc.state).thenReturn(tAuthenticatedState);
        when(mockDeleteTodoUseCase.execute(any as String, any as String))
            .thenAnswer((_) async => Future.value(null));
        when(mockGetTodosUseCase.execute(mockFirebaseUser.uid)).thenAnswer(
            (_) =>
                Stream.value(tTodoList)); // Mock stream for state after delete
        return TodoListBloc(
          getTodosUseCase: mockGetTodosUseCase,
          addTodoUseCase: mockAddTodoUseCase,
          updateTodoUseCase: mockUpdateTodoUseCase,
          deleteTodoUseCase: mockDeleteTodoUseCase,
          authBloc: mockAuthBloc,
        );
      },
      act: (bloc) => bloc.add(DeleteTodo('1')),
      expect: () => [
        // Assuming DeleteTodo doesn't change state immediately but triggers a reload
        // If DeleteTodo has an immediate state change, adjust this expectation
        // TodoListLoading(), // If it emits loading before reloading
        // TodoListLoaded(tTodoList), // Assuming a reload happens and loads the list
      ],
      verify: (_) {
        verify(mockAuthBloc.state)
            .called(1); // Verify that bloc checks auth state
        verify(mockDeleteTodoUseCase.execute(mockFirebaseUser.uid, '1'))
            .called(1); // Corrected tUser.uid to mockFirebaseUser.uid
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
        verify: (_) {
          verify(mockAuthBloc.state)
              .called(1); // Verify that bloc checks auth state
          verifyZeroInteractions(
              mockDeleteTodoUseCase); // Verify UseCase is not called
        });

    blocTest<TodoListBloc, TodoListState>(
        'emits [TodoListError] when DeleteTodoUseCase throws an error',
        build: () {
          when(mockAuthBloc.state).thenReturn(tAuthenticatedState);
          when(mockDeleteTodoUseCase.execute(any as String, any as String))
              .thenThrow(Exception('Failed to delete todo'));
          when(mockGetTodosUseCase.execute(mockFirebaseUser.uid)).thenAnswer(
              (_) => Stream.value(
                  tTodoList)); // Mock stream for state after delete error
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
        verify: (_) {
          verify(mockAuthBloc.state)
              .called(1); // Verify that bloc checks auth state
          verify(mockDeleteTodoUseCase.execute(mockFirebaseUser.uid, '1'))
              .called(1); // Corrected tUser.uid to mockFirebaseUser.uid
        });

    blocTest<TodoListBloc, TodoListState>(
      'emits [TodoListLoading, TodoListLoaded] when AuthState changes to Authenticated',
      build: () {
        final authBlocSubject = StreamController<AuthState>();
        // Mock the AuthBloc stream to emit the authenticated state
        when(mockAuthBloc.stream).thenAnswer((_) => authBlocSubject.stream);
        when(mockGetTodosUseCase.execute(mockFirebaseUser.uid))
            .thenAnswer((_) => Stream.value(tTodoList));
        // Mock the initial state of AuthBloc
        when(mockAuthBloc.state).thenReturn(Unauthenticated());

        final bloc = TodoListBloc(
          getTodosUseCase: mockGetTodosUseCase,
          addTodoUseCase: mockAddTodoUseCase,
          updateTodoUseCase: mockUpdateTodoUseCase,
          deleteTodoUseCase: mockDeleteTodoUseCase,
          authBloc: mockAuthBloc,
        );
        // Emit the authenticated state into the mocked stream after the bloc is created
        authBlocSubject.add(tAuthenticatedState);
        return bloc;
      },
      // No act function needed as the bloc listens to the stream
      expect: () => [TodoListLoading(), TodoListLoaded(tTodoList)],
      verify: (_) {
        verify(mockAuthBloc.stream)
            .called(1); // Verify that bloc listens to auth state changes
        verify(mockGetTodosUseCase.execute(mockFirebaseUser.uid))
            .called(1); // Verify UseCase call
      },
    );

    blocTest<TodoListBloc, TodoListState>(
      'emits [TodoListInitial] when AuthState changes to Unauthenticated',
      build: () {
        final authBlocSubject = StreamController<AuthState>();
        // Mock the AuthBloc stream to emit the unauthenticated state
        when(mockAuthBloc.stream).thenAnswer((_) => authBlocSubject.stream);
        // Mock the initial state of AuthBloc
        when(mockAuthBloc.state).thenReturn(tAuthenticatedState);

        final bloc = TodoListBloc(
          getTodosUseCase: mockGetTodosUseCase,
          addTodoUseCase: mockAddTodoUseCase,
          updateTodoUseCase: mockUpdateTodoUseCase,
          deleteTodoUseCase: mockDeleteTodoUseCase,
          authBloc: mockAuthBloc, // Make sure to pass the mockAuthBloc here
        );

        // Add the state to the stream AFTER the bloc is created and subscribed
        authBlocSubject.add(Unauthenticated());

        return bloc; // Return the created bloc instance
      },
      expect: () => [TodoListInitial()],
      verify: (_) {
        verify(mockAuthBloc.stream)
            .called(1); // Verify that bloc listens to auth state changes
        verifyZeroInteractions(
            mockGetTodosUseCase); // Verify UseCase is not called
      },
    );

    // Add error handling tests for SignInRequested and LogoutRequested if needed
  });
}
