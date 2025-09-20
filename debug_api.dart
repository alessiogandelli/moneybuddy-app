import 'dart:convert';
import 'dart:io';

/// Debug script to check your API response and find the problematic characters
void main() async {
  print('🔍 Debugging your API at http://localhost:420/transaction');
  
  try {
    final client = HttpClient();
    final request = await client.getUrl(Uri.parse('http://localhost:420/transaction'));
    final response = await request.close();
    
    print('📊 Response Status: ${response.statusCode}');
    print('📊 Response Headers: ${response.headers}');
    
    final responseBody = await response.transform(utf8.decoder).join();
    
    print('📊 Response Length: ${responseBody.length} characters');
    print('📊 First 200 characters: ${responseBody.substring(0, responseBody.length > 200 ? 200 : responseBody.length)}');
    
    // Check around the problematic offset (4743)
    if (responseBody.length > 4743) {
      final start = (4743 - 50).clamp(0, responseBody.length);
      final end = (4743 + 50).clamp(0, responseBody.length);
      print('📊 Characters around offset 4743:');
      print('   Text: "${responseBody.substring(start, end)}"');
      print('   Char codes: ${responseBody.substring(start, end).codeUnits}');
    }
    
    // Try to parse as JSON
    try {
      final jsonData = json.decode(responseBody);
      print('✅ JSON is valid!');
      
      if (jsonData is List) {
        print('📊 Found ${jsonData.length} transaction entries');
        
        // Check each transaction entry
        for (int i = 0; i < jsonData.length; i++) {
          try {
            final entry = jsonData[i];
            print('Entry $i: ${entry.keys?.take(5)?.join(", ")}...');
            
            // Check required fields
            final requiredFields = ['direction', 'amount', 'currency'];
            for (final field in requiredFields) {
              if (entry[field] == null) {
                print('  ⚠️  Missing required field: $field');
              }
            }
          } catch (e) {
            print('  🚨 Problem with entry $i: $e');
          }
        }
      } else {
        print('📊 Response is not a list: ${jsonData.runtimeType}');
      }
      
    } catch (e) {
      print('🚨 JSON parsing failed: $e');
      
      // Find problematic characters
      final cleanResponse = responseBody.replaceAll(RegExp(r'[\x00-\x1F\x7F]'), '?');
      if (cleanResponse != responseBody) {
        print('🔧 Found control characters that might be causing issues');
      }
      
      // Try to find where JSON becomes invalid
      for (int i = 0; i < responseBody.length; i += 100) {
        try {
          json.decode(responseBody.substring(0, i + 100));
        } catch (e) {
          print('🔍 JSON becomes invalid around character $i');
          final start = (i - 50).clamp(0, responseBody.length);
          final end = (i + 150).clamp(0, responseBody.length);
          print('   Context: "${responseBody.substring(start, end)}"');
          break;
        }
      }
    }
    
    client.close();
    
  } catch (e) {
    print('🚨 Network error: $e');
  }
}