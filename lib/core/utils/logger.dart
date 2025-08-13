// 📝🐓 LOGGER ÉPICO PARA DEBUG
import 'package:flutter/foundation.dart';

class Logger {
  static const String _appTag = '🐓 GallosApp';

  void info(String message, {Map<String, dynamic>? data}) {
    if (kDebugMode) {
      print('$_appTag ℹ️ $message');
      if (data != null) {
        print('   📊 Data: $data');
      }
    }
  }

  void error(String message, {dynamic error, StackTrace? stackTrace}) {
    if (kDebugMode) {
      print('$_appTag ❌ ERROR: $message');
      if (error != null) {
        print('   🔥 Error: $error');
      }
      if (stackTrace != null) {
        print('   📍 Stack: $stackTrace');
      }
    }
  }

  void warning(String message, {Map<String, dynamic>? data}) {
    if (kDebugMode) {
      print('$_appTag ⚠️ WARNING: $message');
      if (data != null) {
        print('   📊 Data: $data');
      }
    }
  }

  void debug(String message, {Map<String, dynamic>? data}) {
    if (kDebugMode) {
      print('$_appTag 🐛 DEBUG: $message');
      if (data != null) {
        print('   📊 Data: $data');
      }
    }
  }

  void success(String message, {Map<String, dynamic>? data}) {
    if (kDebugMode) {
      print('$_appTag ✅ SUCCESS: $message');
      if (data != null) {
        print('   📊 Data: $data');
      }
    }
  }
}