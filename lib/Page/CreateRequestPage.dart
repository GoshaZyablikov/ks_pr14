import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:warehouse_project/Page/RequestsPage.dart';

import '../Model/Warehouse.dart';
import '../Service/AuthService.dart';
import '../main.dart';

class CreateRequestPage extends StatefulWidget {
  @override
  _CreateRequestPageState createState() => _CreateRequestPageState();
}

class _CreateRequestPageState extends State<CreateRequestPage> {
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 1;
  int? _productId;
  // Данные продукта
  String? _nameProduct;
  int? _countProduct;
  double? _weightProduct;

  // Данные заявки
  DateTime? _startDate;
  DateTime? _endDate;
  double? _totalCost;
  int? _statusId;
  int? _warehouseId;


  // Контроллеры для текстовых полей с датами
  TextEditingController _startDateController = TextEditingController();
  TextEditingController _endDateController = TextEditingController();


  @override
  void initState() {
    super.initState();
  }

  // Список складов и выбранный склад
  List<Warehouse> _warehouses = [];
  Warehouse? _selectedWarehouse;

  void calculateTotalCost() {
    if (_startDate != null && _endDate != null && _selectedWarehouse != null) {
      int days = _endDate!.difference(_startDate!).inDays + 1; // +1, чтобы включить последний день
      double totalCost = days * _selectedWarehouse!.rent; // Используйте свойство `rent`
      setState(() {
        _totalCost = totalCost;
      });
    }
  }


  Future<List<Warehouse>> fetchWarehouses() async {
    try {
      final response = await Dio().get('$api/Warehouses');
      print(response.data); // Добавьте логирование данных
      if (response.statusCode == 200) {
        List<Warehouse> warehouses = (response.data as List).map((warehouse) {
          return Warehouse.fromJson(warehouse);
        }).toList();
        return warehouses;
      } else {
        throw Exception('Failed to load warehouses');
      }
    } catch (e) {
      print(e);
      throw Exception('Failed to load warehouses');
    }
  }

// Метод для добавления продукта
  Future<int?> addProduct(String name, int count, double weight) async {
    try {
      final response = await Dio().post(
        '$api/Products',
        data: {
          'nameProduct': name,
          'countProduct': count,
          'weightProduct': weight.toStringAsFixed(2).replaceAll(',', '.'),
          'userId': UserId,
          // Добавьте другие необходимые поля
        },
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data['idProduct']; // Предполагается, что API возвращает id продукта в этом поле
      } else {
        return null; // Ошибка при добавлении продукта
      }
    } catch (e) {
      print(e);
      return null; // Ошибка при выполнении запроса
    }
  }

  // Переменная для хранения id продукта


// Метод для добавления заявки
  Future<bool> addApplication(DateTime startDate, DateTime endDate, int warehouseId, double totalCost) async {
    if (_productId == null) {
      print("Product ID is null");
      return false;
    }
    try {
      final response = await Dio().post(
        '$api/Applications',
        data: {
          'startDate': startDate.toIso8601String(),
          'endDate': endDate.toIso8601String(),
          'warehouseId': warehouseId,
          'totalCost': totalCost.toString().replaceAll(',', '.'),
          'productId': _productId,
          'userId': UserId,
          'statusId': 1,
          // Добавьте другие необходимые поля
        },
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print(e);
      return false;
    }
  }

  // Пример использования этих методов
  void handleAddProductAndApplication() async {
    // Добавление продукта
    _productId = await addProduct(_nameProduct!, _countProduct!, double.parse(_weightProduct!.toString().replaceAll(',', '.')));
    if (_productId != null) {
      // Если продукт успешно добавлен, показываем уведомление
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Продукт успешно добавлен!'),
          duration: Duration(seconds: 2),
        ),
      );
      // Переходим к следующему шагу
      setState(() => _currentStep = 2);
    } else {
      // Если произошла ошибка при добавлении продукта, показываем сообщение об ошибке
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Не удалось добавить продукт. Попробуйте снова.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }



  @override
  void dispose() {
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Создать заявку"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              if (_currentStep == 1) ...[
                TextFormField(
                  decoration: InputDecoration(labelText: 'Название продукта'),
                  onSaved: (value) => _nameProduct = value,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Пожалуйста, введите название продукта';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Количество продукта'),
                  keyboardType: TextInputType.number,
                  onSaved: (value) => _countProduct = int.tryParse(value!),
                  validator: (value) {
                    if (value == null || value.isEmpty || int.tryParse(value) == null) {
                      return 'Введите корректное количество';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Вес продукта'),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  onSaved: (value) => _weightProduct = double.tryParse(value!),
                  validator: (value) {
                    if (value == null || value.isEmpty || double.tryParse(value) == null) {
                      return 'Введите корректный вес';
                    }
                    return null;
                  },
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      handleAddProductAndApplication();
                      setState(() => _currentStep = 2); // Переход ко второму шагу
                    }
                  },
                  child: Text('Далее'),
                ),
              ],
              if (_currentStep == 2) ...[
                TextFormField(
                  controller: _startDateController,
                  decoration: InputDecoration(labelText: 'Дата начала', suffixIcon: Icon(Icons.calendar_today)),
                  readOnly: true,
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(), // Начиная с текущей даты
                      lastDate: DateTime(2025),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        _startDate = pickedDate;

                        _startDateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);

                      });
                    }
                  },
                ),
                TextFormField(
                  controller: _endDateController,
                  decoration: InputDecoration(labelText: 'Дата конца', suffixIcon: Icon(Icons.calendar_today)),
                  readOnly: true,
                  onTap: () async {
                    DateTime initialEndDate = _startDate != null ? _startDate!.add(Duration(days: 1)) : DateTime.now();
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: initialEndDate,
                      firstDate: initialEndDate, // Начиная с даты начала + 1 день или с текущей даты
                      lastDate: DateTime(2025),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        _endDate = pickedDate;

                        _endDateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);

                      });
                      calculateTotalCost(); // Вызов после выбора даты
                    }
                  },
                ),
                FutureBuilder<List<Warehouse>>(
                  future: fetchWarehouses(),
                  builder: (BuildContext context, AsyncSnapshot<List<Warehouse>> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text('Ошибка: ${snapshot.error}');
                    } else {
                      _warehouses = snapshot.data ?? [];
                      return DropdownButtonFormField<int>(
                        value: _selectedWarehouse?.id,
                        onChanged: (int? newValue) {
                          setState(() {
                            _selectedWarehouse = _warehouses.firstWhere((warehouse) => warehouse.id == newValue);
                            _warehouseId = _selectedWarehouse?.id; // Обновляем _warehouseId при выборе склада
                          });
                          calculateTotalCost(); // Вызов метода для расчета стоимости
                        },

                        items: _warehouses.map<DropdownMenuItem<int>>((Warehouse warehouse) {
                          return DropdownMenuItem<int>(
                            value: warehouse.id,
                            child: Text(warehouse.name),
                          );
                        }).toList(),
                        decoration: InputDecoration(
                          labelText: 'Выберите склад',
                        ),
                      );

                  }
                  },
                ),
                if (_totalCost != null) ...[
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      'Итоговая стоимость: ${_totalCost!.toStringAsFixed(2)}', // Форматирование с двумя знаками после запятой
                      style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
                // Дополнительные поля и кнопка сохранения заявки
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      bool applicationAdded = await addApplication(_startDate!, _endDate!, _warehouseId!, _totalCost = double.parse(_totalCost!.toStringAsFixed(2).replaceAll(',', '.')));
                      if (applicationAdded) {
                        // Показываем SnackBar с сообщением об успешном создании заявки
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Заявка успешно создана!'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                        // Возвращаемся на предыдущую страницу после закрытия SnackBar
                        Navigator.pop(context);
                      } else {
                        // Сообщение об ошибке, если заявка не была добавлена
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Не удалось создать заявку. Попробуйте снова.'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  child: Text('Сохранить заявку'),
                ),

              ],
            ],
          ),
        ),
      ),
    );
  }
}
