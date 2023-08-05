class Item {
  final int? id;
  final String ownerId;
  String title;
  String description;
  final DateTime createdTime;
  List<String> checkedBy;

  Item(this.id, this.ownerId, this.title, this.description, this.createdTime,
      List<String>? checkedBy)
      : checkedBy = checkedBy ?? [];
}
