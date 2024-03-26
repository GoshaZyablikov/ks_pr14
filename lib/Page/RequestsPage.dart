import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:warehouse_project/Model/Application.dart';
import 'package:warehouse_project/Page/ApplicationDetailsPage.dart';
import 'package:warehouse_project/Page/CreateRequestPage.dart';
import 'package:warehouse_project/Service/AuthService.dart';

import '../main.dart';

class RequestsPage extends StatefulWidget {
  const RequestsPage({super.key});

  @override
  State<RequestsPage> createState() => _RequestsPageState();
}

class _RequestsPageState extends State<RequestsPage> {

  Future<List<Application>> fetchApplications() async {
   String endpoint;
    if(kIsWeb){
      endpoint = '$api/Applications';

    }else{
      endpoint = '$api/Applications/user/$UserId';
    }
    var response = await  Dio().get(endpoint);
    if (response.statusCode == 200) {
      List<Application> applications = (response.data as List)
          .map((applicationJson) => Application.fromJson(applicationJson))
          .toList();
      return applications;
    } else {
      throw Exception('Failed to load applications');
    }
  }

  Color _getColorForDateDifference(DateTime endDate) {
    int daysDifference = endDate.difference(DateTime.now()).inDays;
    if (daysDifference > 7) {
      return Colors.green;
    } else if (daysDifference > 2 && daysDifference <= 7) {
      return Colors.yellow;
    } else {
      return Colors.red;
    }
  }

  String _getRemainingDaysMessage(DateTime endDate) {
    int daysDifference = endDate.difference(DateTime.now()).inDays + 1; // +1, чтобы включить последний день
    return "Осталось дней: $daysDifference";
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Заявки"),
        actions: <Widget>[
          PopupMenuButton<String>(
            onSelected: (String result) {
              switch (result) {
                case 'create_request':
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CreateRequestPage()),
                  );
                  break;
              // Другие пункты меню при необходимости
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'create_request',
                child: Text('Создать заявку'),
              ),
              // Другие пункты меню при необходимости
            ],
          ),
        ],
      ),
      body: FutureBuilder<List<Application>>(
        future: fetchApplications(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Ошибка: ${snapshot.error}"));
          } else {
            return RefreshIndicator(
                onRefresh: () async {
              // Обновите данные
              setState(() {
                fetchApplications();
              });
            },
          child: ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                Application application = snapshot.data![index];
                return InkWell(
                    onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ApplicationDetailsPage(application: application),
                    ),
                  );
                },
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  elevation: 5,
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(10),
                    title: Text(
                      "Заявка ${application.id}",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text("Продукт: ${application.productName}"),
                        Text("Дата начала: ${DateFormat('yyyy-MM-dd').format(application.startDate)}"),
                        Text("Дата окончания: ${DateFormat('yyyy-MM-dd').format(application.endDate)}"),
                        Text("Аренда: ${application.totalCost.toStringAsFixed(2)}"),
                        Text("Склад: ${application.warehouseName}"),
                        Text(
                          _getRemainingDaysMessage(application.endDate),
                          style: TextStyle(color: _getColorForDateDifference(application.endDate)), // Изменение цвета текста
                        ),
                      ],
                    ),
                    isThreeLine: true,
                  ),
                )
                );




              },
            )
            );
          }
        },
      ),
    );
  }
}
