import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:myapp/main.dart' as app; // Import your main app file

void main() {
  // Define keys for widgets to find them reliably
  const Key emailFieldKey = Key('email_text_field');
  const Key passwordFieldKey = Key('password_text_field');
  const Key signInButtonKey = Key('sign_in_button');
  const Key registerButtonKey = Key('register_button');
  const Key logoutButtonKey = Key('logout_button'); // Assuming a logout button with this key
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Authentication Flow', () {
    testWidgets('user can successfully sign in and navigate to home screen', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Verify that we are on the Login Screen
      expect(find.byKey(emailFieldKey), findsOneWidget);
      expect(find.byKey(passwordFieldKey), findsOneWidget);
      expect(find.byKey(signInButtonKey), findsOneWidget);
      expect(find.byKey(registerButtonKey), findsOneWidget);

      // Enter valid credentials (replace with actual test credentials)
      await tester.enterText(find.byKey(emailFieldKey), 'test@example.com');
      await tester.enterText(find.byKey(passwordFieldKey), 'password123');

      // Tap the Sign In button (assuming it's the first ElevatedButton)
      await tester.tap(find.byKey(signInButtonKey));
      await tester.pumpAndSettle(); // Wait for navigation and UI updates

      // Verify that we have navigated to the Home Screen
      // Replace `HomeScreen` with the actual type of your Home Screen widget
      // You might need a key or a specific widget to uniquely identify the Home Screen
      expect(find.text('Todo List'), findsOneWidget); // Assuming your Home Screen has a title "Todo List" or similar
      expect(find.byType(ListView), findsOneWidget); // Assuming your Home Screen displays a ListView for todos

      // Optional: Verify the user is logged in (if you have a sign out button or user info displayed)
      // expect(find.byIcon(Icons.logout), findsOneWidget); // Example: if there's a logout icon
    });

    testWidgets('user can successfully register and navigate to home screen', (WidgetTester tester) async {
       app.main();
      await tester.pumpAndSettle();

      // Tap the Register button
      await tester.tap(find.byKey(registerButtonKey));
      await tester.pumpAndSettle(); // Wait for navigation to the registration screen (if applicable) or other UI updates

      // Assuming registration happens on the same screen or a simple dialog
      // Enter new user credentials (replace with actual unique test credentials)
      await tester.enterText(find.byKey(emailFieldKey), 'newuser_${DateTime.now().millisecondsSinceEpoch}@example.com'); // Use unique email
      await tester.enterText(find.byKey(passwordFieldKey), 'newpassword123');

      // Tap the Register button again (or the button that submits the registration form)
      // Replace `HomeScreen` with the actual type of your Home Screen widget
      // You might need a key or a specific widget to uniquely identify the Home Screen
      expect(find.text('Todo List'), findsOneWidget); // Assuming your Home Screen has a title "Todo List" or similar
      expect(find.byType(ListView), findsOneWidget); // Assuming your Home Screen displays a ListView for todos

      // Optional: Verify the user is logged in (if you have a sign out button or user info displayed)
      // expect(find.byIcon(Icons.logout), findsOneWidget); // Example: if there's a logout icon
    });

    testWidgets('user can successfully sign out and navigate back to login screen', (WidgetTester tester) async {
      // Start the app and log in first (or assume a pre-logged in state)
      app.main();
      await tester.pumpAndSettle();

      // Perform login steps
      await tester.enterText(find.byKey(emailFieldKey), 'test@example.com'); // Use valid test credentials
      await tester.enterText(find.byKey(passwordFieldKey), 'password123'); // Use valid test credentials
      await tester.tap(find.byKey(signInButtonKey));
      await tester.pumpAndSettle();

      // Verify that we are on the Home Screen
      expect(find.text('Todo List'), findsOneWidget); // Assuming Home Screen check

      // Tap the Logout button
      expect(find.byKey(logoutButtonKey), findsOneWidget);
      await tester.tap(find.byKey(logoutButtonKey));
      await tester.pumpAndSettle(); // Wait for navigation

      // Verify that we are back on the Login Screen
      expect(find.byKey(signInButtonKey), findsOneWidget);
      expect(find.byKey(registerButtonKey), findsOneWidget);
    });
    // You can add more integration tests for other authentication scenarios,
    // like signing up, signing in with invalid credentials, etc.

  });

  group('Todo Management Flow', () {
    // Assume the user is already logged in for these tests.
    // You might need to set up the test environment or use a test account
    // that is already logged in before running this test group.
    // Alternatively, you can include the login steps at the beginning of each test
    // in this group if setting up a pre-logged in state is not feasible.

    testWidgets('user can add a new todo', (WidgetTester tester) async {
      // Assuming we are starting from the Home Screen (user is logged in)
      // If not, add the login steps here or set up the test environment
      app.main(); // Start the app
      await tester.pumpAndSettle();

      // Assuming there's a way to add a new todo on the HomeScreen, e.g., a TextField and an Add button
      // Replace finders with the actual finders for your UI elements
      final newTodoDescription = 'Buy groceries';
      // You will need to define Keys for your todo adding TextField and button/FAB
      // For example:
      // await tester.enterText(find.byKey(Key('add_todo_textfield')), newTodoDescription);
      // await tester.tap(find.byKey(Key('add_todo_button')));
      await tester.pumpAndSettle();

      // Verify the new todo appears in the list
      expect(find.text(newTodoDescription), findsOneWidget);
      // You might also want to check if the TextField is cleared after adding
    });

    testWidgets('user can update an existing todo', (WidgetTester tester) async {
      // Assuming we are starting from the Home Screen with at least one todo
      app.main(); // Start the app
      await tester.pumpAndSettle();

      // Assuming you have a todo in the list to update. You might need to add one first
      // if the list is empty initially for this test.
      final initialTodoDescription = 'Buy groceries'; // The description of the todo to update
      final updatedTodoDescription = 'Buy milk and bread';

       // You will need to define Keys for your todo list items
      // For example:
      final todoItemFinder = find.byKey(Key('todo_item_${initialTodoDescription}')); // Assuming Key based on description or ID
      expect(todoItemFinder, findsOneWidget); // Ensure the todo exists

      // Simulate tapping on the todo item to edit (or whatever your update mechanism is)
      await tester.tap(todoItemFinder);
      await tester.pumpAndSettle();

      // Assuming tapping opens an editing interface, e.g., a dialog or a new screen
      // Replace finders and actions with the actual steps to update a todo in your UI
      // You will need to define Keys for your editing TextField and Save button
      // For example:
      // await tester.enterText(find.byKey(Key('edit_todo_textfield')), updatedTodoDescription);
      // await tester.tap(find.byKey(Key('save_todo_button')));
      await tester.pumpAndSettle();

      // Verify the todo is updated in the list
      expect(find.text(initialTodoDescription), findsNothing); // The old text should be gone
      expect(find.text(updatedTodoDescription), findsOneWidget); // The new text should be present
    });

    testWidgets('user can delete a todo', (WidgetTester tester) async {
      // Assuming we are starting from the Home Screen with at least one todo
      app.main(); // Start the app
      await tester.pumpAndSettle();

      // Assuming you have a todo in the list to delete. You might need to add one first.
      final todoDescriptionToDelete = 'Buy milk and bread'; // The description of the todo to delete

       // You will need to define Keys for your todo list items
      // For example:
      final todoItemFinder = find.byKey(Key('todo_item_${todoDescriptionToDelete}')); // Assuming Key based on description or ID
      expect(todoItemFinder, findsOneWidget); // Ensure the todo exists

      // Simulate deleting the todo. This could be a swipe, a long press, a delete button, etc.
      // Replace the action with the actual way to delete a todo in your UI
      // Example: Swiping the list tile to the left
      await tester.drag(todoItemFinder, const Offset(-500.0, 0.0));
      await tester.pumpAndSettle(); // Wait for the animation and UI update

      // Verify the todo is removed from the list
      expect(find.text(todoDescriptionToDelete), findsNothing);
    });
  });
}