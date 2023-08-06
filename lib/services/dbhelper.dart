import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/checklist.dart';
import '../models/listitem.dart';

class DbHelper {
  static const checkedItemsTableName = 'checkedItems';
  static const checklistsTableName = 'checklists';
  static const itemsTableName = 'items';

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
    List<Checklist> checklists = [];
    final res = await _client
        .from(checklistsTableName)
        .select<List<Map<String, dynamic>>>();
    for (final element in res) {
      Checklist cl = Checklist(
        element['id'],
        element['owner_id'],
        element['title'],
        element['description'],
        DateTime.parse(element['created_time']),
      );
      checklists.add(cl);
    }
    return checklists;
  }

  static Future<void> updateChecklistTitle(int id, String title) async {
    await _client
        .from(checklistsTableName)
        .update({'title': title}).eq('id', id);
  }

  /// returns id of newly created checklist
  static Future<int> addOrUpdateChecklist(Checklist? checklist) async {
    final ownerId = _client.auth.currentSession!.user.id;

    Map<String, dynamic> upsertMap = {
      'owner_id': ownerId,
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

  static Future<void> addOrUpdateItem(
    int checklistId,
    String title,
    String description,
    int? itemId,
  ) async {
    try {
      final ownerId = _client.auth.currentSession!.user.id;

      Map<String, dynamic> upsertMap = {
        'checklist_id': checklistId,
        'owner_id': ownerId,
        'title': title,
        'description': description,
      };
      if (itemId != null) {
        upsertMap.addEntries([
          MapEntry('id', itemId),
        ]);
      }
      await _client.from(itemsTableName).upsert(upsertMap);
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  static Future<List<Item>> getItemsByChecklistId(int checklistId) async {
    final List<Item> items = [];

    final itemRes = await _client
        .from(itemsTableName)
        .select<List<Map<String, dynamic>>>()
        .eq('checklist_id', checklistId);

    for (final item in itemRes) {
      items.add(
        Item(
          item['id'],
          item['owner_id'],
          item['title'],
          item['description'],
          DateTime.parse(item['created_time']),
          null,
        ),
      );
    }

    return items;
  }

  static Future<Checklist> getChecklistById(int id) async {
    final checklistRes = await _client
        .from(checklistsTableName)
        .select<Map<String, dynamic>>()
        .eq('id', id)
        .single();

    return Checklist(
      checklistRes['id'],
      checklistRes['owner_id'],
      checklistRes['title'],
      checklistRes['description'],
      DateTime.parse(checklistRes['created_time']),
    );
  }

  static Future<void> deleteItemById(int id) async {
    await _client.from(itemsTableName).delete().eq('id', id);
  }

  static Future<void> deleteItemsById(List<int> ids) async {
    await _client.from(itemsTableName).delete().in_('id', ids);
  }

  static Future<void> deleteChecklistByid(int id) async {
    await _client.from(itemsTableName).delete().eq('checklist_id', id);
    await _client.from(checklistsTableName).delete().eq('id', id);
  }

  static Stream<AuthState> get authChangeEventStream =>
      _client.auth.onAuthStateChange;
}
