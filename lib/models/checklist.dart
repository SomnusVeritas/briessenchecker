class Checklist {
  final int id;
  final String ownerId;
  String _title;
  String description;
  final DateTime createdTime;

  String get title => _title == '' ? 'Unnamed $id' : _title;

  Checklist(
      this.id, this.ownerId, String title, this.description, this.createdTime)
      : _title = title;
}
