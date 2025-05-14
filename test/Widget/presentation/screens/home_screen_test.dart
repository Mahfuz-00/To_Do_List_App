import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth; // Added import

import 'package:myapp/domain/entities/todo.dart';
import 'package:myapp/domain/entities/user.dart' as my_app_user; // Alias for clarity
import 'package:myapp/presentation/blocs/auth/auth_bloc.dart';
import 'package:myapp/presentation/blocs/auth/auth_event.dart';
import 'package:myapp/presentation/blocs/auth/auth_state.dart';
import 'package:myapp/presentation/blocs/todo_list/todo_list_bloc.dart';
import 'package:myapp/presentation/blocs/todo_list/todo_list_event.dart';
import 'package:myapp/presentation/blocs/todo_list/todo_list_state.dart';
import 'package:myapp/presentation/screens/home_screen.dart';

// Mock classes
class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}
class MockTodoListBloc extends MockBloc<TodoListEvent, TodoListState> implements TodoListBloc {}
class MockFirebaseUser extends Mock implements firebase_auth.User {} // Added mock Firebase User

void main() {
  late MockAuthBloc mockAuthBloc;
  late MockTodoListBloc mockTodoListBloc;

  setUp(() {
    mockAuthBloc = MockAuthBloc();
    mockTodoListBloc = MockTodoListBloc();
  });

  tearDown(() {
    mockAuthBloc.close();
    mockTodoListBloc.close();
  });

  // Example test case (you will have more tests here)
  testWidgets('displays loading indicator when AuthBloc is loading', (WidgetTester tester) async {
    // Arrange
    whenListen(
      mockAuthBloc,
      Stream.fromIterable([AuthLoading()]),
      initialState: AuthInitial(), // Corrected parameter
    );

    // Build the widget
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(create: (_) => mockAuthBloc),
          BlocProvider<TodoListBloc>(create: (_) => mockTodoListBloc),
        ],
        child: MaterialApp(
          home: HomeScreen(),
        ),
      ),
    );

    // Assert
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  // Add other test cases here, ensuring correct whenListen and Authenticated state usage

  testWidgets('displays todo list when TodoListBloc is in TodoListLoaded state', (WidgetTester tester) async {
      // Arrange: Create mock todos and mock authenticated state with MockFirebaseUser
      final mockFirebaseUser = MockFirebaseUser();
      when(mockFirebaseUser.uid).thenReturn('testUserId');
      final tAuthenticatedState = Authenticated(user: mockFirebaseUser); // Corrected instantiation

      final mockTodos = [
        Todo(id: '1', title: 'Test Todo 1'),
        Todo(id: '2', title: 'Test Todo 2'),
      ];

      whenListen(mockAuthBloc, Stream.value(tAuthenticatedState), initialState: tAuthenticatedState); // Corrected parameter and instantiation
      whenListen(mockTodoListBloc, Stream.value(TodoListLoaded(mockTodos)), initialState: TodoListLoading()); // Corrected parameter

      // Build the widget
      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider<AuthBloc>(create: (_) => mockAuthBloc),
            BlocProvider<TodoListBloc>(create: (_) => mockTodoListBloc),
          ],
          child: MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );

      // Assert
      expect(find.byType(ListTile), findsNWidgets(mockTodos.length)); // Assuming each todo is in a ListTile
    });

    testWidgets('displays a loading indicator when TodoListBloc is in TodoListLoading state', (WidgetTester tester) async {
      // Arrange: Mock the TodoListBloc to emit TodoListLoading state
       final mockFirebaseUser = MockFirebaseUser();
      when(mockFirebaseUser.uid).thenReturn('testUserId');
      final tAuthenticatedState = Authenticated(user: mockFirebaseUser); // Corrected instantiation


      whenListen(mockTodoListBloc, Stream.value(TodoListLoading()), initialState: TodoListLoading()); // Corrected parameter
      whenListen(mockAuthBloc, Stream.value(tAuthenticatedState), initialState: tAuthenticatedState); // Corrected parameter and instantiation


      // Build the widget
      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider<AuthBloc>(create: (_) => mockAuthBloc),
            BlocProvider<TodoListBloc>(create: (_) => mockTodoListBloc),
          ],
          child: MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
}