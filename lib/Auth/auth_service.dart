import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _client = Supabase.instance.client;

  // SIGN UP
  Future<String?> signUp(String email, String password) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
      );
      if (response.user == null) {
        return 'Sign-up failed. Please try again.';
      }
      return null; // success
    } on AuthException catch (e) {
      return e.message;
    } catch (_) {
      return 'Unexpected error occurred. Please try again later.';
    }
  }

  // LOGIN
  Future<String?> signIn(String email, String password) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (response.user == null) {
        return 'Invalid credentials.';
      }
      return null;
    } on AuthException catch (e) {
      return e.message;
    } catch (_) {
      return 'Unexpected error occurred.';
    }
  }

  // LOGOUT
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  // CHECK IF USER IS LOGGED IN
  bool get isLoggedIn => _client.auth.currentUser != null;
}