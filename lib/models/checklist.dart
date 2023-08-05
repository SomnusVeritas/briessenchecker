import 'listitem.dart';

class Checklist {
  final int id;
  final String ownerId;
  String title;
  String description;
  final DateTime createdTime;
  List<Item> items;

  Checklist(this.id, this.ownerId, this.title, this.description,
      this.createdTime, List<Item>? items)
      : items = items ?? [];
}
