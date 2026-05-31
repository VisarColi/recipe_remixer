class AdaptedRecipe {
  final String title;
  final List<String> ingredients;
  final List<String> instructions;
  final String servings;
  final String time;

  const AdaptedRecipe({
    required this.title,
    required this.ingredients,
    required this.instructions,
    required this.servings,
    required this.time,
  });

  factory AdaptedRecipe.fromJson(Map<String, dynamic> json) {
    return AdaptedRecipe(
      title: json['title'] as String? ?? '',
      ingredients: List<String>.from(json['ingredients'] as List? ?? []),
      instructions: List<String>.from(json['instructions'] as List? ?? []),
      servings: json['servings'] as String? ?? '',
      time: json['time'] as String? ?? '',
    );
  }
}

class RemixResult {
  final bool canAdapt;
  final String reason;
  final AdaptedRecipe? recipe;
  final List<String> whatChanged;
  final List<String> metricIngredients;

  const RemixResult({
    required this.canAdapt,
    required this.reason,
    this.recipe,
    required this.whatChanged,
    required this.metricIngredients,
  });

  factory RemixResult.fromJson(Map<String, dynamic> json) {
    final adaptedJson = json['adaptedRecipe'];
    return RemixResult(
      canAdapt: json['canAdapt'] as bool? ?? false,
      reason: json['reason'] as String? ?? '',
      recipe: adaptedJson != null && adaptedJson is Map<String, dynamic>
          ? AdaptedRecipe.fromJson(adaptedJson)
          : null,
      whatChanged: List<String>.from(json['whatChanged'] as List? ?? []),
      metricIngredients:
          List<String>.from(json['metricIngredients'] as List? ?? []),
    );
  }
}
