import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myapp/presentation/blocs/auth/auth_bloc.dart';
import 'package:myapp/presentation/blocs/auth/auth_event.dart';
import 'package:myapp/presentation/blocs/auth/auth_state.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

 @override
 Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,

            ),
            SizedBox(height: 12.0),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
           SizedBox(height: 20.0),
           BlocConsumer<AuthBloc, AuthState>(
             listener: (context, state) {
               if (state is AuthError) {
                 ScaffoldMessenger.of(context).showSnackBar(
                   SnackBar(content: Text(state.message)),
                 );
               }
             },
             builder: (context, state) {
               if (state is AuthLoading) {
                 return CircularProgressIndicator();
               }
               return Column(
                 children: [
                   ElevatedButton(
                     onPressed: () {
                       context.read<AuthBloc>().add(
                         LoginRequested(
                           email: _emailController.text,
                           password: _passwordController.text,
                         ),
                       );
                     },
                     child: const Text('Login'),
                   ),
                   SizedBox(height: 12.0),
                   TextButton(
                     onPressed: () {
                       context.read<AuthBloc>().add(
                         RegisterRequested(
                           email: _emailController.text,
                           password: _passwordController.text,
                         ),
                       );
                     },
                     child: const Text('Don\'t have an account? Register'),
                   ),
                 ],
               );
             },
           ),

          ],
        ),
      ),
    );
  }
}