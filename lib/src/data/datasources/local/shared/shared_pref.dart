import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SharefPref {
  // Guardar
  Future<void> save(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(key, json.encode(value));
  }

  // Leer
  Future<dynamic> read(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final storedValue = prefs.getString(key);

    if (storedValue == null) return null;

    try {
      final decoded = json.decode(storedValue);

      // Solo devolvemos el objeto decodificado si es un mapa o lista
      if (decoded is Map || decoded is List) {
        return decoded;
      } else {
        // Si es número, string u otro tipo simple, devolver tal cual
        return storedValue;
      }
    } catch (e) {
      // Si no se puede decodificar, devolvemos el valor crudo
      return storedValue;
    }
  }

  // Remove
  Future<bool> remove(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.remove(key);
  }

  Future<bool> contains(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(key);
  }
}
