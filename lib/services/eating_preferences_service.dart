import 'package:supabase_flutter/supabase_flutter.dart';

class EatingPreferencesService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Get user's eating preferences
  Future<Map<String, dynamic>?> getUserPreferences() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return null;

      final data = await _supabase
          .from('eating_preferences')
          .select()
          .eq('user_id', user.id)
          .maybeSingle();
      
      return data;
    } catch (e) {
      print('Error getting user preferences: $e');
      return null;
    }
  }

  // Update diet preference
  Future<bool> updateDietPreference(String? dietPreference) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return false;

      final existingPrefs = await _supabase
          .from('eating_preferences')
          .select()
          .eq('user_id', user.id)
          .maybeSingle();

      if (existingPrefs != null) {
        await _supabase
            .from('eating_preferences')
            .update({
              'diet_preference': dietPreference,
              'updated_at': DateTime.now().toIso8601String()
            })
            .eq('user_id', user.id);
      } else {
        await _supabase.from('eating_preferences').insert({
          'user_id': user.id,
          'diet_preference': dietPreference,
          'allergens': [],
          'disliked_ingredients': [],
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String()
        });
      }
      return true;
    } catch (e) {
      print('Error updating diet preference: $e');
      return false;
    }
  }

  // Update allergens
  Future<bool> updateAllergens(List<String> allergens) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return false;

      final existingPrefs = await _supabase
          .from('eating_preferences')
          .select()
          .eq('user_id', user.id)
          .maybeSingle();

      if (existingPrefs != null) {
        await _supabase
            .from('eating_preferences')
            .update({
              'allergens': allergens,
              'updated_at': DateTime.now().toIso8601String()
            })
            .eq('user_id', user.id);
      } else {
        await _supabase.from('eating_preferences').insert({
          'user_id': user.id,
          'diet_preference': null,
          'allergens': allergens,
          'disliked_ingredients': [],
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String()
        });
      }
      return true;
    } catch (e) {
      print('Error updating allergens: $e');
      return false;
    }
  }

  // Update disliked ingredients
  Future<bool> updateDislikedIngredients(List<String> ingredients) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return false;

      final existingPrefs = await _supabase
          .from('eating_preferences')
          .select()
          .eq('user_id', user.id)
          .maybeSingle();

      if (existingPrefs != null) {
        await _supabase
            .from('eating_preferences')
            .update({
              'disliked_ingredients': ingredients,
              'updated_at': DateTime.now().toIso8601String()
            })
            .eq('user_id', user.id);
      } else {
        await _supabase.from('eating_preferences').insert({
          'user_id': user.id,
          'diet_preference': null,
          'allergens': [],
          'disliked_ingredients': ingredients,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String()
        });
      }
      return true;
    } catch (e) {
      print('Error updating disliked ingredients: $e');
      return false;
    }
  }
}