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
    double dialogWidth = screenSize.width > 300 ? 300 : screenSize.width;
    return Stack(children: [
      Image(
        width: screenSize.width,
        height: screenSize.height,
        fit: BoxFit.cover,
        image: const AssetImage(
          'nekro_wallpaper.jpg',
        ),
      ),
      Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).dialogBackgroundColor,
              backgroundBlendMode: BlendMode.luminosity,
              borderRadius: BorderRadius.circular(10),
            ),
            height: 300,
            width: dialogWidth,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Form(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextFormField(
                      controller: emailController,
                      autofillHints: const [
                        'email',
                        'username',
                        'name',
                        'login',
                        'mail'
                      ],
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(label: Text('Email')),
                    ),
                    const Padding(padding: EdgeInsets.symmetric(vertical: 8.0)),
                    TextFormField(
                      controller: passwordController,
                      autofillHints: const ['password', 'pass', 'login'],
                      onFieldSubmitted: (value) => _loginSubmitted(
                          emailController.text, passwordController.text),
                      decoration:
                          const InputDecoration(label: Text('Password')),
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
        ),
      ),
    ]);
  }

  void _loginSubmitted(String email, String password) {
    DbHelper.login(email, password);
  }
}
