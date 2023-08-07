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
  TextEditingController titleController = TextEditingController();

  Checklist? _checklist;
  late Future<List<Object>> _checklistFutures;
  late final ChecklistProvider _checklistProvider;
  List<int> _checkedItemIds = [];
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
      DbHelper.fetchcheckedItemIds(checklistId),
    ]);
  }

  Widget _futureBuilder(
      BuildContext context, AsyncSnapshot<List<Object>> snapshot) {
    if (snapshot.hasData) {
      _checklist = snapshot.data!.elementAt(0) as Checklist;
      _items = snapshot.data!.elementAt(1) as List<Item>;
      _checkedItemIds = snapshot.data!.elementAt(2) as List<int>;
      if (pageTitle == null) {
        WidgetsBinding.instance.addPostFrameCallback((_) => setState(() =>
            pageTitle = _checklist!.title == ''
                ? 'Unnamed ${_checklist!.id}'
                : _checklist!.title));
      }
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
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              label: Text('Title'),
            ),
          ),
          TextFormField(
            controller: descCon,
            onFieldSubmitted: (value) =>
                _itemSaved(titleCon.text, descCon.text),
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
    Navigator.of(context).pop();
  }

  Widget? _itemListBuilder(BuildContext context, int index) {
    Item item = _items.elementAt(index);
    return ItemListTile(
      title: item.title,
      description: item.description,
      onTap: () => _itemTapped(index),
      itemSelectionChanged: (isSelected) =>
          _itemSelectionChanged(isSelected, index),
      selectionMode: selectedItemIndexes.isNotEmpty,
      isChecked: _checkedItemIds.contains(item.id),
      onCheckedChanged: (isChecked) =>
          _onItemCheckedChanged(isChecked, item.id),
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
      return TextField(
        autofocus: true,
        controller: titleController,
        onSubmitted: (value) => _onTitleChanged(
          _checklist!.id,
          titleController.text,
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

  _streamBuilder(
      BuildContext context,
      AsyncSnapshot<List<Map<String, dynamic>>> snapshot,
      Checklist? checklist,
      List<Item> items) {
    if (snapshot.hasData) {
      _items = DbHelper.resToItemList(snapshot.data!);
    }
    return Column(
      children: [
        Text(_checklist!.description),
        Expanded(
          child: ListView.builder(
            itemCount: _items.length,
            itemBuilder: _itemListBuilder,
          ),
        ),
      ],
    );
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

  _onItemCheckedChanged(bool isChecked, int? id) async {
    if (isChecked) {
      await DbHelper.insertCheckedEntry(_checklist!.id, id!);
    } else {
      await DbHelper.deleteCheckedEntry(_checklist!.id, id!);
    }
  }
}
