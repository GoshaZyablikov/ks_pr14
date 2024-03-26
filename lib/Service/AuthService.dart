import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';

String api = 'http://192.168.1.71:5078/api';

class AuthService {
  Dio _dio = new Dio();

  Future<bool> register(String firstName, String lastName, String middleName, String phoneNumber, String loginUser, String passwordUser) async {
    try {
      Response response = await _dio.post(
        '$api/Users/register',
        data: {
          'firstName': firstName,
          'lastName': lastName,
          'middleName': middleName,
          'phoneNumber': phoneNumber,
          'loginUser': loginUser,
          'passwordUser': passwordUser,
          'roleId': 2,
          'fcmToken': 'string'
        },
      );

      if (response.statusCode == 201) {
        String token = response.data['token'];
        await _saveToken(token);
        return true;
      }

      return false;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> login(String loginUser, String passwordUser) async {
    try {
      Response response = await _dio.post(
        '$api/Users/login',
        data: {
          'login': loginUser,
          'password': passwordUser,
        },
      );

      if (response.statusCode == 200) {
        String token = response.data['token'];
        int userId = response.data['userId'];
        UserId = userId.toString();
        await _saveToken(token);
        await _saveUserId(userId.toString()); // Сохраняем ID пользователя как строку
        return true;
      }

      return false;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<void> _saveUserId(String userId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_id', userId);
  }


  Future<void> _saveToken(String token) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }
}
