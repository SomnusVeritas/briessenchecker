import 'package:flutter/material.dart';

class ChecklistProvider extends ChangeNotifier {
  int? _selectedChecklistId;

  updateSelectedChecklist(int? checklistId, {bool silent = false}) {
    _selectedChecklistId = checklistId;
    if (!silent) notifyListeners();
  }

  int? get selectedChecklistId => _selectedChecklistId;
}
