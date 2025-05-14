import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mockito/mockito.dart';
import 'package:myapp/presentation/blocs/auth/auth_bloc.dart';
import 'package:myapp/presentation/blocs/auth/auth_state.dart';
import 'package:myapp/presentation/blocs/auth/auth_event.dart';
import 'package:myapp/presentation/screens/login_screen.dart';

// Create a mock AuthBloc
class MockAuthBloc extends Mock implements AuthBloc {}

void main() {
  late MockAuthBloc mockAuthBloc;

  setUp(() {
    mockAuthBloc = MockAuthBloc();
  });

  Widget makeTestableWidget({required Widget child}) {
    return BlocProvider<AuthBloc>(
      create: (context) => mockAuthBloc,
      child: MaterialApp(home: child),
    );
  }

  group('LoginScreen Widget Tests', () {
    // Mock the stream to avoid issues with bloc_test and pumpWidget
    setUp(() {
      whenListen(
        mockAuthBloc,
        Stream.fromIterable(
            []), // Provide an empty stream if you just need to set up the initial state
        initialState: AuthInitial(), // Set the initial state
      );
    });

    testWidgets('LoginScreen has email and password fields and buttons',
        (WidgetTester tester) async {
      // Arrange: Mock the initial state of the AuthBloc
      when(mockAuthBloc.state).thenReturn(AuthInitial());
      whenListen(
        mockAuthBloc,
        Stream.fromIterable(
            []), // Provide an empty stream if you just need to set up the initial state
        initialState: AuthInitial(), // Set the initial state
      );

      // Act: Build the LoginScreen widget
      await tester.pumpWidget(makeTestableWidget(child: LoginScreen()));

      // Assert: Verify the presence of key widgets
      expect(find.byType(TextFormField),
          findsNWidgets(2)); // Expecting email and password fields
      expect(find.byType(ElevatedButton),
          findsNWidgets(2)); // Expecting Sign In and Register buttons

      // You can add more specific checks, e.g., by finding widgets by key or text
      expect(find.widgetWithText(ElevatedButton, 'Sign In'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Register'), findsOneWidget);
    });

    // You can add more widget tests here to cover different scenarios,
    // such as testing input field interactions, button taps, error message display, etc.
    // For example:
    // testWidgets('Entering text into email field works', (WidgetTester tester) async {
    //   when(mockAuthBloc.state).thenReturn(AuthInitial());
    //   when(mockAuthBloc.stream).asBroadcastStream();
    //
    //   await tester.pumpWidget(makeTestableWidget(child: LoginScreen()));
    //
    //   await tester.enterText(find.byType(TextFormField).first, 'test@test.com');
    //   expect(find.text('test@test.com'), findsOneWidget);
    // });
  });
}
