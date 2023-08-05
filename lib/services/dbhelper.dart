import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../assets/example_data.dart' as ed;
import '../models/checklist.dart';
import '../models/listitem.dart';

class DbHelper {
  static late final SupabaseClient _client;
  static const checklistsTableName = 'checklists';
  static const itemsTableName = 'items';
  static const checkedItemsTableName = 'checkedItems';

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
    List<Checklist> checklists = [];
    final res = await _client
        .from(checklistsTableName)
        .select<List<Map<String, dynamic>>>();
    for (final element in res) {
      Checklist cl = Checklist(
        element['id'],
        element['ownerId'],
        element['title'],
        element['description'],
        DateTime.parse(element['createdTime']),
        [],
      );
      checklists.add(cl);
    }
    return checklists;
  }

  /// returns id of newly created checklist
  static Future<int> addOrUpdateChecklist(Checklist? checklist) async {
    final ownerId = _client.auth.currentSession!.user.id;

    Map<String, dynamic> upsertMap = {
      'ownerId': ownerId,
    };
    if (checklist != null) {
      List<MapEntry<String, dynamic>> entries = [
        MapEntry('id', checklist.id),
        MapEntry('title', checklist.title),
        MapEntry('description', checklist.description),
      ];
      upsertMap.addEntries(entries);
    }

    final res = await _client
        .from('checklists')
        .upsert(upsertMap)
        .select<List<Map<String, dynamic>>>('id');
    return res.last['id'] as int;
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
