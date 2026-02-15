import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:symtom_checker/api_config.dart';
import 'package:symtom_checker/models/appointment_model.dart';
import 'package:symtom_checker/user_session.dart';

class AppointmentService {
  Future<Appointment?> getAppointmentById(int id) async {
    try {
      final response = await http.get(
        Uri.parse("${ApiConfig.baseUrl}/appointments/$id"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${UserSession().token}",
        },
      );

      if (response.statusCode == 200) {
        return Appointment.fromJson(jsonDecode(response.body));
      } else {
        return null;
      }
    } catch (e) {
      print("Error fetching appointment: $e");
      return null;
    }
  }
}
