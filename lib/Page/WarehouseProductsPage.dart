import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../Service/AuthService.dart';
import '../main.dart';

class WarehouseProductsPage extends StatefulWidget {
  final int warehouseId;
  WarehouseProductsPage({Key? key, required this.warehouseId}) : super(key: key);

  @override
  _WarehouseProductsPageState createState() => _WarehouseProductsPageState();
}

class _WarehouseProductsPageState extends State<WarehouseProductsPage> {

  Future<List<dynamic>> fetchProducts() async {
    String url;
    if (kIsWeb) {
      // Для веба
      url = '$api/Warehouses/${widget.warehouseId}/Products';
    } else {
      // Для мобильных устройств, используем userId
      url = '$api/Warehouses/${widget.warehouseId}/Products/user/$UserId';
    }

    final response = await Dio().get(url);

    if (response.statusCode == 200) {
      return response.data;
    } else {
      throw Exception('Failed to load products');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Товары склада'),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: fetchProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Ошибка: ${snapshot.error}"));
          } else {
            return ListView.separated(
              padding: EdgeInsets.all(10),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                var product = snapshot.data![index];
                return Card(
                  elevation: 4,
                  child: ListTile(
                    title: Text(product['productName'], style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Количество: ${product['countProduct']}'),
                        Text('Вес: ${product['weightProduct']} кг'),
                        Text('Статус: ${product['nameStatus'] ?? "Не указан"}'),
                        Text('Склад: ${product['warehouseName']}'),
                        Text('Клиент: ${product['firstName']} ${product['lastName']} ${product['middleName']}'),
                        Text('Номер телефона: ${product['phoneNumber']}'),
                      ],
                    ),
                    isThreeLine: true,
                  ),
                );
              },
              separatorBuilder: (context, index) => Divider(),
            );
          }
        },
      ),
    );
  }
}
