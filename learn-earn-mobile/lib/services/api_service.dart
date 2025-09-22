import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../models/lesson.dart';
import '../models/earning.dart';
import '../models/payout.dart';
import '../utils/crypto.dart';

class ApiService {
  static const String baseUrl =
      'http://localhost:8080/api'; // Change for production
  static String? _deviceId;
  static String? _publicKey;
  static String? _privateKey;

  static void setDeviceCredentials(
    String deviceId,
    String publicKey,
    String privateKey,
  ) {
    _deviceId = deviceId;
    _publicKey = publicKey;
    _privateKey = privateKey;
  }

  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  static Map<String, dynamic> _createSignedPayload(
    Map<String, dynamic> payload,
  ) {
    final nonce = CryptoUtils.generateNonce();
    final message = jsonEncode({'nonce': nonce, 'payload': payload});
    final signature = _privateKey != null
        ? CryptoUtils.createSignature(message, _privateKey!)
        : '';

    return {
      'deviceId': _deviceId,
      'signature': signature,
      'nonce': nonce,
      'payload': payload,
    };
  }

  static Future<http.Response> _makeRequest(
    String method,
    String endpoint, {
    Map<String, dynamic>? body,
    bool requiresAuth = false,
  }) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final headers = Map<String, String>.from(_headers);

    Map<String, dynamic>? requestBody;
    if (body != null) {
      if (requiresAuth) {
        requestBody = _createSignedPayload(body);
      } else {
        requestBody = body;
      }
    }

    http.Response response;
    switch (method.toUpperCase()) {
      case 'GET':
        response = await http.get(url, headers: headers);
        break;
      case 'POST':
        response = await http.post(
          url,
          headers: headers,
          body: requestBody != null ? jsonEncode(requestBody) : null,
        );
        break;
      case 'PUT':
        response = await http.put(
          url,
          headers: headers,
          body: requestBody != null ? jsonEncode(requestBody) : null,
        );
        break;
      case 'DELETE':
        response = await http.delete(url, headers: headers);
        break;
      default:
        throw Exception('Unsupported HTTP method: $method');
    }

    return response;
  }

  // User endpoints
  static Future<User> registerDevice(
    String publicKey, {
    bool isEmulator = false,
  }) async {
    final response = await _makeRequest(
      'POST',
      '/users/register',
      body: {'publicKey': publicKey, 'isEmulator': isEmulator},
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return User.fromJson(data);
    } else {
      throw Exception('Registration failed: ${response.body}');
    }
  }

  static Future<User> getUserProfile() async {
    final response = await _makeRequest(
      'GET',
      '/users/profile',
      requiresAuth: true,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return User.fromJson(data);
    } else {
      throw Exception('Failed to get profile: ${response.body}');
    }
  }

  static Future<void> setMobileMoneyNumber(String mobileNumber) async {
    final response = await _makeRequest(
      'POST',
      '/users/mobile-number',
      body: {'mobileNumber': mobileNumber},
      requiresAuth: true,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to set mobile number: ${response.body}');
    }
  }

  // Lesson endpoints
  static Future<List<Lesson>> getLessons({
    String? category,
    List<String>? tags,
    int page = 1,
    int limit = 20,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };

    if (category != null) queryParams['category'] = category;
    if (tags != null) queryParams['tags'] = tags.join(',');

    final queryString = queryParams.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
        .join('&');

    final response = await _makeRequest(
      'GET',
      '/lessons?$queryString',
      requiresAuth: true,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['lessons'] as List)
          .map((lesson) => Lesson.fromJson(lesson))
          .toList();
    } else {
      throw Exception('Failed to get lessons: ${response.body}');
    }
  }

  static Future<Lesson> getLessonById(String lessonId) async {
    final response = await _makeRequest(
      'GET',
      '/lessons/$lessonId',
      requiresAuth: true,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Lesson.fromJson(data['lesson']);
    } else {
      throw Exception('Failed to get lesson: ${response.body}');
    }
  }

  static Future<List<String>> getCategories() async {
    final response = await _makeRequest(
      'GET',
      '/lessons/categories',
      requiresAuth: true,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['categories'] as List)
          .map((cat) => cat['_id'] as String)
          .toList();
    } else {
      throw Exception('Failed to get categories: ${response.body}');
    }
  }

  // Earning endpoints
  static Future<Earning> recordEarning({
    required EarningSource source,
    String? lessonId,
    String? adSlotId,
  }) async {
    final response = await _makeRequest(
      'POST',
      '/earnings/record',
      body: {
        'source': source.value,
        'lessonId': lessonId,
        'adSlotId': adSlotId,
      },
      requiresAuth: true,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Earning.fromJson(data['earning']);
    } else {
      throw Exception('Failed to record earning: ${response.body}');
    }
  }

  static Future<List<Earning>> getEarningsHistory({
    int page = 1,
    int limit = 20,
    EarningSource? source,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };

    if (source != null) queryParams['source'] = source.value;

    final queryString = queryParams.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
        .join('&');

    final response = await _makeRequest(
      'GET',
      '/earnings/history?$queryString',
      requiresAuth: true,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['earnings'] as List)
          .map((earning) => Earning.fromJson(earning))
          .toList();
    } else {
      throw Exception('Failed to get earnings history: ${response.body}');
    }
  }

  // Payout endpoints
  static Future<Payout> requestPayout(double amountUsd) async {
    final nonce = CryptoUtils.generateNonce();
    final message = jsonEncode({
      'nonce': nonce,
      'amountUsd': amountUsd,
      'deviceId': _deviceId,
    });
    final signature = _privateKey != null
        ? CryptoUtils.createSignature(message, _privateKey!)
        : '';

    final response = await _makeRequest(
      'POST',
      '/payouts/request',
      body: {'amountUsd': amountUsd, 'signature': signature, 'nonce': nonce},
      requiresAuth: true,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Payout.fromJson(data['payout']);
    } else {
      throw Exception('Failed to request payout: ${response.body}');
    }
  }

  static Future<List<Payout>> getPayoutHistory({
    int page = 1,
    int limit = 20,
    PayoutStatus? status,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };

    if (status != null) queryParams['status'] = status.value;

    final queryString = queryParams.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
        .join('&');

    final response = await _makeRequest(
      'GET',
      '/payouts/history?$queryString',
      requiresAuth: true,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['payouts'] as List)
          .map((payout) => Payout.fromJson(payout))
          .toList();
    } else {
      throw Exception('Failed to get payout history: ${response.body}');
    }
  }

  static Future<CooldownStatus> getCooldownStatus() async {
    final response = await _makeRequest(
      'GET',
      '/payouts/cooldown',
      requiresAuth: true,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return CooldownStatus.fromJson(data);
    } else {
      throw Exception('Failed to get cooldown status: ${response.body}');
    }
  }
}
