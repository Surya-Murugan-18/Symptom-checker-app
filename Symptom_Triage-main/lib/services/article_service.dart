import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:symtom_checker/api_config.dart';
import 'package:symtom_checker/models/article_model.dart'; // Ensure correct import

class ArticleService {
  Future<List<Article>> fetchRecentArticles() async {
    try {
      final response = await http.get(Uri.parse('${ApiConfig.baseUrl}/articles')); // Adjust endpoint as needed
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        // Assuming the backend returns a list of articles. 
        // We take the latest 3.
        return data.map((json) => Article.fromJson(json)).take(3).toList();
      } else {
        throw Exception('Failed to load articles');
      }
    } catch (e) {
      throw Exception('Error fetching articles: $e');
    }
  }
}
