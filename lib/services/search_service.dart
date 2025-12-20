import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api.dart';
import 'auth_service.dart';

class SearchService {
  final AuthService _auth = AuthService();

  /// Search courses
  Future<Map<String, dynamic>> search({
    required String query,
    String? categoryId,
    String? level,
    num? minPrice,
    num? maxPrice,
    int page = 1,
    int perPage = 20,
  }) async {
    final token = await _auth.getToken();
    
    final queryParams = <String, String>{
      'q': query,
      'page': page.toString(),
      'per_page': perPage.toString(),
    };

    if (categoryId != null && categoryId.isNotEmpty) {
      queryParams['category_id'] = categoryId;
    }
    if (level != null && level.isNotEmpty) {
      queryParams['level'] = level;
    }
    if (minPrice != null) {
      queryParams['min_price'] = minPrice.toString();
    }
    if (maxPrice != null) {
      queryParams['max_price'] = maxPrice.toString();
    }

    final uri = Uri.parse("${ApiConfig.baseUrl}/v1/search")
        .replace(queryParameters: queryParams);

    final response = await http.get(
      uri,
      headers: {
        if (token != null) "Authorization": "Bearer $token",
        "Accept": "application/json",
      },
    );

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  /// Get search suggestions
  Future<List<String>> getSuggestions(String query) async {
    final token = await _auth.getToken();

    final response = await http.get(
      Uri.parse("${ApiConfig.baseUrl}/v1/search/suggestions?q=$query"),
      headers: {
        if (token != null) "Authorization": "Bearer $token",
        "Accept": "application/json",
      },
    );

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return (data['suggestions'] as List?)?.cast<String>() ?? [];
  }
}







