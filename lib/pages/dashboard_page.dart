import 'package:briessenchecker/models/checklist.dart';
import 'package:briessenchecker/pages/detail_checklist_page.dart';
import 'package:briessenchecker/services/checklist_provider.dart';
import 'package:briessenchecker/services/dbhelper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});
  static const routeName = '/dashboard';

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final Future<List<Checklist>> checklistFuture = DbHelper.fetchChecklist;
  late ChecklistProvider checklistProvider;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    checklistProvider = Provider.of<ChecklistProvider>(context, listen: true);
    return Scaffold(
      body: FutureBuilder(
        future: checklistFuture,
        builder: _futureBuilder,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onAddTapped,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _futureBuilder(
      BuildContext context, AsyncSnapshot<List<Checklist>> snapshot) {
    if (snapshot.hasData) {
      return ListView.builder(
        itemCount: snapshot.data!.length,
        itemBuilder: (context, index) =>
            _listBuilder(context, index, snapshot.data!),
      );
    } else {
      return const CircularProgressIndicator();
    }
  }

  Widget? _listBuilder(BuildContext context, int index, List<Checklist> list) {
    Checklist cl = list.elementAt(index);
    return ListTile(
      title: Text(cl.title),
      subtitle: Text(cl.description),
    );
  }

  void _onAddTapped() {
    DbHelper.addChecklist().then((id) {
      checklistProvider.updateSelectedChecklist(id, silent: true);
    });
    Navigator.of(context).pushNamed(DetailChecklistPage.routeName);
  }
}
