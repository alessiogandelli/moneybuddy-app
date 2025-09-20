import 'package:dio/dio.dart';
import '../../core/config/chat_config.dart';

/// Simple service to communicate with the chat API
class SimpleChatService {
  final Dio _dio;
  final String baseUrl;

  SimpleChatService({
    String? apiUrl,
  }) : baseUrl = apiUrl ?? ChatConfig.apiUrl,
        _dio = Dio() {
    
    // Setup basic headers
    _dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    
    // Add timeout
    _dio.options.connectTimeout = Duration(seconds: ChatConfig.connectionTimeoutSeconds);
    _dio.options.receiveTimeout = Duration(seconds: ChatConfig.receiveTimeoutSeconds);
  }

  /// Send message to API and get response
  Future<String> sendMessage(String message) async {
    try {
      print('🚀 Sending message to API: $message');
      
      final fullUrl = '$baseUrl/chat';
      print('🔗 Full URL: $fullUrl');
      
      final response = await _dio.post(
        '$baseUrl/chat',
        data: {
          'message': message,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      if (response.statusCode == 200) {
        print('✅ Raw API response: ${response.data}');
        
        final responseData = response.data;
        String aiResponse = 'No response from server';
        
        // Check if we got HTML instead of JSON (common API configuration issue)
        if (responseData is String && responseData.toLowerCase().contains('<html>')) {
          throw Exception('Received HTML instead of JSON - check your API URL configuration');
        }
        
        // Handle different response formats safely
        if (responseData is Map<String, dynamic>) {
          // Try common response field names
          aiResponse = responseData['response']?.toString() ?? 
                      responseData['message']?.toString() ?? 
                      responseData['reply']?.toString() ?? 
                      responseData['text']?.toString() ?? 
                      'No response from server';
        } else if (responseData is String) {
          aiResponse = responseData;
        } else {
          aiResponse = responseData.toString();
        }
        
        print('✅ Parsed response: $aiResponse');
        return aiResponse;
      } else {
        throw Exception('API returned status ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('❌ API Error: ${e.message}');
      
      if (e.type == DioExceptionType.connectionTimeout) {
        return 'Sorry, the connection timed out. Please check your internet connection.';
      } else if (e.type == DioExceptionType.receiveTimeout) {
        return 'Sorry, the server is taking too long to respond. Please try again.';
      } else if (e.response?.statusCode == 500) {
        return 'Sorry, there\'s a server error. Please try again later.';
      } else {
        return 'Sorry, I\'m having trouble connecting right now. Please try again.';
      }
    } catch (e) {
      print('❌ Unexpected error: $e');
      print('❌ Error type: ${e.runtimeType}');
      
      if (e.toString().contains('Received HTML instead of JSON')) {
        return '⚠️ API Configuration Error: Please update your API URL in chat_config.dart. Currently pointing to a redirect page.';
      }
      
      return 'Sorry, something went wrong. Please try again.';
    }
  }

  /// Update API URL if needed
  void updateApiUrl(String newUrl) {
    // You can call this method to change the API endpoint
    // For example: chatService.updateApiUrl('https://your-new-api.com/api');
    print('API URL updated to: $newUrl');
  }
}