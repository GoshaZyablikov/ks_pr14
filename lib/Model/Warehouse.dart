class Warehouse {
  final int id;
  final String name;
  final String description;
  final String openingHours;
  final double rent;
  final double discharge;
  final int? pictureId;

  Warehouse({
    required this.id,
    required this.name,
    required this.description,
    required this.openingHours,
    required this.rent,
    required this.discharge,
    this.pictureId,
  });

  factory Warehouse.fromJson(Map<String, dynamic> json) {
    return Warehouse(
      id: json['idWarehouses'],
      name: json['nameWarehouse'],
      description: json['descriptionWarehouse'],
      openingHours: json['warehouseOpeningHours'],
      rent: json['rent'].toDouble(),
      discharge: json['discharge'].toDouble(),
      pictureId: json['pictureId'],
    );
  }
}