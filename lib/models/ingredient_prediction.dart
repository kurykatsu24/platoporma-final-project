class IngredientPrediction {
  final String id;
  final String name;
  final String? category;

  IngredientPrediction({
    required this.id,
    required this.name,
    this.category,
  });

  factory IngredientPrediction.fromMap(Map<String, dynamic> m) {
    return IngredientPrediction(
      id: m['id']?.toString() ?? '',
      name: (m['name'] as String?) ?? '',
      category: (m['ingredient_category'] as String?) ?? (m['category'] as String?),
    );
  }
}