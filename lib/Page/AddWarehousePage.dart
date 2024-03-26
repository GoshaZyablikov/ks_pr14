import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../Service/AuthService.dart';

class AddWarehousePage extends StatefulWidget {
  @override
  _AddWarehousePageState createState() => _AddWarehousePageState();
}

class _AddWarehousePageState extends State<AddWarehousePage> {
  final _formKey = GlobalKey<FormState>();
  String? name;
  String? description;
  String? openingHours;
  double? rent;
  double? discharge;
  XFile? _image;
  Uint8List? _imageBytes;

  final ImagePicker _picker = ImagePicker();
  final Dio _dio = Dio();

  // Остальная часть вашего состояния...

  Future pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        _imageBytes = bytes;
        _image = image;
      });
    }
  }

  Future<void> uploadData() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    try {
      int? pictureId;

      // Шаг 1: Загрузка изображения
      if (_image != null) {
        final bytes = await _image!.readAsBytes();
        String fileName = _image!.name;

        FormData formData = FormData.fromMap({
          "file": MultipartFile.fromBytes(bytes, filename: fileName),
        });

        var imageResponse = await _dio.post(
          "$api/Pictures",
          data: formData,
        );

        if (imageResponse.statusCode == 201) {
          pictureId = imageResponse.data['idPicture'];
        } else {
          throw Exception("Failed to upload image");
        }
      }

      // Шаг 2: Добавление склада с ID изображения
      if (pictureId != null) {
        var warehouseResponse = await _dio.post(
          "$api/Warehouses",
          data: {
            "nameWarehouse": name,
            "descriptionWarehouse": description,
            "warehouseOpeningHours": openingHours,
            "rent": rent.toString(),
            "discharge": discharge.toString(),
            "pictureId": pictureId,
          },
        );

        if (warehouseResponse.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Склад успешно добавлен!')));
          Navigator.of(context).pop(); // Возвращение на предыдущий экран
        } else {
          throw Exception("Failed to add warehouse");
        }
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка при отправке данных: ${e.toString()}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Добавить склад'),
      ),
      body: Padding(
        padding: EdgeInsets.all(12.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                TextFormField(
                  decoration: InputDecoration(labelText: 'Название склада'),
                  onSaved: (value) => name = value,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Пожалуйста, введите название';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Описание склада'),
                  onSaved: (value) => description = value,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Пожалуйста, введите описание';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Часы работы'),
                  onSaved: (value) => openingHours = value,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Пожалуйста, введите часы работы';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Стоимость аренды'),
                  keyboardType: TextInputType.number,
                  onSaved: (value) => rent = double.tryParse(value!),
                  validator: (value) {
                    if (value == null || value.isEmpty || double.tryParse(value) == null) {
                      return 'Введите корректную стоимость аренды';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Стоимость разгрузки'),
                  keyboardType: TextInputType.number,
                  onSaved: (value) => discharge = double.tryParse(value!),
                  validator: (value) {
                    if (value == null || value.isEmpty || double.tryParse(value) == null) {
                      return 'Введите корректную стоимость разгрузки';
                    }
                    return null;
                  },
                ),
                OutlinedButton(
                  onPressed: pickImage,
                  child: Text('Выбрать изображение'),
                ),
                // Отображаем изображение в зависимости от платформы
                _image != null
                    ? kIsWeb
                    ? _imageBytes != null
                    ? Image.memory(_imageBytes!)
                    : Text("Изображение не выбрано")
                    : Image.file(File(_image!.path))
                    : Text("Изображение не выбрано"),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    uploadData();                  },
                  child: Text('Добавить склад'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
