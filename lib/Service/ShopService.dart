import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:warehouse_project/Model/ShopItem.dart';
import 'package:warehouse_project/Service/AuthService.dart';

class ShopService {
  final String apiUrl = '$api/Shops';

  Future<List<ShopItem>> fetchShopItems() async {
    try {
      final response = await Dio().get(apiUrl);
      if (response.statusCode == 200) {
        List<dynamic> body = response.data;
        List<ShopItem> shopItems = body.map((dynamic item) => ShopItem.fromJson(item)).toList();
        return shopItems;
      } else {
        throw "Unable to retrieve products.";
      }
    } catch (e) {
      throw Exception('Failed to load products');
    }
  }

  Future<bool> addProduct(int productId, double price) async {
    try {
      final response = await Dio().post(
        apiUrl,
        data: jsonEncode({
          'productId': productId,
          'price': price,
        }),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      // Проверяем, успешно ли выполнен запрос
      // Статус код 200 или 201 обычно указывает на успешное выполнение
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      // Логирование или обработка ошибки
      print(e.toString());
      return false;
    }
  }
}
