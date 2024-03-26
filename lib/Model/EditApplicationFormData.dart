class EditApplicationFormData {
  DateTime startDate;
  DateTime endDate;
  double totalCost;
  int warehouseId;
  int productId;
  int statusId;
  String productName;
  int countProduct;
  double weightProduct;
  String nameStatus;

  EditApplicationFormData({
    required this.startDate,
    required this.endDate,
    required this.totalCost,
    required this.warehouseId,
    required this.productId,
    required this.statusId,
    required this.productName,
    required this.countProduct,
    required this.weightProduct,
    required this.nameStatus,
  });
}
