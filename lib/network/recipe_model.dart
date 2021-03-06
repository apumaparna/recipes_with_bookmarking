import 'package:json_annotation/json_annotation.dart';
import 'package:recipes_with_bookmarking/data/models/ingredients.dart';
import '../data/models/models.dart';

part 'recipe_model.g.dart';

@JsonSerializable()
class APIRecipeQuery {
  // Note also that the first call is a factory method.
  // That’s because you need a class-level method when you’re creating the
  // instance, while you use the other method on an object that already exists.
  factory APIRecipeQuery.fromJson(Map<String, dynamic> json) =>
      _$APIRecipeQueryFromJson(json);

  Map<String, dynamic> toJson() => _$APIRecipeQueryToJson(this);
  @JsonKey(name: 'q')
  String query;
  int from;
  int to;
  bool more;
  int count;
  List<APIHits> hits;

  APIRecipeQuery({
    required this.query,
    required this.from,
    required this.to,
    required this.more,
    required this.count,
    required this.hits,
  });
}

// Add @JsonSerializable() class APIHits
// 1. Marks the class serializable.
// 2. Defines a field of class APIRecipe, which you’ll create soon.
// 3. Defines a constructor that accepts a recipe parameter.
// 4. Adds the methods for JSON serialization.

// 1
@JsonSerializable()
class APIHits {
  // 2
  APIRecipe recipe;

  // 3
  APIHits({
    required this.recipe,
  });

  // 4
  factory APIHits.fromJson(Map<String, dynamic> json) =>
      _$APIHitsFromJson(json);
  Map<String, dynamic> toJson() => _$APIHitsToJson(this);
}

// Add @JsonSerializable() class APIRecipe
// 1. Define the fields for a recipe. label is the text shown and image is the URL of the image to show.
// 2. State that each recipe has a list of ingredients.
// 3. Create the factory methods for serializing JSON.

@JsonSerializable()
class APIRecipe {
  // 1
  String label;
  String image;
  String url;
  // 2
  List<APIIngredients> ingredients;
  double calories;
  double totalWeight;
  double totalTime;

  APIRecipe({
    required this.label,
    required this.image,
    required this.url,
    required this.ingredients,
    required this.calories,
    required this.totalWeight,
    required this.totalTime,
  });

  // 3
  factory APIRecipe.fromJson(Map<String, dynamic> json) =>
      _$APIRecipeFromJson(json);
  Map<String, dynamic> toJson() => _$APIRecipeToJson(this);
}

// 4. Add a helper method to turn a calorie into a string.
// 5. Add another helper method to turn the weight into a string.

// 4
String getCalories(double? calories) {
  if (calories == null) {
    return '0 KCAL';
  }
  return calories.floor().toString() + ' KCAL';
}

// 5
String getWeight(double? weight) {
  if (weight == null) {
    return '0g';
  }
  return weight.floor().toString() + 'g';
}

// Add @JsonSerializable() class APIIngredients

// 1. State that the name field of this class maps to the JSON field named text.
// 2. Create the methods to serialize JSON.

@JsonSerializable()
class APIIngredients {
  // 1
  @JsonKey(name: 'text')
  String name;
  double weight;

  APIIngredients({
    required this.name,
    required this.weight,
  });

  // 2
  factory APIIngredients.fromJson(Map<String, dynamic> json) =>
      _$APIIngredientsFromJson(json);
  Map<String, dynamic> toJson() => _$APIIngredientsToJson(this);
}

List<Ingredient> convertIngredients(List<APIIngredients> apiIngredients) {
  // Create a new list of ingredients to return.
  final ingredients = <Ingredient>[];
  // Convert each APIIngredients into an instance of Ingredient and
  // add it to the list.
  apiIngredients.forEach((ingredient) {
    ingredients
        .add(Ingredient(name: ingredient.name, weight: ingredient.weight));
  });
  return ingredients;
}
