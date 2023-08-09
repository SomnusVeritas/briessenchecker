import 'package:briessenchecker/pages/detail_checklist_page.dart';
import 'package:briessenchecker/pages/edit_checklist_page.dart';
import 'package:briessenchecker/services/checklist_provider.dart';
import 'package:briessenchecker/services/dbhelper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'pages/dashboard_page.dart';
import 'pages/landing_page.dart';
import 'pages/login_page.dart';

void main() async {
  await dotenv.load(fileName: 'secrets.env');
  await DbHelper.init();
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(
      create: (_) => ChecklistProvider(),
    ),
    StreamProvider.value(
      value: DbHelper.checklistChangeEventStream,
      initialData: null,
    ),
    StreamProvider.value(
        value: DbHelper.selectedChecklistChangeEventStreamById,
        initialData: null),
  ], child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    DbHelper.initStreams(context);

    return MaterialApp(
      title: 'Brisenchecker',
      theme: ThemeData.dark(
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        LandingPage.routeName: (context) => const LandingPage(),
        LoginPage.routeName: (context) => const LoginPage(),
        DashboardPage.routeName: (context) => const DashboardPage(),
        EditChecklistPage.routeName: (context) => const EditChecklistPage(),
        DetailChecklistPage.routeName: (context) => const DetailChecklistPage(),
      },
    );
  }
}
