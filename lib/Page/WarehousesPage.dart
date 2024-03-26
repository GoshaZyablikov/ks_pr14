import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:warehouse_project/Page/AddWarehousePage.dart';
import 'package:warehouse_project/Page/SettingsPage.dart';
import 'package:warehouse_project/Service/AuthService.dart';

import 'WarehouseProductsPage.dart';

class WarehousesPage extends StatefulWidget {
  @override
  _WarehousesPageState createState() => _WarehousesPageState();
}

class _WarehousesPageState extends State<WarehousesPage> {
  Future<List<dynamic>> fetchWarehouses() async {
    final response = await Dio().get('$api/Warehouses');

    if (response.statusCode == 200) {
      return response.data;
    } else {
      throw Exception('Failed to load warehouses');
    }
  }

  Future<Uint8List?> fetchWarehouseImage(int? pictureId) async {
    if (pictureId == null) {
      return null;
    }

    try {
      final response = await Dio().get(
        '$api/Pictures/$pictureId',
        options: Options(responseType: ResponseType.bytes),
      );
      return response.data;
    } catch (e) {
      print('Failed to load image: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var cardWidth = screenWidth < 600 ? screenWidth * 0.8 : screenWidth / 3 - 20; // Для экранов меньше 600px карточка займет 80% ширины, иначе треть ширины экрана минус отступы

    return Scaffold(
      appBar: AppBar(
        title: Text('Склады'),
        actions: <Widget>[
          PopupMenuButton<int>(
            onSelected: (item) => onSelected(context, item),
            itemBuilder: (context) => [
              if(kIsWeb)
                PopupMenuItem<int>(
                value: 0,
                child: Text('Добавить склад'),
              ),
              PopupMenuItem<int>(
                value: 1,
                child: Text('Настройки'),
              ),
            ],
          )

        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: fetchWarehouses(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Ошибка: ${snapshot.error}"));
          } else {
            return GridView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: snapshot.data!.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 1, // 3 колонки для широких экранов, 1 колонка для узких
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: (cardWidth / 300), // Высота карточки
              ),
              itemBuilder: (context, index) {
                var warehouse = snapshot.data![index];
                return InkWell(
                    onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => WarehouseProductsPage(warehouseId: warehouse['idWarehouses']),
                  ));
                },
                child: Card(
                  elevation: 5,
                  child: Column(
                    children: [
                      FutureBuilder<Uint8List?>(
                        future: fetchWarehouseImage(warehouse['pictureId']),
                        builder: (context, imageSnapshot) {
                          if (imageSnapshot.connectionState == ConnectionState.waiting) {
                            return CircularProgressIndicator();
                          } else if (imageSnapshot.hasData) {
                            return Image.memory(imageSnapshot.data!, width: cardWidth, height: 200, fit: BoxFit.cover);
                          } else {
                            return SizedBox(height: 200, child: Center(child: Text('Нет изображения')));
                          }
                        },
                      ),
                      ListTile(
                        title: Text(warehouse['nameWarehouse']),
                        subtitle: Text(warehouse['descriptionWarehouse']),
                      ),
                    ],
                  ),
                )
                );
              },
            );
          }
        },
      ),
    );
  }

  void onSelected(BuildContext context, int item) {
    switch (item) {
      case 0:
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => AddWarehousePage()));
        break;
      case 1:
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => SettingsPage()));
        break;
    }
  }

}
