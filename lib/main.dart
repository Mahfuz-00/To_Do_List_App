import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myapp/presentation/blocs/auth/auth_event.dart';
import 'package:myapp/presentation/blocs/auth/auth_state.dart';
import 'package:myapp/presentation/blocs/todo_list/todo_list_bloc.dart';
import 'package:myapp/presentation/blocs/todo_list/todo_list_event.dart';
import 'package:provider/provider.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:myapp/data/repositories/auth_repository.dart';
import 'package:myapp/data/repositories/todo_repository_impl.dart';
import 'package:myapp/domain/repositories/auth_repository.dart'
    as domain_auth_repository; // Import with alias
import 'package:myapp/domain/repositories/todo_repository.dart';
import 'package:myapp/domain/usecases/sign_in_usecase.dart';
import 'package:myapp/domain/usecases/register_usecase.dart';
import 'package:myapp/domain/usecases/sign_out_usecase.dart';
import 'package:myapp/domain/usecases/add_todo.dart';
import 'package:myapp/domain/usecases/delete_todo.dart';
import 'package:myapp/domain/usecases/get_todos.dart';
import 'package:myapp/domain/usecases/update_todo.dart';

import 'package:myapp/presentation/blocs/auth/auth_bloc.dart';
import 'package:myapp/presentation/screens/login_screen.dart'; // Updated import
import 'package:myapp/presentation/screens/home_screen.dart'; // Updated import

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // You will need to add options here if you are not using flutterfire configure
  await Firebase.initializeApp();
  runApp(MyApp());
}

// Import your firebase options file here
// import 'firebase_options.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: MultiProvider(
        providers: [
          Provider<domain_auth_repository.AuthRepository>(
            create:
                (_) => AuthRepositoryImpl(firebaseAuth: FirebaseAuth.instance),
          ),
          Provider<SignInUseCase>(
            create:
                (context) => SignInUseCase(
                  context.read<domain_auth_repository.AuthRepository>(),
                ),
          ),
          Provider<RegisterUseCase>(
            create:
                (context) => RegisterUseCase(
                  context.read<domain_auth_repository.AuthRepository>(),
                ),
          ),
          Provider<SignOutUseCase>(
            create:
                (context) => SignOutUseCase(
                  context.read<domain_auth_repository.AuthRepository>(),
                ),
          ),
          Provider<TodoRepository>(
            create:
                (_) => TodoRepositoryImpl(
                  firestore: FirebaseFirestore.instance,
                  auth: FirebaseAuth.instance,
                ),
          ),
          Provider<GetTodosUseCase>(
            create:
                (context) => GetTodosUseCase(context.read<TodoRepository>()),
          ),
          Provider<AddTodoUseCase>(
            create: (context) => AddTodoUseCase(context.read<TodoRepository>()),
          ),
          Provider<UpdateTodoUseCase>(
            create:
                (context) => UpdateTodoUseCase(context.read<TodoRepository>()),
          ),
          Provider<DeleteTodoUseCase>(
            create:
                (context) => DeleteTodoUseCase(context.read<TodoRepository>()),
          ),
          BlocProvider(
            create:
                (context) => AuthBloc(
                  signInUseCase: context.read<SignInUseCase>(),
                  registerUseCase: context.read<RegisterUseCase>(),
                  signOutUseCase: context.read<SignOutUseCase>(),
                )..add(AuthStateChanged(FirebaseAuth.instance.currentUser)),
          ),
        ],
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is AuthLoading) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            } else if (state is Authenticated) {
              // Provide TodoListBloc only when the user is authenticated
              return BlocProvider(
                create:
                    (context) => TodoListBloc(
                      getTodosUseCase: context.read<GetTodosUseCase>(),
                      addTodoUseCase: context.read<AddTodoUseCase>(),
                      updateTodoUseCase: context.read<UpdateTodoUseCase>(),
                      deleteTodoUseCase: context.read<DeleteTodoUseCase>(),
                      authBloc:
                          context.read<AuthBloc>(), // Pass AuthBloc dependency
                    )..add(LoadTodos()), // Load todos when authenticated
                child: const HomeScreen(),
              );
            }
            return const LoginScreen();
          },
        ),
      ),
    );
  }
}
