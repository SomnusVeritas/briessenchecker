import 'package:briessenchecker/services/dbhelper.dart';
import 'package:briessenchecker/widgets/password_textfield.dart';
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
      Align(
          alignment: Alignment.topCenter,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'BRISEN',
                style: Theme.of(context).textTheme.displayLarge!.copyWith(
                      fontFamily: 'Cinzel',
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Image(
                  width: 200,
                  image: AssetImage('logo.png'),
                ),
              ),
              Text(
                'CHECKER',
                style: Theme.of(context).textTheme.displayLarge!.copyWith(
                      fontFamily: 'Cinzel',
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
              )
            ],
          )),
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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
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
                    PasswordField(
                      controller: passwordController,
                      onSubmitted: () => _loginSubmitted(
                          emailController.text, passwordController.text),
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
