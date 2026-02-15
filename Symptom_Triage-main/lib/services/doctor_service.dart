import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:symtom_checker/api_config.dart';
import 'package:symtom_checker/models/doctor_model.dart';
import 'package:symtom_checker/user_session.dart';

class DoctorService {
  /// Fetch top 10 doctors by rating
  Future<List<Doctor>> fetchTopDoctors() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/doctors/top'),
        headers: {
          'Content-Type': 'application/json',
          if (UserSession().token != null)
            'Authorization': 'Bearer ${UserSession().token}',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Doctor.fromJson(json)).take(5).toList();
      } else {
        throw Exception('Failed to load top doctors (${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Error fetching top doctors: $e');
    }
  }

  /// Fetch all verified doctors (patient-facing listing)
  Future<List<Doctor>> fetchVerifiedDoctors() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/doctors/verified'),
        headers: {
          'Content-Type': 'application/json',
          if (UserSession().token != null)
            'Authorization': 'Bearer ${UserSession().token}',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Doctor.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load verified doctors (${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Error fetching verified doctors: $e');
    }
  }

  /// Search verified doctors by specialization
  Future<List<Doctor>> searchVerifiedDoctors(String query) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/doctors/verified/search?query=${Uri.encodeComponent(query)}'),
        headers: {
          'Content-Type': 'application/json',
          if (UserSession().token != null)
            'Authorization': 'Bearer ${UserSession().token}',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Doctor.fromJson(json)).toList();
      } else {
        throw Exception('Failed to search doctors (${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Error searching doctors: $e');
    }
  }

  /// Fetch a single doctor by ID (for detail page)
  Future<Doctor?> fetchDoctorById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/doctors/$id'),
        headers: {
          'Content-Type': 'application/json',
          if (UserSession().token != null)
            'Authorization': 'Bearer ${UserSession().token}',
        },
      );

      if (response.statusCode == 200) {
        return Doctor.fromJson(jsonDecode(response.body));
      } else {
        return null;
      }
    } catch (e) {
      throw Exception('Error fetching doctor $id: $e');
    }
  }

  /// Fetch all doctors (admin / unfiltered)
  Future<List<Doctor>> fetchAllDoctors() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/doctors'),
        headers: {
          'Content-Type': 'application/json',
          if (UserSession().token != null)
            'Authorization': 'Bearer ${UserSession().token}',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Doctor.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load all doctors (${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Error fetching all doctors: $e');
    }
  }

  /// Search doctors by specialization (unfiltered)
  Future<List<Doctor>> searchDoctors(String query) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/doctors/search?query=$query'),
        headers: {
          'Content-Type': 'application/json',
          if (UserSession().token != null)
            'Authorization': 'Bearer ${UserSession().token}',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Doctor.fromJson(json)).toList();
      } else {
        throw Exception('Failed to search doctors (${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Error searching doctors: $e');
    }
  }

  Future<List<String>> fetchSpecializations() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/doctors/specializations'),
        headers: {
          'Content-Type': 'application/json',
          if (UserSession().token != null)
            'Authorization': 'Bearer ${UserSession().token}',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<String>();
      } else {
        throw Exception('Failed to load specializations (${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Error fetching specializations: $e');
    }
  }
}
