import 'package:briessenchecker/services/dbhelper.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});
  static const routeName = '/login';

  @override
  Widget build(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    return Scaffold(
      body: Form(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextFormField(
              controller: emailController,
              decoration: const InputDecoration(label: Text('Email')),
            ),
            TextFormField(
              controller: passwordController,
              decoration: const InputDecoration(label: Text('Password')),
            ),
            FloatingActionButton.extended(
                onPressed: () => _loginSubmitted(
                    emailController.text, passwordController.text),
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
