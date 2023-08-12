class Profile {
  final String id;
  final String username;
  final String language;
  final String bio;

  Profile(
      {required this.id,
      this.username = '',
      this.language = '',
      this.bio = ''});
}
