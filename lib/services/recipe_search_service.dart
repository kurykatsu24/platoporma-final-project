// lib/services/search_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:platoporma/models/recipe_prediction.dart';

class RecipeSearchService {
  final SupabaseClient client;

  RecipeSearchService({required this.client});

  /// Calls the RPC function search_recipe_predictions
  /// NOTE: the RPC param name here is 'q' — if your DB function expects a different
  /// name (e.g. 'search_text'), change the key in params accordingly.
  Future<List<RecipePrediction>> fetchPredictions(String q) async {
    if (q.trim().isEmpty) return [];

    try {
      // Await the RPC directly (don't call .execute() on the builder)
      final dynamic rpcResult = await client.rpc(
        'search_recipe_predictions',
        params: {'q': q}, // <-- change 'q' => 'search_text' if your function uses that
      );

      // rpcResult can be:
      // - a List<dynamic> (most likely), or
      // - a Map<String, dynamic> (single-row), or
      // - null
      if (rpcResult == null) {
        return [];
      }

      // Normalize to a List<Map>
      final List<dynamic> rawList = rpcResult is List ? rpcResult : [rpcResult];

      final List<RecipePrediction> parsed = rawList.map<RecipePrediction>((e) {
        final Map<String, dynamic> m = (e is Map) ? Map<String, dynamic>.from(e) : Map<String, dynamic>.from(e as Map);
        return RecipePrediction.fromMap(m);
      }).toList();

      return parsed;
    } catch (err, st) {
      // Helpful debug while developing — remove or reduce in production.
      // print stack and error so you can see what the client returned.
      // ignore: avoid_print
      print('fetchPredictions rpc error: $err\n$st');
      return [];
    }
  }
}