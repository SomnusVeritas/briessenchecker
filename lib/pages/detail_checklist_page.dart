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
  String? pageTitle;
  List<int> selectedItemIndexes = [];

  Checklist? _checklist;
  late Future<List<Object>> _checklistFutures;
  late final ChecklistProvider _checklistProvider;
  TextEditingController titleController = TextEditingController();
  List<Item> _items = [];
  int? _selectedItemId;
  bool _titleEditMode = false;

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

  Future<List<Object>> initFutures(int checklistId) async {
    return Future.wait([
      DbHelper.getChecklistById(checklistId),
      DbHelper.getItemsByChecklistId(checklistId),
    ]);
  }

  Widget _futureBuilder(
      BuildContext context, AsyncSnapshot<List<Object>> snapshot) {
    if (snapshot.hasData) {
      _checklist = snapshot.data!.first as Checklist;
      _items = snapshot.data!.last as List<Item>;
      return StreamBuilder(
        stream: DbHelper.itemsChangeEventStream,
        builder: (BuildContext context,
                AsyncSnapshot<List<Map<String, dynamic>>> snapshot) =>
            _streamBuilder(context, snapshot, _checklist, _items),
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

  Widget? _itemListBuilder(BuildContext context, int index) {
    return ItemListTile(
      title: _items.elementAt(index).title,
      description: _items.elementAt(index).description,
      onTap: () => _itemTapped(index),
      itemSelectionChanged: (isSelected) =>
          _itemSelectionChanged(isSelected, index),
      selectionMode: selectedItemIndexes.isNotEmpty,
    );
  }

  void _itemSelectionChanged(bool isSelected, int index) {
    if (isSelected) {
      setState(() {
        selectedItemIndexes.add(index);
      });
    } else {
      setState(() {
        selectedItemIndexes.remove(index);
      });
    }
  }

  void _onDeleteItemsPressed() {
    List<int> itemIds = [];
    for (final itemIndex in selectedItemIndexes) {
      itemIds.add(_items.elementAt(itemIndex).id!);
    }
    DbHelper.deleteItemsById(itemIds);
    setState(() {
      selectedItemIndexes = [];
    });
  }

  Widget get _pageTitleBuilder {
    if (!_titleEditMode) {
      return GestureDetector(
          onTap: () => setState(() => _titleEditMode = true),
          child: Text(pageTitle ?? ''));
    } else {
      titleController.text = pageTitle ?? '';
      return Expanded(
        child: TextField(
          autofocus: true,
          controller: titleController,
        ),
      );
    }
  }

  void _onTitleChanged(int id, String title) {
    setState(() {
      pageTitle = title;
      _titleEditMode = false;
      DbHelper.updateChecklistTitle(id, title);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _pageTitleBuilder,
        actions: [
          if (selectedItemIndexes.isNotEmpty && !_titleEditMode)
            IconButton(
                onPressed: _onDeleteItemsPressed,
                icon: const Icon(Icons.delete)),
          if (_titleEditMode)
            IconButton(
              onPressed: () => _onTitleChanged(
                _checklist!.id,
                titleController.text,
              ),
              icon: const Icon(Icons.check),
            ),
          if (_titleEditMode)
            IconButton(
                onPressed: () => setState(() => _titleEditMode = false),
                icon: const Icon(Icons.cancel_outlined)),
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

  _streamBuilder(
      BuildContext context,
      AsyncSnapshot<List<Map<String, dynamic>>> snapshot,
      Checklist? checklist,
      List<Item> items) {
    if (pageTitle != _checklist!.title) {
      WidgetsBinding.instance.addPostFrameCallback(
          (_) => setState(() => pageTitle = _checklist!.title));
    }
    if (snapshot.hasData) {
      _items = DbHelper.resToItemList(snapshot.data!);
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
  }
}
