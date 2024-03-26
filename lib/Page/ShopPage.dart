import 'package:flutter/material.dart';
import 'package:warehouse_project/Model/ShopItem.dart';
import 'package:warehouse_project/Page/AddProductPage.dart';
import 'package:warehouse_project/Service/ShopService.dart';


class ShopPage extends StatefulWidget {
  @override
  _ShopPageState createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  late Future<List<ShopItem>> shopItems;

  @override
  void initState() {
    super.initState();
    shopItems = ShopService().fetchShopItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Магазин'),
        actions: <Widget>[
          PopupMenuButton<int>(
            onSelected: (item) => onItemSelected(item, context),
            itemBuilder: (context) => [
              PopupMenuItem<int>(
                value: 0,
                child: Text('Добавить товар'),
              ),
              // Другие пункты меню, если они вам нужны
            ],
          ),
        ],
      ),

      body: FutureBuilder<List<ShopItem>>(
        future: shopItems,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                ShopItem item = snapshot.data![index];
                return ListTile(
                  title: Text(item.productName), // Изменено с 'Product ID: ${item.productId}'
                  subtitle: Text('Цена: ${item.price}'),
                );
              },
            );

          }
        },
      ),
    );
  }

  void onItemSelected(int item, BuildContext context) {
    switch (item) {
      case 0:
      // Открываем страницу для добавления товара
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AddProductPage()),
        );
        break;
    }
  }

}
