import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesProvider extends ChangeNotifier {
  SharedPreferences? _prefs;

  SharedPreferencesProvider() {
    _initSharedPreferences();
  }

  Future<void> _initSharedPreferences() async {
    _prefs = await SharedPreferences.getInstance();
  }

  String? getData(String key) {
    return _prefs?.getString(key);
  }

  Future<void> setData(String key, String value) async {
    await _prefs?.setString(key, value);
    notifyListeners();
  }

  Future<void> deleteData() async {
    await _prefs?.clear();
  }
}
