import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../config/api.dart';
import 'auth_service.dart';

class PaymentService {
  final AuthService _auth = AuthService();

  /// Initiate payment for a course (uses course slug)
  Future<Map<String, dynamic>> initiatePayment({
    required String courseSlug,
    String? paymentMethod,
  }) async {
    final token = await _auth.getToken();

    final body = <String, dynamic>{};
    if (paymentMethod != null) body["payment_method"] = paymentMethod;

    final response = await http.post(
      Uri.parse("${ApiConfig.baseUrl}/courses/$courseSlug/payment"),
      headers: {
        if (token != null) "Authorization": "Bearer $token",
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
      body: jsonEncode(body),
    );

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  /// Confirm payment after user completes payment (with receipt image)
  Future<Map<String, dynamic>> confirmPayment({
    required String orderId,
    File? receiptImage,
    String confirmationMethod = 'upload', // 'whatsapp', 'upload', or 'admin'
  }) async {
    final token = await _auth.getToken();

    if (receiptImage != null) {
      // Upload with image
      final request = http.MultipartRequest(
        'POST',
        Uri.parse("${ApiConfig.baseUrl}/payments/confirm"),
      );

      request.headers.addAll({
        if (token != null) "Authorization": "Bearer $token",
        "Accept": "application/json",
      });

      request.fields['order_id'] = orderId;
      request.fields['confirmation_method'] = confirmationMethod;

      final file = await http.MultipartFile.fromPath(
        'receipt_image',
        receiptImage.path,
        contentType: MediaType('image', 'jpeg'),
      );
      request.files.add(file);

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      // Without image (for whatsapp or admin confirmation)
      final response = await http.post(
        Uri.parse("${ApiConfig.baseUrl}/payments/confirm"),
        headers: {
          if (token != null) "Authorization": "Bearer $token",
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({
          "order_id": orderId,
          "confirmation_method": confirmationMethod,
        }),
      );

      return jsonDecode(response.body) as Map<String, dynamic>;
    }
  }

  /// Get payment status
  Future<Map<String, dynamic>> getPaymentStatus(String orderId) async {
    final token = await _auth.getToken();

    final response = await http.get(
      Uri.parse("${ApiConfig.baseUrl}/payments/$orderId/status"),
      headers: {
        if (token != null) "Authorization": "Bearer $token",
        "Accept": "application/json",
      },
    );

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  /// Get user's payment history
  Future<Map<String, dynamic>> getPaymentHistory() async {
    final token = await _auth.getToken();

    final response = await http.get(
      Uri.parse("${ApiConfig.baseUrl}/payments/history"),
      headers: {
        if (token != null) "Authorization": "Bearer $token",
        "Accept": "application/json",
      },
    );

    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}

