/// Base URL for Infinity Cage X API and Socket.IO.
/// - Production (domain + HTTPS): https://yourdomain.com  (no port; Nginx proxies to backend)
/// - Server (IP): http://45.32.103.210:4005
/// - Local dev: http://localhost:4005 or http://192.168.x.x:4005

const String apiBaseUrl = 'https://infinitycage.3core21.com';

String get loginApiUrl => '$apiBaseUrl/api/auth/login';

String get realtimeApiUrl => '$apiBaseUrl/api/realtime';

String get notificationsApiUrl => '$apiBaseUrl/api/notifications';

String notificationMarkReadUrl(int id) => '$apiBaseUrl/api/notifications/$id';

String get socketUrl => apiBaseUrl;

String dailySettlementApiUrl({required String startDate, required String endDate}) =>
    '$apiBaseUrl/api/daily-settlement?start_date=$startDate&end_date=$endDate';

String monthlyAccumulatedApiUrl({required int year, required int month}) =>
    '$apiBaseUrl/api/monthly-accumulated?year=$year&month=$month';

String get markerApiUrl => '$apiBaseUrl/api/marker';

String rankingApiUrl({int? year, int? month, int? limit, int? offset}) {
  final now = DateTime.now();
  final y = year ?? now.year;
  final m = month ?? now.month;
  var url = '$apiBaseUrl/api/ranking?year=$y&month=$m';
  if (limit != null) url += '&limit=$limit';
  if (offset != null) url += '&offset=$offset';
  return url;
}
