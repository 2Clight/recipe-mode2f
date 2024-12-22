import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String apiKey = 'dec989b0fd284b688c8e0c0cc7958e9b';
  final String baseUrl = 'https://api.spoonacular.com/recipes';

  Future<List<dynamic>> getRecipesByIngredients(List<String> ingredients) async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/findByIngredients?ingredients=${ingredients.join(",")}&number=10&apiKey=$apiKey',
      ),
    );

    if (response.statusCode == 200) {
      List<dynamic> recipes = json.decode(response.body);
      return recipes;
    } else {
      throw Exception('Failed to load recipes');
    }
  }

  Future<Map<String, dynamic>> getRecipeDetails(int recipeId) async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/$recipeId/information?includeNutrition=false&apiKey=$apiKey',
      ),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load recipe details');
    }
  }
}
