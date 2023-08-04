import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});
  static const routeName = '/login';

  @override
  Widget build(BuildContext context) {
    TextEditingController usernameController = TextEditingController();
    TextEditingController passwordController = TextEditingController();

    return Scaffold(
      body: Form(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextFormField(
              controller: usernameController,
              decoration: const InputDecoration(label: Text('Username')),
            ),
            TextFormField(
              controller: passwordController,
              decoration: const InputDecoration(label: Text('Password')),
            ),
            FloatingActionButton.extended(
                onPressed: _loginSubmitted, label: const Text('Login'))
          ],
        ),
      ),
    );
  }

  void _loginSubmitted() {}
}
