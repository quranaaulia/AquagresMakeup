import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tugasakhirtpm/models/model.dart';

const String baseUrl = "https://makeup-api.herokuapp.com/api/v1/products.json";

class ApiService {
  static Future<List<ContentModel>> fetchData(String brand) async {
    // Membuat URL dengan parameter 'brand'
    final response = await http.get(Uri.parse('$baseUrl?brand=$brand'));

    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = jsonDecode(response.body);

      // Mengonversi JSON menjadi list objek ContentModel
      return jsonResponse.map((item) => ContentModel.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load products: ${response.statusCode}');
    }
  }
}
