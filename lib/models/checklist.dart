class Checklist {
  final int id;
  final String ownerId;
  String title;
  String description;
  final DateTime createdTime;

  Checklist(
      this.id, this.ownerId, this.title, this.description, this.createdTime);
}
