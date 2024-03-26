import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:warehouse_project/Model/Application.dart';
import 'package:warehouse_project/Model/EditApplicationFormData.dart';
import 'package:warehouse_project/Model/Status.dart';
import 'package:warehouse_project/Model/Warehouse.dart';
import 'package:warehouse_project/Service/AuthService.dart';
import 'package:warehouse_project/main.dart';

class ApplicationDetailsPage extends StatefulWidget {
  final Application application;

  const ApplicationDetailsPage({Key? key, required this.application}) : super(key: key);

  @override
  State<ApplicationDetailsPage> createState() => _ApplicationDetailsPageState();
}

class _ApplicationDetailsPageState extends State<ApplicationDetailsPage> {
  late TextEditingController startDateController;
  late TextEditingController endDateController;

  @override
  void initState() {
    super.initState();
    startDateController = TextEditingController(text: DateFormat('yyyy-MM-dd').format(widget.application.startDate));
    endDateController = TextEditingController(text: DateFormat('yyyy-MM-dd').format(widget.application.endDate));

    fetchWarehouses().then((warehousesList) {
      setState(() {
        warehouses = warehousesList;
      });
    });
    fetchStatus().then((statusList) {
      setState(() {
        status = statusList;
      });
    });
  }
  late List<Warehouse> warehouses;
  late List<Status> status;




  void _deleteApplication(BuildContext context, int applicationId) async {
    // Проверяем, что статус заявки позволяет её удаление
    if (widget.application.nameStatus != "В обработке") {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Удаление недоступно для данного статуса заявки')),
      );
      return;
    }

    // Отображение диалога с подтверждением удаления
    bool confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Подтверждение"),
          content: Text("Вы действительно хотите удалить эту заявку?"),
          actions: <Widget>[
            TextButton(
              child: Text("Отмена"),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: Text("Удалить"),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    ) ?? false; // Возвращаем false по умолчанию, если диалог был закрыт другим способом

    // Если подтверждено удаление
    if (confirmDelete) {
      try {
        // Отправляем запрос на удаление заявки
        final response = await Dio().delete('$api/Applications/$applicationId');
        if (response.statusCode == 204) {
          // Успешно удалено
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Заявка успешно удалена')),
          );
          Navigator.of(context).pop(); // Возвращаемся на предыдущий экран
        } else {
          // Обработка случая, когда удаление не удалось
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Не удалось удалить заявку')),
          );
        }
      } catch (e) {
        // Обработка ошибки при запросе
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка при удалении заявки: $e')),
        );
      }
    }
  }

  double calculateTotalCost(double rentPerDay, DateTime startDate, DateTime endDate) {
    int daysDifference = endDate.difference(startDate).inDays + 1; // +1 чтобы включить последний день в аренду
    return daysDifference * rentPerDay;
  }




 // Загрузите список складов заранее
  Future<List<Warehouse>> fetchWarehouses() async {
    final response = await Dio().get('$api/Warehouses');
    if (response.statusCode == 200) {
      List<Warehouse> warehouses = (response.data as List).map((data) => Warehouse.fromJson(data)).toList();
      return warehouses;
    } else {
      throw Exception('Failed to load warehouses');
    }
  }
  Future<List<Status>> fetchStatus() async {
    final response = await Dio().get('$api/Status');
    if (response.statusCode == 200) {
      List<Status> status = (response.data as List).map((data) => Status.fromJson(data)).toList();
      return status;
    } else {
      throw Exception('Failed to load warehouses');
    }
  }



  Future<bool> updateProduct(int productId, EditApplicationFormData formData) async {
    try {
      final response = await Dio().put(
        '$api/Products/$productId',
        data: {
          "idProduct": productId,
          "nameProduct": formData.productName,
          "countProduct": formData.countProduct,
          "weightProduct": formData.weightProduct.toString().replaceAll(',', '.'),
          "userId": UserId,

        },
      );

      return response.statusCode == 204;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> updateApplication(int applicationId, EditApplicationFormData formData) async {
    try {
      final response = await Dio().put(
        '$api/Applications/$applicationId',
        data: {
          "startDate": formData.startDate.toIso8601String(),
          "endDate": formData.endDate.toIso8601String(),
          "totalCost": formData.totalCost.toString().replaceAll(',', '.'),
          "warehouseId": formData.warehouseId,
          "productId": formData.productId,
          "statusId": formData.statusId,
        },
      );

      return response.statusCode == 204;
    } catch (e) {
      print(e);
      return false;
    }
  }

  void onSaveButtonPressed(BuildContext context, EditApplicationFormData formData, int productId, int applicationId) {
    // Вызов метода обновления продукта
    updateProduct(productId, formData).then((_) {
      // Вызов метода обновления заявки
      updateApplication(applicationId, formData).then((_) {
        // Показать сообщение об успешном обновлении или об ошибке
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Заявка и продукт успешно обновлены')),
        );
        // Возвращение на предыдущий экран после обновления
        Navigator.of(context).pop();
      });
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка при обновлении данных')),
      );
    });
  }




  void _editApplication(BuildContext context, Application application) {
    if (!kIsWeb && application.nameStatus != "В обработке") {
      // Если статус не "В обработке", показываем сообщение и не позволяем редактировать
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Редактирование недоступно для данного статуса заявки')),
      );
      return; // Прекращаем выполнение метода
    }
    final _formKey = GlobalKey<FormState>();
    EditApplicationFormData formData = EditApplicationFormData(
      startDate: application.startDate,
      endDate: application.endDate,
      totalCost: application.totalCost,
      warehouseId: application.warehouseId,
      productName: application.productName,
      countProduct: application.countProduct,
      weightProduct: application.weightProduct,
      nameStatus: application.nameStatus,
      productId: application.productId,
      statusId: application.statusId,
    );

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              title: Text("Редактировать заявку"),
          content: StatefulBuilder( // Используйте StatefulBuilder
          builder: (BuildContext context, StateSetter setState) { // Обратите внимание на параметр StateSetter
            return SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      // Дата начала
                      TextFormField(
                        controller: startDateController,
                        decoration: InputDecoration(labelText: 'Дата начала'),
                        readOnly: true,
                        onTap: () async {
                          DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: formData.startDate,
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2025),
                          );
                          if (pickedDate != null) {
                            setState(() {
                              formData.startDate = pickedDate;
                              startDateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
                            });
                          }
                        },
                      ),

                      TextFormField(
                        controller: endDateController, // Используйте контроллер для управления текстом
                        decoration: InputDecoration(labelText: 'Дата окончания'),
                        readOnly: true,
                        onTap: () async {
                          // Исходная дата для date picker, должна быть либо текущей датой окончания, либо сегодняшней датой, если дата окончания ранее.
                          DateTime initialDate = formData.endDate.isAfter(DateTime.now()) ? formData.endDate : DateTime.now();
                          DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: initialDate,
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2025),
                          );
                          if (pickedDate != null) {
                            setState(() {
                              formData.endDate = pickedDate;
                              endDateController.text = DateFormat('yyyy-MM-dd').format(pickedDate); // Обновите текст в контроллере
                            });
                          }
                        },
                      ),



                      DropdownButtonFormField<int>(
                        value: formData.warehouseId,
                        onChanged: (int? newValue) {
                          setState(() {
                            formData.warehouseId = newValue!;
                            var selectedWarehouse = warehouses.firstWhere((
                                warehouse) => warehouse.id == newValue);
                            formData.totalCost = calculateTotalCost(
                                selectedWarehouse.rent, formData.startDate,
                                formData.endDate);
                          });
                        },
                        items: warehouses.map<DropdownMenuItem<int>>((
                            Warehouse warehouse) {
                          return DropdownMenuItem<int>(
                            value: warehouse.id,
                            child: Text(warehouse.name),
                          );
                        }).toList(),
                        decoration: InputDecoration(
                          labelText: 'Выберите склад',
                        ),
                      ),

// Итоговая стоимость
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          'Итоговая стоимость: ${formData.totalCost
                              .toStringAsFixed(2)}',
                          style: TextStyle(fontSize: 16.0),
                        ),
                      ),
                      if(kIsWeb)
                      DropdownButtonFormField<int>(
                        value: formData.statusId,
                        onChanged: (int? newValues) {
                          setState(() {
                            formData.statusId = newValues!;
                            var selectedStatus = status.firstWhere((
                                status) => status.idStatus == newValues);

                          });
                        },
                        items: status.map<DropdownMenuItem<int>>((
                            Status status) {
                          return DropdownMenuItem<int>(
                            value: status.idStatus,
                            child: Text(status.nameStatus),
                          );
                        }).toList(),
                        decoration: InputDecoration(
                          labelText: 'Выберите статус',
                        ),
                      ),
// Текстовое поле для названия продукта
                      TextFormField(
                        initialValue: formData.productName,
                        decoration: InputDecoration(
                            labelText: 'Название продукта'),
                        onSaved: (String? value) {
                          formData.productName = value!;
                        },
                      ),
                      TextFormField(
                        initialValue: formData.countProduct.toString(),
                        decoration: InputDecoration(labelText: 'Количество продукта'),
                        keyboardType: TextInputType.number,
                        onSaved: (String? value) {
                          formData.countProduct = int.tryParse(value!)!;
                        },
                      ),
                      TextFormField(
                        initialValue: formData.weightProduct.toString(),
                        decoration: InputDecoration(labelText: 'Вес продукта'),
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                        onSaved: (String? value) {
                          formData.weightProduct = double.tryParse(value!)!;

                        },
                      ),
                      // Добавить поля для количества продукта, веса и статуса по аналогии
                    ],
                  ),
                )
            );
          }
          ),

          actions: <Widget>[
            TextButton(
              child: Text("Отмена"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text("Сохранить"),
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();

                  // Обновление продукта
                  bool productUpdated = await updateProduct(widget.application.productId, formData);

                  // Обновление заявки, если продукт успешно обновлен
                  bool applicationUpdated = false;
                  if (productUpdated) {
                    applicationUpdated = await updateApplication(widget.application.id, formData);
                  }

                  // Проверка результатов и показ уведомления
                  if (productUpdated && applicationUpdated) {
                    // Обновляем данные заявки
/*
                    await fetchApplicationDetails(widget.application.id);
*/

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Заявка и продукт успешно обновлены')),
                    );
                    // Закрываем диалог
                    Navigator.of(context).pop();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Ошибка при обновлении данных')),
                    );
                  }

                }
              },
            ),



          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Детали заявки"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text("Продукт: ${widget.application.productName}", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text("Дата начала: ${DateFormat('yyyy-MM-dd').format(widget.application.startDate)}"),
            Text("Дата окончания: ${DateFormat('yyyy-MM-dd').format(widget.application.endDate)}"),
            Text("Стоимость аренды: ${widget.application.totalCost.toStringAsFixed(2)}"),
            Text("Склад: ${widget.application.warehouseName}"),
            Text("Количество продукта: ${widget.application.countProduct}"),
            Text("Вес продукта: ${widget.application.weightProduct}"),
            Text("Статус: ${widget.application.nameStatus}"),
            SizedBox(height: 16), // Добавить немного пространства
            Row(
              children: <Widget>[
                IconButton(
                  icon: Icon(Icons.edit, color: Colors.blue),
                  onPressed: () {
                    // Функционал изменения заявки
                    _editApplication(context, widget.application);
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    // Функционал удаления заявки
                    _deleteApplication(context, widget.application.id);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  @override
  void dispose() {
    startDateController.dispose();
    endDateController.dispose();
    super.dispose();
  }

}
