class ShopItem {
  final int idShop;
  final int productId;
  final double price;
  final String productName; // Новое свойство

  ShopItem({
    required this.idShop,
    required this.productId,
    required this.price,
    required this.productName, // Не забудьте добавить сюда
  });

  factory ShopItem.fromJson(Map<String, dynamic> json) {
    return ShopItem(
      idShop: json['idShop'],
      productId: json['productId'],
      price: json['price'].toDouble(),
      productName: json['productName'], // Инициализация из JSON
    );
  }
}
