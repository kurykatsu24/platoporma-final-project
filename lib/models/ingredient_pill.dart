class IngredientPill {
  final String id;
  final String name;
  final String? category;

  IngredientPill({
    required this.id,
    required this.name,
    this.category,
  });
}