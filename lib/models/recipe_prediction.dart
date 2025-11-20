class RecipePrediction {
  final String itemType; // 'recipe' or 'category'
  final String? refId;   // recipe id (uuid) as string, null for category
  final String displayText;
  final String? categoryType; // 'cuisine'|'diet'|'protein' or null

  RecipePrediction({
    required this.itemType,
    required this.refId,
    required this.displayText,
    required this.categoryType,
  });

  factory RecipePrediction.fromMap(Map<String, dynamic> m) {
    return RecipePrediction(
      itemType: (m['item_type'] as String?) ?? 'recipe',
      refId: m['ref_id'] != null ? m['ref_id'].toString() : null,
      displayText: (m['display_text'] as String?) ?? '',
      categoryType: m['category_type'] as String?,
    );
  }
}