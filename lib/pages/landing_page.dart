import 'package:briessenchecker/pages/dashboard_page.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/dbhelper.dart';
import 'login_page.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});
  static const routeName = '/';

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  bool _isLoggedIn = false;
  @override
  void initState() {
    DbHelper.authChangeEventStream.listen(_onAuthEvent);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoggedIn) return const DashboardPage();
    return const LoginPage();
  }

  void _onAuthEvent(AuthState event) {
    if (event.event == AuthChangeEvent.signedIn) {
      setState(() => _isLoggedIn = true);
    } else if (event.event == AuthChangeEvent.signedOut) {
      setState(() => _isLoggedIn = false);
    }
  }
}
