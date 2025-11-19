import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final supabase = Supabase.instance.client;

  /// Register new user to Supabase
  static Future<Map<String, dynamic>> registerUser({
    required String fullName,
    required String designation,
    required String district,
    required String tehsil,
    required String mobileNumber,
  }) async {
    try {
      print('DEBUG: Checking if phone exists: $mobileNumber');

      // STEP 1: Check if mobile number already exists
      final existing = await supabase
          .from('registered_users')
          .select('mobile_number')
          .eq('mobile_number', mobileNumber)
          .maybeSingle();

      if (existing != null) {
        print('DEBUG: ❌ Phone number already exists in database');
        return {
          'success': false,
          'message': 'Phone number already registered',
          'isDuplicate': true,
        };
      }

      print('DEBUG: ✅ Phone number not found, proceeding with registration');

      // STEP 2: Insert new user WITHOUT specifying id (let Supabase auto-generate)
      final response = await supabase.from('registered_users').insert({
        // DO NOT include 'id' here - let database auto-generate it
        'full_name': fullName,
        'designation': designation,
        'district': district,
        'tehsil': tehsil,
        'mobile_number': mobileNumber,
        'registration_date': DateTime.now().toIso8601String(),
      }).select().single();

      print('DEBUG: ✅ User registered successfully: $response');

      return {
        'success': true,
        'message': 'User registered in central database',
        'isDuplicate': false,
      };
    } on PostgrestException catch (e) {
      print('DEBUG: ❌ PostgrestException: ${e.message}');
      print('DEBUG: Error code: ${e.code}');
      print('DEBUG: Error details: ${e.details}');
      
      // Handle any duplicate constraint
      if (e.code == '23505') {
        // Check if it's phone number or ID issue
        if (e.message.contains('mobile_number')) {
          return {
            'success': false,
            'message': 'Phone number already registered',
            'isDuplicate': true,
          };
        } else {
          // ID constraint issue - retry without ID
          return {
            'success': false,
            'message': 'Database configuration error. Please contact support.',
            'isDuplicate': false,
          };
        }
      }
      
      return {
        'success': false,
        'message': 'Database error: ${e.message}',
        'isDuplicate': false,
      };
    } catch (e) {
      print('DEBUG: ❌ Network error: $e');
      return {
        'success': false,
        'message': 'No internet connection',
        'isDuplicate': false,
      };
    }
  }

  /// Check if user exists by mobile number
  static Future<bool> checkUserExists(String mobileNumber) async {
    try {
      final response = await supabase
          .from('registered_users')
          .select()
          .eq('mobile_number', mobileNumber)
          .maybeSingle();

      return response != null;
    } catch (e) {
      print('Error checking user: $e');
      return false;
    }
  }

  /// Get total registered users count
  static Future<int> getTotalUsersCount() async {
    try {
      final response = await supabase
          .from('registered_users')
          .select()
          .count();
      
      return response.count;
    } catch (e) {
      print('Error getting user count: $e');
      return 0;
    }
  }

  /// Get all users ordered by registration date
  static Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      final response = await supabase
          .from('registered_users')
          .select()
          .order('registration_date', ascending: false);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error getting users: $e');
      return [];
    }
  }

  /// Get users by district
  static Future<List<Map<String, dynamic>>> getUsersByDistrict(String district) async {
    try {
      final response = await supabase
          .from('registered_users')
          .select()
          .eq('district', district)
          .order('registration_date', ascending: false);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error getting users by district: $e');
      return [];
    }
  }

  /// Get users by designation
  static Future<List<Map<String, dynamic>>> getUsersByDesignation(String designation) async {
    try {
      final response = await supabase
          .from('registered_users')
          .select()
          .eq('designation', designation)
          .order('registration_date', ascending: false);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error getting users by designation: $e');
      return [];
    }
  }
}
