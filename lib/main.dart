import 'package:briessenchecker/services/dbhelper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gotrue/src/types/auth_state.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'pages/login_page.dart';

void main() async {
  await dotenv.load(fileName: 'secrets.env');
  await DbHelper.init();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isLoggedIn = false;
  @override
  Widget build(BuildContext context) {
    String initialRoute =
        isLoggedIn ? LoginPage.routeName : LoginPage.routeName;
    DbHelper.authChangeEventStream.listen(_onAuthEvent);
    return MaterialApp(
      title: 'Briessenchecker',
      theme: ThemeData.dark(
        useMaterial3: true,
      ).copyWith(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      initialRoute: initialRoute,
      routes: {
        LoginPage.routeName: (context) => const LoginPage(),
      },
    );
  }

  void _onAuthEvent(AuthState event) {
    if (event.event == AuthChangeEvent.signedIn) {
      setState(() => isLoggedIn = true);
    } else if (event.event == AuthChangeEvent.signedOut) {
      setState(() => isLoggedIn = false);
    }
  }
}
