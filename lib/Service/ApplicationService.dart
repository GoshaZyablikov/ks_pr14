import 'package:dio/dio.dart';
import 'package:warehouse_project/Model/Application.dart';
import 'package:warehouse_project/Service/AuthService.dart';

class ApplicationService {
  Future<List<Application>> fetchApplications() async {
    final response = await Dio().get('$api/Applications');
    if (response.statusCode == 200) {
      List<Application> applications = List<Application>.from(
          response.data.map((model) => Application.fromJson(model))
      );
      return applications;
    } else {
      throw Exception('Failed to load applications');
    }
  }
}
