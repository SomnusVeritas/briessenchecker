import 'package:briessenchecker/models/checklist.dart';
import 'package:briessenchecker/pages/detail_checklist_page.dart';
import 'package:briessenchecker/services/checklist_provider.dart';
import 'package:briessenchecker/services/dbhelper.dart';
import 'package:briessenchecker/services/scaffold_messenger.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  static const routeName = '/dashboard';

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  Future<List<Checklist>> checklistFuture = DbHelper.fetchChecklist;
  late List<Checklist> checklists;
  late ChecklistProvider checklistProvider;
  late Stream<List<Map<String, dynamic>>> clChangeStream;

  int? _selectedChecklistIndex;

  FloatingActionButton get _fabBuilder {
    if (_selectedChecklistIndex == null) {
      return FloatingActionButton(
        onPressed: _onAddTapped,
        child: const Icon(Icons.add),
      );
    }
    return FloatingActionButton(
      onPressed: _onDeleteTapped,
      backgroundColor: Theme.of(context).colorScheme.error,
      child: Icon(Icons.delete, color: Theme.of(context).colorScheme.onError),
    );
  }

  Widget _futureBuilder(
      BuildContext context, AsyncSnapshot<List<Checklist>> snapshot) {
    if (snapshot.hasData) {
      checklists = snapshot.data!;
      return StreamBuilder(
          stream: DbHelper.checklistChangeEventStream,
          builder: (context, snapshot) =>
              _streamBuilder(context, snapshot, checklists));
    } else if (snapshot.hasError) {
      return Text(snapshot.error.toString());
    } else {
      return const CircularProgressIndicator();
    }
  }

  Widget? _listBuilder(BuildContext context, int index, List<Checklist> list) {
    Checklist cl = list.elementAt(index);
    return ListTile(
      title: Text(cl.title == '' ? 'Unnamed ${cl.id}' : cl.title),
      subtitle: Text(cl.description),
      onTap: () => _onListEntryTapped(cl, index),
      onLongPress: () => _onLongPress(index),
      selected: _selectedChecklistIndex == index,
    );
  }

  void _onAddTapped() {
    DbHelper.addOrUpdateChecklist(null).then((id) {
      checklistProvider.updateSelectedChecklist(id, silent: true);
    }).whenComplete(
        () => Navigator.of(context).pushNamed(DetailChecklistPage.routeName));
  }

  void _onListEntryTapped(Checklist cl, int index) {
    if (_selectedChecklistIndex == index) {
      setState(() => _selectedChecklistIndex = null);
    } else if (_selectedChecklistIndex != null) {
      setState(() => _selectedChecklistIndex = index);
    } else {
      checklistProvider.updateSelectedChecklist(cl.id, silent: true);
      Navigator.of(context).pushNamed(DetailChecklistPage.routeName);
    }
  }

  void _onLongPress(int index) {
    setState(() {
      _selectedChecklistIndex = index;
    });
  }

  void _onDeleteTapped() {
    final checklist = checklists.elementAt(_selectedChecklistIndex!);
    DbHelper.deleteChecklistByid(checklist.id);
    if (!DbHelper.isOwner(checklist.ownerId)) {
      Messenger.showError(
          context, 'Can\'t delete checklists that aren\'t yours');
    }
    setState(() {
      _selectedChecklistIndex = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    checklistProvider = Provider.of<ChecklistProvider>(context, listen: true);
    clChangeStream = DbHelper.checklistChangeEventStream;
    clChangeStream.listen(_onClChanged);
    return Scaffold(
        appBar: AppBar(
          title: const Text('Brießenchecker9000'),
          actions: [
            IconButton(
              onPressed: () => DbHelper.logout(),
              icon: const Icon(Icons.logout),
            )
          ],
        ),
        body: FutureBuilder(
          future: checklistFuture,
          builder: _futureBuilder,
        ),
        floatingActionButton: _fabBuilder);
  }

  void _onClChanged(List<Map<String, dynamic>> res) {
    checklists = DbHelper.resToChecklistList(res);
  }

  Widget _streamBuilder(
      BuildContext context,
      AsyncSnapshot<List<Map<String, dynamic>>> snapshot,
      List<Checklist> checklists) {
    if (snapshot.hasData) {
      checklists = DbHelper.resToChecklistList(snapshot.data!);
    }

    return ListView.builder(
      itemCount: checklists.length,
      itemBuilder: (context, index) => _listBuilder(context, index, checklists),
    );
  }
}
