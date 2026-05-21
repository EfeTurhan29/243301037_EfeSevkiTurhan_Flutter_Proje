import 'package:supabase_flutter/supabase_flutter.dart';

class LogService {
  static final _supabase = Supabase.instance.client;

  static Future<void> addLog({
    required String action,
    required String description,
  }) async {
    try {
      final user = _supabase.auth.currentUser;

      await _supabase.from('logs').insert({
        'user_id': user?.id,
        'action': action,
        'description': description,
      });
    } catch (_) {
      // Log hatası uygulamayı durdurmasın diye sessiz geçiyoruz.
    }
  }
}