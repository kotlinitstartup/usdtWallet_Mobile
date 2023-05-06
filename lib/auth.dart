import 'package:shared_preferences/shared_preferences.dart';

final _prefs = SharedPreferences.getInstance();

Future<void> saveAccessToken(String accessToken) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('accessToken', accessToken);
}

Future<String?> getAccessToken() async {
  final prefs = await _prefs;
  return prefs.getString('accessToken');
}

Future<void> clearAccessToken() async {
  final prefs = await _prefs;
  await prefs.remove('accessToken');
}
