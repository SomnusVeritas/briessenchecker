import 'package:briessenchecker/models/checklist.dart';
import 'package:briessenchecker/models/listitem.dart';
import 'package:briessenchecker/services/checklist_provider.dart';
import 'package:briessenchecker/services/dbhelper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DetailChecklistPage extends StatefulWidget {
  const DetailChecklistPage({super.key});

  static const routeName = '/detail';

  @override
  State<DetailChecklistPage> createState() => _DetailChecklistPageState();
}

class _DetailChecklistPageState extends State<DetailChecklistPage> {
  late Future<Checklist> _checklistFuture;
  late final ChecklistProvider _checklistProvider;
  int? _selectedItemId;
  late Checklist _currentChecklist;

  @override
  void dispose() {
    super.dispose();
    _checklistProvider.updateSelectedChecklist(null, silent: true);
  }

  @override
  void initState() {
    super.initState();
    _checklistProvider = Provider.of<ChecklistProvider>(context, listen: false);
    _checklistFuture = DbHelper.getChecklistById(1);
  }

  Widget _futureBuilder(
      BuildContext context, AsyncSnapshot<Checklist> snapshot) {
    if (snapshot.hasData) {
      _currentChecklist = snapshot.data!;
      return Column(
        children: [
          Text(_currentChecklist.title),
          Text(_currentChecklist.description),
        ],
      );
    } else {
      return const CircularProgressIndicator();
    }
  }

  void _addItemTapped() {
    showDialog(context: context, builder: _addItemDialog);
  }

  Widget _addItemDialog(BuildContext context) {
    TextEditingController titleCon = TextEditingController();
    TextEditingController descCon = TextEditingController();
    if (_selectedItemId != null) {
      final item = _currentChecklist.items.elementAt(_selectedItemId!);
      titleCon.text = item.title;
      descCon.text = item.description;
    }
    return AlertDialog(
      title: const Text('additem'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: titleCon,
            decoration: const InputDecoration(
              label: Text('Title'),
            ),
          ),
          TextFormField(
            controller: descCon,
            decoration: const InputDecoration(
              label: Text('Description'),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            _itemSaved(titleCon.text, descCon.text);
            Navigator.of(context).pop();
          },
          child: const Text('save'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: _checklistFuture,
        builder: _futureBuilder,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addItemTapped,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _itemSaved(String title, String description) {
    DbHelper.addOrUpdateItem(_checklistProvider.selectedChecklistId!, title,
        description, _selectedItemId);
  }
}
