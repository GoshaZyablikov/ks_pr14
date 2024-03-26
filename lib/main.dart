import 'package:flutter/material.dart';
import "package:shared_preferences/shared_preferences.dart";
import 'package:warehouse_project/Page/LoginPage.dart';
import 'package:warehouse_project/Page/NavigationBar.dart';
String? UserId = '';
void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Убедитесь, что инициализация выполнена

  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final String? authToken = prefs.getString('auth_token');
  UserId = prefs.getString('user_id');
  runApp(MyApp(startPage: authToken == null ? LoginPage() : MainPage()));
}

class MyApp extends StatefulWidget {
  final Widget startPage;

  MyApp({required this.startPage});

  static _MyAppState? of(BuildContext context) => context.findAncestorStateOfType<_MyAppState>();

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeData _themeData = ThemeData.light();

  void setTheme(ThemeData themeData) {
    setState(() {
      _themeData = themeData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: _themeData,
      home: widget.startPage,
    );
  }
}
