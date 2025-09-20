# Chat Integration Setup

## How to configure your API

1. **Update the API URL:**
   - Open `lib/core/config/chat_config.dart`
   - Replace `https://your-api-endpoint.com/api` with your actual API URL

2. **Expected API Format:**

Your API should accept POST requests to `/chat` endpoint with this format:

**Request:**
```json
{
  "message": "User's message here",
  "timestamp": "2025-09-20T10:30:00.000Z"
}
```

**Response:**
```json
{
  "response": "AI response here"
}
```

OR alternatively:
```json
{
  "message": "AI response here"
}
```

3. **Testing:**
   - The chat will automatically handle errors and show user-friendly messages
   - Check your console/logs for API call details (marked with 🚀 and ✅/❌)

4. **Common configurations:**

For local development:
```dart
static const String apiUrl = 'http://localhost:3000/api';
```

For deployed service:
```dart
static const String apiUrl = 'https://your-backend.vercel.app/api';
```

## Error Handling

The chat automatically handles:
- Connection timeouts
- Server errors (500)
- Network connectivity issues
- API response parsing

Users will see friendly error messages like:
- "Sorry, the connection timed out. Please check your internet connection."
- "Sorry, there's a server error. Please try again later."
- "Sorry, I'm having trouble connecting right now. Please try again."