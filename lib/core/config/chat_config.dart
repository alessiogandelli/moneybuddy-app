/// Configuration for the chat API
class ChatConfig {
  /// Your API endpoint URL - UPDATE THIS with your actual API URL
  static const String apiUrl = 'http://127.0.0.1:420/api';
  
  /// Alternative: if you're running locally during development
  // static const String apiUrl = 'http://localhost:3000/api';
  
  /// Alternative: if you're using a specific service
  // static const String apiUrl = 'https://your-backend-service.vercel.app/api';
  
  /// Timeout settings
  static const int connectionTimeoutSeconds = 30;
  static const int receiveTimeoutSeconds = 30;
}