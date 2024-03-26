import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:warehouse_project/Page/LoginPage.dart';
import 'package:warehouse_project/main.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isDarkTheme = false;

  @override
  void initState() {
    super.initState();
    _loadThemePreference();
  }

  Future<void> _loadThemePreference() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkTheme = prefs.getBool('isDarkTheme') ?? false;
    });
  }

  Future<void> _saveThemePreference(bool value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkTheme', value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Настройки'),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: Text('Темная тема'),
            value: _isDarkTheme,
            onChanged: (value) async {
              setState(() {
                _isDarkTheme = value;
              });
              await _saveThemePreference(value);
              MyApp.of(context)!.setTheme(value ? ThemeData.dark() : ThemeData.light());
            },
          ),
          ElevatedButton(
            child: Text('Выйти из аккаунта'),
            onPressed: () async {
              await logOut(context);
            },
          ),
        ],
      ),
    );
  }

  Future<void> logOut(BuildContext context) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_id');

    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => LoginPage()), (Route<dynamic> route) => false);
  }
}
