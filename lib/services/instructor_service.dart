import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:courses_app/config/api.dart';
import 'package:courses_app/services/auth_service.dart';

class InstructorService {
  final AuthService _auth = AuthService();

  /// Test instructor API connectivity
  Future<Map<String, dynamic>> testInstructorApi() async {
    print('🔵 Testing instructor API connectivity...');
    
    final token = await _auth.getToken();
    if (token == null) {
      return {
        'success': false,
        'message': 'No authentication token',
        'error': 'Not authenticated'
      };
    }

    try {
      // First try a simple GET to the main API
      print('🔵 Testing main API endpoint...');
      final mainResponse = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/me'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );
      
      print('🔵 Main API response status: ${mainResponse.statusCode}');
      
      if (mainResponse.statusCode != 200) {
        return {
          'success': false,
          'message': 'Main API not accessible',
          'error': 'Status: ${mainResponse.statusCode}',
        };
      }
      
      // Now test instructor API
      print('🔵 Testing instructor API endpoint...');
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/v1/instructor/test'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );
      
      print('🔵 Test response status: ${response.statusCode}');
      print('🔵 Test response body: ${response.body}');
      
      final data = response.body.isNotEmpty ? jsonDecode(response.body) : null;

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Instructor API is working!',
          'data': data,
        };
      } else {
        return {
          'success': false,
          'message': data?['message'] ?? 'Test failed',
          'error': 'Status: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('❌ Test failed: $e');
      return {
        'success': false,
        'message': 'Test failed',
        'error': e.toString(),
      };
    }
  }

  /// Submit instructor application
  Future<Map<String, dynamic>> applyToInstructor({
    required String educationLevel,
    required String department,
    required double yearsOfExperience,
    required String experienceDescription,
    String? linkedinUrl,
    String? portfolioUrl,
    List<File>? certificates,
  }) async {
    print('🔵 Submitting instructor application...');
    print('🔵 Certificates: ${certificates?.length ?? 0} files');
    
    final token = await _auth.getToken();
    print('🔵 Token: ${token?.substring(0, 20) ?? 'null'}...');
    
    if (token == null) {
      return {
        'success': false,
        'message': 'No authentication token',
        'error': 'Not authenticated'
      };
    }

    try {
      final url = '${ApiConfig.baseUrl}/instructor-apply';
      print('🔵 Full URL: $url');
      
      // If there are certificates, use multipart request
      if (certificates != null && certificates.isNotEmpty) {
        print('🔵 Using multipart request with ${certificates.length} certificates');
        
        final request = http.MultipartRequest('POST', Uri.parse(url));
        request.headers['Authorization'] = 'Bearer $token';
        request.headers['Accept'] = 'application/json';
        
        // Add text fields
        request.fields['education_level'] = educationLevel;
        request.fields['department'] = department;
        request.fields['years_of_experience'] = yearsOfExperience.toInt().toString();
        request.fields['experience_description'] = experienceDescription;
        request.fields['agreed_to_terms'] = 'true';
        if (linkedinUrl != null && linkedinUrl.isNotEmpty) {
          request.fields['linkedin_url'] = linkedinUrl;
        }
        if (portfolioUrl != null && portfolioUrl.isNotEmpty) {
          request.fields['portfolio_url'] = portfolioUrl;
        }
        
        // Add certificate files
        for (var i = 0; i < certificates.length; i++) {
          final file = certificates[i];
          final fileSize = await file.length();
          print('🔵 Adding certificate $i: ${file.path} (${(fileSize / 1024 / 1024).toStringAsFixed(2)} MB)');
          
          if (fileSize > 15 * 1024 * 1024) {
            return {
              'success': false,
              'message': 'حجم الملف كبير جداً (الحد الأقصى 15MB)',
            };
          }
          
          request.files.add(await http.MultipartFile.fromPath(
            'certificates[$i]',
            file.path,
          ));
        }
        
        print('🔵 Sending multipart request...');
        final streamedResponse = await request.send();
        final response = await http.Response.fromStream(streamedResponse);
        
        print('🔵 Response status: ${response.statusCode}');
        print('🔵 Response body: ${response.body}');
        
        final data = response.body.isNotEmpty ? jsonDecode(response.body) : null;
        
        if (response.statusCode == 200 && data?['success'] == true) {
          return {
            'success': true,
            'message': data?['message'] ?? 'Application submitted successfully!',
            'status': data?['status'] ?? 'instructor',
            'data': data,
          };
        } else {
          return {
            'success': false,
            'message': data?['message'] ?? 'Failed to submit application',
            'error': 'Status: ${response.statusCode}',
            'data': data,
          };
        }
      } else {
        // No certificates - use simple JSON request
        print('🔵 Using JSON request without certificates');
        
        final body = {
          'education_level': educationLevel,
          'department': department,
          'years_of_experience': yearsOfExperience.toInt(),
          'experience_description': experienceDescription,
          'agreed_to_terms': true,
        };
        
        // Only add optional fields if they have values
        if (linkedinUrl != null && linkedinUrl.isNotEmpty) {
          body['linkedin_url'] = linkedinUrl;
        }
        if (portfolioUrl != null && portfolioUrl.isNotEmpty) {
          body['portfolio_url'] = portfolioUrl;
        }
        
        final response = await http.post(
          Uri.parse(url),
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
          body: jsonEncode(body),
        );
        
        print('🔵 Response status: ${response.statusCode}');
        print('🔵 Response body: ${response.body}');

        final data = response.body.isNotEmpty ? jsonDecode(response.body) : null;

        if (response.statusCode == 200 && data?['success'] == true) {
          return {
            'success': true,
            'message': data?['message'] ?? 'Application submitted successfully!',
            'status': data?['status'] ?? 'instructor',
            'data': data,
          };
        } else {
          return {
            'success': false,
            'message': data?['message'] ?? 'Failed to submit application',
            'error': 'Status: ${response.statusCode}',
            'data': data,
          };
        }
      }
    } catch (e) {
      print('❌ Instructor application error: $e');
      return {
        'success': false,
        'message': 'خطأ في إرسال الطلب',
        'error': e.toString(),
      };
    }
  }

  /// Get current user's instructor application status
  Future<Map<String, dynamic>> getMyApplication() async {
    print('🔵 Getting instructor application status...');
    
    final token = await _auth.getToken();
    if (token == null) {
      return {
        'success': false,
        'message': 'No authentication token',
        'error': 'Not authenticated'
      };
    }

    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/v1/instructor/application'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      print('🔵 Application status response: ${response.statusCode}');
      print('🔵 Response body: ${response.body}');

      final data = response.body.isNotEmpty ? jsonDecode(response.body) : null;

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data?['message'] ?? 'Application retrieved successfully',
          'application': data?['application'],
          'data': data,
        };
      } else {
        return {
          'success': false,
          'message': data?['message'] ?? 'Failed to get application',
          'error': data?['error'] ?? 'Unknown error',
          'data': data,
        };
      }
    } catch (e) {
      print('❌ Get application error: $e');
      return {
        'success': false,
        'message': 'خطأ في جلب الطلب',
        'error': e.toString(),
      };
    }
  }

  /// Cancel instructor application
  Future<Map<String, dynamic>> cancelApplication() async {
    print('🔵 Canceling instructor application...');
    
    final token = await _auth.getToken();
    if (token == null) {
      return {
        'success': false,
        'message': 'No authentication token',
        'error': 'Not authenticated'
      };
    }

    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/v1/instructor/application'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      print('🔵 Cancel application response: ${response.statusCode}');
      print('🔵 Response body: ${response.body}');

      final data = response.body.isNotEmpty ? jsonDecode(response.body) : null;

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data?['message'] ?? 'Application canceled successfully',
          'data': data,
        };
      } else {
        return {
          'success': false,
          'message': data?['message'] ?? 'Failed to cancel application',
          'error': data?['error'] ?? 'Unknown error',
          'data': data,
        };
      }
    } catch (e) {
      print('❌ Cancel application error: $e');
      return {
        'success': false,
        'message': 'خطأ في إلغاء الطلب',
        'error': e.toString(),
      };
    }
  }
}
