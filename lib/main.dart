import 'package:flutter/material.dart';
import 'api_service.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: IngredientInputScreen(),
    );
  }
}

class IngredientInputScreen extends StatefulWidget {
  @override
  _IngredientInputScreenState createState() => _IngredientInputScreenState();
}

class _IngredientInputScreenState extends State<IngredientInputScreen> {
  TextEditingController _controller = TextEditingController();
  List<dynamic> _recipes = [];
  bool _isLoading = false;

  void _searchRecipes() async {
    setState(() {
      _isLoading = true;
    });

    List<String> ingredients = _controller.text.split(',').map((ingredient) => ingredient.trim()).toList();
    ApiService apiService = ApiService();

    try {
      List<dynamic> recipes = await apiService.getRecipesByIngredients(ingredients);
      setState(() {
        _recipes = recipes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('Failed to fetch recipes. Please try again later.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  void _showRecipeDetails(int recipeId) async {
    ApiService apiService = ApiService();

    try {
      var recipeDetails = await apiService.getRecipeDetails(recipeId);
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(recipeDetails['title']),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ingredients:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  ...recipeDetails['extendedIngredients'].map<Widget>((ingredient) {
                    return Text('- ${ingredient['original']}');
                  }).toList(),
                  SizedBox(height: 16),
                  Text(
                    'Instructions:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(recipeDetails['instructions'] ?? 'No instructions available'),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Close'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('Failed to fetch recipe details. Please try again later.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Ingredient to Recipe')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Enter ingredients (comma separated)',
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _searchRecipes,
              child: Text('Find Recipes'),
            ),
            SizedBox(height: 20),
            _isLoading
                ? CircularProgressIndicator()
                : Expanded(
                    child: ListView.builder(
                      itemCount: _recipes.length,
                      itemBuilder: (context, index) {
                        var recipe = _recipes[index];
                        return Card(
                          child: ListTile(
                            title: Text(recipe['title']),
                            subtitle: Text('Used ingredients: ${recipe['usedIngredients'].length}'),
                            leading: Image.network(
                              recipe['image'],
                              fit: BoxFit.cover,
                              height: 100.0,
                              width: 100.0,
                            ),
                            onTap: () => _showRecipeDetails(recipe['id']),
                          ),
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
