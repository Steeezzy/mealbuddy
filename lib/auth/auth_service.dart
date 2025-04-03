import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  //Sign in with email and password
  Future<AuthResponse> signInWithEmailAndPassword({required String email, required String password}) async {
    return await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  //Sign up with email and password
  Future<AuthResponse> signUpWithEmailAndPassword({required String email, required String password}) async {
    return await _supabase.auth.signUp(
      email: email,
      password: password,
    );
  }

  //Sign out
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  //Get user Email
  String? getCurrentUserEmail() {
    final session = _supabase.auth.currentSession;
    final user = session?.user;
    return user?.email;
  }

  // Add this method to store restaurant profile data
  Future<void> storeRestaurantProfile({
    required String restoName,
    required String state,
    required String district,
    required String city,
    required String email,
    String? imagePath, // Add imagePath parameter
  }) async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    
    if (user == null) {
      throw Exception('User not authenticated');
    }
    
    // Create restaurant profile data
    final restaurantData = {
      'user_id': user.id,
      'resto_name': restoName,
      'state': state,
      'district': district,
      'city': city,
      'email': email,
      'image_url': imagePath, // Add image URL to the data
      'created_at': DateTime.now().toIso8601String(),
    };
    
    // Store in restaurants table
    await supabase.from('restaurants').insert(restaurantData);
  }

  Future<Map<String, dynamic>?> getCurrentUserProfile() async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      
      if (user == null) {
        print('getCurrentUserProfile: No authenticated user found');
        return null;
      }
      
      print('Fetching profile for user ID: ${user.id}');
      
      // Query the restaurants table for the current user's profile
      final response = await supabase
          .from('restaurants')
          .select()
          .eq('user_id', user.id)
          .maybeSingle();
      
      print('Profile data response: $response');
      
      return response;
    } catch (e) {
      print('Error in getCurrentUserProfile: $e');
      return null;
    }
  }

  Future<bool> updateRestaurantProfile({
    required String restoName,
    required String state,
    required String district,
    required String city,
    String? imagePath, // Add imagePath parameter
  }) async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      
      if (user == null) {
        return false;
      }
      
      // Create update data
      final updateData = {
        'resto_name': restoName,
        'state': state,
        'district': district,
        'city': city,
        'updated_at': DateTime.now().toIso8601String(),
      };
      
      // Add image path to update data if provided
      if (imagePath != null) {
        updateData['image_url'] = imagePath;
      }
      
      // Update restaurant profile
      await supabase
          .from('restaurants')
          .update(updateData)
          .eq('user_id', user.id);
      
      return true;
    } catch (e) {
      print('Error updating restaurant profile: $e');
      return false;
    }
  }
}