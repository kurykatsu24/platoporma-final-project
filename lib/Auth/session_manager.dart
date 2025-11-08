import 'package:supabase_flutter/supabase_flutter.dart';

class SessionManager {
  final SupabaseClient _client = Supabase.instance.client;

  bool get isUserLoggedIn => _client.auth.currentUser != null;

  // Optional: listen for changes in auth state
  void listenAuthChanges(Function(bool loggedIn) onChanged) {
    _client.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      if (event == AuthChangeEvent.signedIn) {
        onChanged(true);
      } else if (event == AuthChangeEvent.signedOut) {
        onChanged(false);
      }
    });
  }
}