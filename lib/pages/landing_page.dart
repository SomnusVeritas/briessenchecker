import 'package:briessenchecker/pages/dashboard_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart' as p;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/dbhelper.dart';
import '../services/profile_provider.dart';
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

  void _onAuthEvent(AuthState event) async {
    if (event.event == AuthChangeEvent.signedIn) {
      await DbHelper.fetchProfiles().then((value) =>
          p.Provider.of<ProfileProvider>(context, listen: false)
              .updateProfiles(value));
      setState(() => _isLoggedIn = true);
    } else if (event.event == AuthChangeEvent.signedOut) {
      setState(() => _isLoggedIn = false);
    }
  }
}
