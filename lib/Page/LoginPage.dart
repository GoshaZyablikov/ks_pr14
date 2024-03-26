import 'package:flutter/material.dart';
import 'package:warehouse_project/Page/NavigationBar.dart';
import 'package:warehouse_project/Page/RegistrationPage.dart';
import 'package:warehouse_project/Service/AuthService.dart';

class LoginPage extends StatefulWidget {


  LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _loginController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Авторизация"),
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _loginController,
              decoration: InputDecoration(labelText: 'Логин'),
            ),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Пароль'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                bool isLoggedIn = await _authService.login(_loginController.text, _passwordController.text);
                if (isLoggedIn) {
                  // Заменяем текущую страницу на MainPage в стеке навигации
                  Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => MainPage()));
                } else {
                  // Показать ошибку, если авторизация не удалась
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Ошибка'),
                      content: Text('Неверные учетные данные'),
                      actions: <Widget>[
                        TextButton(
                          child: Text('OK'),
                          onPressed: () {
                            Navigator.of(context).pop(); // Закрывает диалоговое окно
                          },
                        ),
                      ],
                    ),
                  );
                }
              },
              child: Text('Авторизоваться'),
            ),

            TextButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => RegistrationPage()));
              },
              child: Text('Зарегистрироваться'),
            ),
          ],
        ),
      ),
    );
  }
}

