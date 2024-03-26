class Application {
  final int id;
  final DateTime startDate;
  final DateTime endDate;
  final double totalCost;
  final String warehouseName;
  final String productName;
  final int countProduct;
  final int warehouseId;
  final int productId;
  final int statusId;
  final double weightProduct;
  final String nameStatus;
  final String? firstName;
  final String? lastName;
  final String? middleName;
  final String? phoneNumber;

  Application({
    required this.id,
    required this.startDate,
    required this.endDate,
    required this.totalCost,
    required this.warehouseName,
    required this.productName,
    required this.countProduct,
    required this.warehouseId,
    required this.productId,
    required this.statusId,
    required this.weightProduct,
    required this.nameStatus,
     this.firstName,
     this.lastName,
     this.middleName,
     this.phoneNumber,
  });

  factory Application.fromJson(Map<String, dynamic> json) {
    return Application(
      id: json['idApplications'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      totalCost: json['totalCost'].toDouble(), // Убедитесь, что это поле имеет тип double
      warehouseName: json['warehouseName'],
      productName: json['productName'],
      countProduct: json['countProduct'],
      warehouseId: json['warehouseId'],
      productId: json['productId'],
      statusId: json['statusId'],
      weightProduct: json['weightProduct'].toDouble(), // Убедитесь, что это поле имеет тип double
      nameStatus: json['nameStatus'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      middleName: json['middleName'],
      phoneNumber: json['phoneNumber'],
    );
  }
}
