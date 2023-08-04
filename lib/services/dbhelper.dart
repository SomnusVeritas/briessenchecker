import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DbHelper {
  static late final SupabaseClient _client;

  static Future<void> init() async {
    await Supabase.initialize(
        url: dotenv.env['SUPABASE_URL'] ?? '',
        anonKey: dotenv.env['SUPABASE_ANON'] ?? '');
    _client = Supabase.instance.client;
  }

  static Future<void> login(String email, String password) async {
    email = 'sites@skup.in';
    password = 'pass';
    await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  static Stream<AuthState> get authChangeEventStream =>
      _client.auth.onAuthStateChange;
}
