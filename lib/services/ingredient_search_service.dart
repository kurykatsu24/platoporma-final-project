// lib/services/ingredient_search_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/ingredient_prediction.dart';

class IngredientSearchService {
  final SupabaseClient client;
  IngredientSearchService({required this.client});

  /// Calls an RPC that returns ingredient predictions.
  /// RPC param name here is 'q' — change if your RPC uses different param.
  Future<List<IngredientPrediction>> fetchPredictions(String q) async {
    if (q.trim().isEmpty) return [];

    try {
      // The project pattern earlier used rpc returning a list of rows.
      final dynamic rpcResult = await client.rpc('search_ingredient_predictions', params: {'q': q});

      if (rpcResult == null) return [];

      final List<dynamic> rawList = rpcResult is List ? rpcResult : [rpcResult];

      final List<IngredientPrediction> parsed = rawList.map<IngredientPrediction>((e) {
        final Map<String, dynamic> m = Map<String, dynamic>.from(e as Map);
        return IngredientPrediction.fromMap(m);
      }).toList();

      return parsed;
    } catch (err, st) {
      // debug during development
      // ignore: avoid_print
      print('ingredient fetch error: $err\n$st');
      return [];
    }
  }
}