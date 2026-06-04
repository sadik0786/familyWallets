import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_keys.dart';

class LocalDbService {
  static final LocalDbService _instance = LocalDbService._internal();
  factory LocalDbService() => _instance;
  LocalDbService._internal();

  late SharedPreferences _prefs;

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Generic List Storage
  Future<List<Map<String, dynamic>>> getList(String tableKey) async {
    final rawData = _prefs.getString('${AppKeys.localCachePrefix}$tableKey');
    if (rawData == null) return [];
    try {
      final decoded = json.decode(rawData) as List<dynamic>;
      return decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveList(String tableKey, List<Map<String, dynamic>> list) async {
    final rawData = json.encode(list);
    await _prefs.setString('${AppKeys.localCachePrefix}$tableKey', rawData);
  }

  // Generic Row Add
  Future<void> insertRow(String tableKey, Map<String, dynamic> row) async {
    final list = await getList(tableKey);
    list.add(row);
    await saveList(tableKey, list);
  }

  // Generic Row Update
  Future<void> updateRow(String tableKey, String idKey, String idValue, Map<String, dynamic> updatedRow) async {
    final list = await getList(tableKey);
    final index = list.indexWhere((element) => element[idKey] == idValue);
    if (index != -1) {
      list[index] = {...list[index], ...updatedRow};
      await saveList(tableKey, list);
    }
  }

  // Generic Row Delete
  Future<void> deleteRow(String tableKey, String idKey, String idValue) async {
    final list = await getList(tableKey);
    list.removeWhere((element) => element[idKey] == idValue);
    await saveList(tableKey, list);
  }

  // Clean Database (useful for Demo Mode reset)
  Future<void> clearAll() async {
    final keys = _prefs.getKeys();
    for (final key in keys) {
      if (key.startsWith(AppKeys.localCachePrefix)) {
        await _prefs.remove(key);
      }
    }
  }

  // Utility to set/get single value preferences (like theme, theme settings, etc.)
  Future<void> setString(String key, String value) async {
    await _prefs.setString(key, value);
  }

  String? getString(String key) {
    return _prefs.getString(key);
  }

  Future<void> setBool(String key, bool value) async {
    await _prefs.setBool(key, value);
  }

  bool? getBool(String key) {
    return _prefs.getBool(key);
  }
}

final localDbServiceProvider = Provider<LocalDbService>((ref) => LocalDbService());
