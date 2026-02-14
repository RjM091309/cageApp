import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/api_config.dart';

class AuthUser {
  final String username;
  final String firstname;
  final String lastname;
  final int userId;
  final int permissions;
  final String role;

  const AuthUser({
    required this.username,
    required this.firstname,
    required this.lastname,
    required this.userId,
    required this.permissions,
    this.role = 'User',
  });

  String get displayName {
    if (firstname.isNotEmpty || lastname.isNotEmpty) {
      return '$firstname $lastname'.trim();
    }
    return username;
  }
}

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  static const _keyToken = 'auth_token';
  static const _keyUser = 'auth_user';
  static const _keyRememberMe = 'remember_me';
  static const _keySavedUsername = 'saved_username';
  static const _keySavedPassword = 'saved_password';

  /// Returns stored token or null.
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyToken);
  }

  /// Returns stored user or null.
  Future<AuthUser?> getStoredUser() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_keyUser);
    if (json == null || json.isEmpty) return null;
    try {
      final map = Map<String, dynamic>.from(jsonDecode(json) as Map);
      return AuthUser(
        username: map['username']?.toString() ?? '',
        firstname: map['firstname']?.toString() ?? '',
        lastname: map['lastname']?.toString() ?? '',
        userId: _int(map['user_id']),
        permissions: _int(map['permissions']),
        role: map['role']?.toString().trim() ?? 'User',
      );
    } catch (_) {
      return null;
    }
  }

  /// Login with username and password. On success saves token and user, returns AuthUser.
  Future<AuthUser?> login({required String username, required String password}) async {
    try {
      final res = await http.post(
        Uri.parse(loginApiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username.trim(), 'password': password}),
      );
      final json = _parseJson(res.body);
      if (json == null) return null;
      final success = json['success'] == true;
      if (!success) return null;
      final token = json['token']?.toString();
      final userMap = json['user'];
      if (token == null || token.isEmpty || userMap is! Map) return null;
      final user = AuthUser(
        username: (userMap['username'] ?? '').toString(),
        firstname: (userMap['firstname'] ?? '').toString(),
        lastname: (userMap['lastname'] ?? '').toString(),
        userId: _int(userMap['user_id']),
        permissions: _int(userMap['permissions']),
        role: (userMap['role']?.toString() ?? '').trim().isEmpty ? 'User' : (userMap['role']?.toString() ?? 'User').trim(),
      );
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyToken, token);
      await prefs.setString(_keyUser, jsonEncode({
        'username': user.username,
        'firstname': user.firstname,
        'lastname': user.lastname,
        'user_id': user.userId,
        'permissions': user.permissions,
        'role': user.role,
      }));
      return user;
    } catch (_) {
      return null;
    }
  }

  /// Clear stored auth (logout).
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyToken);
    await prefs.remove(_keyUser);
  }

  /// Save login (remember me): username and password. Call after successful login when user checked Remember me.
  Future<void> saveRememberMe({required String username, required String password}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyRememberMe, true);
    await prefs.setString(_keySavedUsername, username);
    await prefs.setString(_keySavedPassword, password);
  }

  /// Clear saved login. Call when user unchecks Remember me or logs in with Remember me off.
  Future<void> clearRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyRememberMe, false);
    await prefs.remove(_keySavedUsername);
    await prefs.remove(_keySavedPassword);
  }

  /// Whether "Remember me" was last enabled.
  Future<bool> getRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyRememberMe) ?? false;
  }

  /// Saved username when Remember me was on. Empty if none.
  Future<String> getSavedUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keySavedUsername) ?? '';
  }

  /// Saved password when Remember me was on. Empty if none.
  Future<String> getSavedPassword() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keySavedPassword) ?? '';
  }

  int _int(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }

  Map<String, dynamic>? _parseJson(String body) {
    try {
      if (body.isEmpty) return null;
      return Map<String, dynamic>.from(jsonDecode(body) as Map);
    } catch (_) {
      return null;
    }
  }
}
