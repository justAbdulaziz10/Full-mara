import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

/// Centralized backend HTTP helper for authenticated calls.
/// Exposes static methods so you can just call:
///   await BackendApi.syncWithBackend();
///   final profile = await BackendApi.getMyProfile();
class BackendApi {
  BackendApi._();

  static String get _base {
    final env = dotenv.env['BACKEND_BASE_URL'];
    if (env != null && env.isNotEmpty) return env.trim();
    return 'http://127.0.0.1:8000'; // fallback for local dev
  }

  /// Sends the Firebase ID token to backend so it can create / sync a user record.
  static Future<void> syncWithBackend() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return; // nothing to sync
    final token = await user.getIdToken();
    final uri = Uri.parse('$_base/auth/sync');
    try {
      final res = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({}),
      );
      if (res.statusCode != 200) {
        throw Exception('Backend auth failed: ${res.statusCode} ${res.body}');
      }
    } catch (e, st) {
      debugPrint('syncWithBackend error: $e\n$st');
      rethrow;
    }
  }

  /// Fetches the current user's profile map from backend.
  static Future<Map<String, dynamic>> getMyProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('No authenticated user');
    }
    final token = await user.getIdToken();
    final uri = Uri.parse('$_base/profile/me');
    final res = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );
    if (res.statusCode != 200) {
      throw Exception('Profile fetch failed: ${res.statusCode} ${res.body}');
    }
    final decoded = jsonDecode(res.body);
    if (decoded is Map<String, dynamic>) return decoded;
    return {'data': decoded};
  }
}
