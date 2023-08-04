import 'package:briessenchecker/services/dbhelper.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});
  static const routeName = '/login';

  @override
  Widget build(BuildContext context) {
    final TextEditingController _emailController = TextEditingController();
    final TextEditingController _passwordController = TextEditingController();
    return Scaffold(
      body: Form(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(label: Text('Email')),
            ),
            TextFormField(
              controller: _passwordController,
              decoration: const InputDecoration(label: Text('Password')),
            ),
            FloatingActionButton.extended(
                onPressed: () => _loginSubmitted(
                    _emailController.text, _passwordController.text),
                label: const Text('Login'))
          ],
        ),
      ),
    );
  }

  void _loginSubmitted(String email, String password) {
    DbHelper.login(email, password);
  }
}
