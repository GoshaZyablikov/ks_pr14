import 'package:flutter/material.dart';
import 'package:warehouse_project/Model/Application.dart';
import 'package:warehouse_project/Service/ApplicationService.dart';
import 'package:warehouse_project/Service/ShopService.dart';

class AddProductPage extends StatefulWidget {
  @override
  _AddProductPageState createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();
  final _priceController = TextEditingController();
  List<Application> applications = [];
  List<Application> filteredApplications = [];
  String? selectedProductId;

  @override
  void initState() {
    super.initState();
    ApplicationService().fetchApplications().then((apps) {
      setState(() {
        applications = apps;
        filteredApplications = applications.where((app) => app.nameStatus == "Завершено").toList();
      });
    });
  }

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _addProduct() async {
    if (_formKey.currentState!.validate()) {
      // Здесь должен быть ваш код для отправки данных на сервер
      // Используйте selectedProductId и _priceController.text для формирования запроса
      bool result = await ShopService().addProduct(int.parse(selectedProductId!), double.parse(_priceController.text));
      if (result) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Продукт успешно добавлен')));
        // Очистка полей или действие после успешного добавления
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка при добавлении продукта')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Добавить товар'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              DropdownButtonFormField<String>(
                value: selectedProductId,
                hint: Text('Выберите продукт'),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedProductId = newValue;
                  });
                },
                items: filteredApplications.map<DropdownMenuItem<String>>((Application application) {
                  return DropdownMenuItem<String>(
                    value: application.productId.toString(),
                    child: Text(application.productName),
                  );
                }).toList(),
              ),
              TextFormField(
                controller: _priceController,
                decoration: InputDecoration(labelText: 'Цена'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Пожалуйста, введите цену';
                  }
                  return null;
                },
              ),
              ElevatedButton(
                onPressed: _addProduct,
                child: Text('Добавить'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
