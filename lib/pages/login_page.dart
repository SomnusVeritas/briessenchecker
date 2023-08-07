import 'package:briessenchecker/services/dbhelper.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});
  static const routeName = '/login';

  @override
  Widget build(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    Size screenSize = MediaQuery.of(context).size;
    double dialogWidth = screenSize.width > 400 ? 400 : screenSize.width;
    return Scaffold(
      body: Center(
        child: SizedBox(
          width: dialogWidth,
          child: Form(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextFormField(
                  controller: emailController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(label: Text('Email')),
                ),
                const Padding(padding: EdgeInsets.symmetric(vertical: 8.0)),
                TextFormField(
                  controller: passwordController,
                  onFieldSubmitted: (value) => _loginSubmitted(
                      emailController.text, passwordController.text),
                  decoration: const InputDecoration(label: Text('Password')),
                ),
                const Padding(padding: EdgeInsets.symmetric(vertical: 8.0)),
                FloatingActionButton.extended(
                    onPressed: () => _loginSubmitted(
                        emailController.text, passwordController.text),
                    label: const Text('Login'))
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _loginSubmitted(String email, String password) {
    DbHelper.login(email, password);
  }
}
