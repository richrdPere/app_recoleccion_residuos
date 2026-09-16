import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class SearchHistoryService {
  final SharedPreferencesAsync _preferences = SharedPreferencesAsync();

  String _key({required String userId, required String scope}) {
    return 'search_history.v1.${jsonEncode([userId, scope])}';
  }

  Future<List<String>> read({
    required String userId,
    required String scope,
  }) async {
    final values = await _preferences.getStringList(
      _key(userId: userId, scope: scope),
    );

    return List<String>.from(values ?? const []);
  }

  Future<void> write({
    required String userId,
    required String scope,
    required List<String> items,
  }) async {
    final key = _key(userId: userId, scope: scope);

    if (items.isEmpty) {
      await _preferences.remove(key);
      return;
    }

    await _preferences.setStringList(key, items);
  }
}
