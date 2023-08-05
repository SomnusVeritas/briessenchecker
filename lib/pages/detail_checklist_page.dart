import 'package:briessenchecker/models/checklist.dart';
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
  late final ChecklistProvider checklistProvider;
  late Future<Checklist> checklistFuture;

  @override
  void initState() {
    super.initState();
    checklistProvider = Provider.of<ChecklistProvider>(context, listen: false);
    checklistFuture =
        DbHelper.getChecklistById(checklistProvider.selectedChecklistId!);
  }

  @override
  void dispose() {
    super.dispose();
    checklistProvider.updateSelectedChecklist(null, silent: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: checklistFuture,
        builder: _futureBuilder,
      ),
    );
  }

  Widget _futureBuilder(
      BuildContext context, AsyncSnapshot<Checklist> snapshot) {
    if (snapshot.hasData) {
      return Column(
        children: [
          Text(snapshot.data!.title),
          Text(snapshot.data!.description),
        ],
      );
    } else {
      return const CircularProgressIndicator();
    }
  }
}
