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
    notifyListeners();
  }

  String? getData(String key) {
    _waitForInitialization();
    print('what? $key');
    print('what? ${_prefs?.getString(key)}');
    return _prefs?.getString(key);
  }

  Future<void> setData(String key, String value) async {
    await _waitForInitialization();
    print('what! $key, $value');
    await _prefs?.setString(key, value);
    notifyListeners();
  }

  Future<void> deleteData() async {
    await _waitForInitialization();
    await _prefs?.clear();
  }

  Future<void> _waitForInitialization() async {
    while (_prefs == null) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }
}
