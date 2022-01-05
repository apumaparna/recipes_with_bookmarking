import 'package:recipes_with_bookmarking/data/models/ingredients.dart';

import 'models/models.dart';

abstract class Repository {
  // Add find methods

  // Return all recipes in the repository.
  List<Recipe> findAllRecipes();
  // Find a specific recipe by its ID.
  Recipe findRecipeById(int id);
  // Return all ingredients.
  List<Ingredient> findAllIngredients();
  // Find all the ingredients for the given recipe ID.
  List<Ingredient> findRecipeIngredients(int recipeId);

  // Add insert methods

  // Insert a new recipe.
  int insertRecipe(Recipe recipe);
  // Add all the given ingredients.
  List<int> insertIngredients(List<Ingredient> ingredients);

  // Add delete methods

  // Delete the given recipe
  void deleteRecipe(Recipe recipe);
  // Delete the given ingredient.
  void deleteIngredient(Ingredient ingredient);
  // Delete all the given ingredients.
  void deleteIngredients(List<Ingredient> ingredients);
  // Delete all the ingredients for the given recipe ID.
  void deleteRecipeIngredients(int recipeId);

  // Add initializing and closing methods

  // Allow the repository to initialize.
  // Databases might need to do some startup work.
  Future init();
  // Close the repository.
  void close();
}
