import 'package:briessenchecker/models/checklist.dart';
import 'package:briessenchecker/models/listitem.dart';
import 'package:briessenchecker/services/checklist_provider.dart';
import 'package:briessenchecker/services/dbhelper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/item_list_tile.dart';

class DetailChecklistPage extends StatefulWidget {
  const DetailChecklistPage({super.key});

  static const routeName = '/detail';

  @override
  State<DetailChecklistPage> createState() => _DetailChecklistPageState();
}

class _DetailChecklistPageState extends State<DetailChecklistPage> {
  late Future<List<Object>> _checklistFutures;
  late final ChecklistProvider _checklistProvider;
  Checklist? _checklist;
  List<Item> _items = [];
  int? _selectedItemId;
  String? pageTitle;
  List<int> selectedItems = [];

  @override
  void dispose() {
    super.dispose();
    _checklistProvider.updateSelectedChecklist(null, silent: true);
  }

  @override
  void initState() {
    super.initState();
    _checklistProvider = Provider.of<ChecklistProvider>(context, listen: false);
    _checklistFutures = initFutures(_checklistProvider.selectedChecklistId!);
  }

  Widget _futureBuilder(
      BuildContext context, AsyncSnapshot<List<Object>> snapshot) {
    if (snapshot.hasData) {
      _checklist = snapshot.data!.first as Checklist;
      _items = snapshot.data!.last as List<Item>;
      String title = _checklist!.title;
      if (pageTitle == null) {
        WidgetsBinding.instance
            .addPostFrameCallback((_) => setState(() => pageTitle = title));
      }
      return Column(
        children: [
          Text(_checklist!.description),
          SizedBox(
            width: 500,
            height: 500,
            child: ListView.builder(
              itemCount: _items.length,
              itemBuilder: _itemListBuilder,
            ),
          ),
        ],
      );
    } else if (snapshot.hasError) {
      return Text('Ooooops, ${snapshot.error}');
    } else {
      return const CircularProgressIndicator();
    }
  }

  void _addItemTapped() {
    showDialog(
        context: context,
        builder: (context) => _itemDetailDialog(context, null));
  }

  void _itemTapped(int index) {
    _selectedItemId = _items.elementAt(index).id;
    showDialog(
        context: context,
        builder: (context) => _itemDetailDialog(context, index)).whenComplete(
      () => _selectedItemId = null,
    );
  }

  Widget _itemDetailDialog(BuildContext context, int? index) {
    TextEditingController titleCon = TextEditingController();
    TextEditingController descCon = TextEditingController();
    if (_selectedItemId != null) {
      final item = _items.elementAt(index!);
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

  void _itemSaved(String title, String description) {
    DbHelper.addOrUpdateItem(
      _checklistProvider.selectedChecklistId!,
      title,
      description,
      _selectedItemId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(pageTitle ?? ''),
        actions: [
          if (selectedItems.isNotEmpty)
            IconButton(
                onPressed: _onDeleteItemsPressed,
                icon: const Icon(Icons.delete))
        ],
      ),
      body: FutureBuilder(
        future: _checklistFutures,
        builder: _futureBuilder,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addItemTapped,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget? _itemListBuilder(BuildContext context, int index) {
    return ItemListTile(
      title: _items.elementAt(index).title,
      description: _items.elementAt(index).description,
      onTap: () => _itemTapped(index),
      itemSelectionChanged: (isSelected) =>
          _itemSelectionChanged(isSelected, index),
      selectionMode: selectedItems.isNotEmpty,
    );
  }

  Future<List<Object>> initFutures(int checklistId) async {
    return Future.wait([
      DbHelper.getChecklistById(checklistId),
      DbHelper.getItemsByChecklistId(checklistId),
    ]);
  }

  void _itemSelectionChanged(bool isSelected, int index) {
    if (isSelected) {
      setState(() {
        selectedItems.add(index);
      });
    } else {
      setState(() {
        selectedItems.remove(index);
      });
    }
  }

  void _onDeleteItemsPressed() {}
}
