import 'package:flutter/material.dart';

import '../models/profile.dart';

class ProfileProvider extends ChangeNotifier {
  List<Profile> _profiles = [];

  void updateProfiles(List<Profile> profiles, {bool silent = false}) {
    _profiles = profiles;
    if (!silent) notifyListeners();
  }

  Profile? getProfileById(String id) {
    if (_profiles.isEmpty) return null;
    final profile = _profiles.where((element) => element.id == id).first;
    return profile;
  }
}
