import 'package:flutter/material.dart';
import 'package:warehouse_project/Page/LoginPage.dart';
import 'package:warehouse_project/Service/AuthService.dart';

class RegistrationPage extends StatefulWidget {

  RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _middleNameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _loginController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Регистрация"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextField(
                controller: _firstNameController,
                decoration: InputDecoration(labelText: 'Фамилия'),
              ),
               TextField(
                controller: _lastNameController,
                decoration: InputDecoration(labelText: 'Имя'),
              ),
               TextField(
                controller: _middleNameController,
                decoration: InputDecoration(labelText: 'Отчество'),
              ),
               TextField(
                controller: _phoneNumberController,
                decoration: InputDecoration(labelText: 'Номер телефона'),
              ),
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
                  bool isRegistered = await _authService.register(
                    _firstNameController.text,
                    _lastNameController.text,
                    _middleNameController.text,
                    _phoneNumberController.text,
                    _loginController.text,
                    _passwordController.text,
                  );
                  if (isRegistered) {
                    // Перенаправляем на страницу авторизации после успешной регистрации
                    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => LoginPage()));
                  } else {
                    // Показать ошибку, если регистрация не удалась
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Ошибка'),
                        content: Text('Произошла ошибка при регистрации'),
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
                child: Text('Зарегистрироваться'),
              ),

              TextButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => LoginPage()));
                },
                child: Text('Авторизоваться'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
