import 'package:equatable/equatable.dart';
import 'package:recipes_with_bookmarking/data/models/ingredients.dart';

// ignore: must_be_immutable
class Recipe extends Equatable {
  // Recipe properties for the recipe text:
  // label, image and url. id is not final so you can
  // update it.
  int? id;
  final String? label;
  final String? image;
  final String? url;

  // A list of ingredients that the recipe contains along
  // with its calories, weight and time to cook.
  List<Ingredient>? ingredients;
  final double? calories;
  final double? totalWeight;
  final double? totalTime;

  // A constructor with all fields except ingredients,
  // which you’ll add later.
  Recipe(
      {this.id,
      this.label,
      this.image,
      this.url,
      this.calories,
      this.totalWeight,
      this.totalTime});

  // Equatable properties, which you’ll use for comparison.
  @override
  List<Object?> get props =>
      [label, image, url, calories, totalWeight, totalTime];
}
