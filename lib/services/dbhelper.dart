import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../assets/example_data.dart' as ed;
import '../models/checklist.dart';
import '../models/listitem.dart';

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

  static Future<void> logout() async {
    await _client.auth.signOut();
  }

  static Future<List<Checklist>> get fetchChecklist async {
    //TODO replace example data
    await Future.delayed(const Duration(seconds: 2));
    return ed.checklists;
  }

  /// returns id of newly created checklist
  static Future<int> addChecklist() async {
    //TODO Add checklist
    return 0;
  }

  static Future<Checklist> getChecklistById(int id) async {
    return ed.checklists.first;
  }

  static Future<void> addOrUpdateItem(
      int checklistId, String title, String description, int? itemId) async {
    // TODO implement addOrUpdateItem
  }

  static Stream<AuthState> get authChangeEventStream =>
      _client.auth.onAuthStateChange;
}
