# MoneyBuddy - AI-Powered Personal Finance App

![MoneyBuddy Logo](assets/images/logo.png)

MoneyBuddy is an intelligent personal finance application that helps users track expenses, gain insights into spending patterns, and achieve their financial goals through the power of AI assistant MoneyCA.

## 🚀 Features

### Core Functionality
- **Smart Transaction Tracking**: Multiple input methods including voice, chat, camera, and traditional forms
- **AI Assistant (MoneyCA)**: Omnipresent AI that helps with data entry and provides financial insights
- **Intelligent Categorization**: Automatic transaction categorization and company logo detection
- **Spending Insights**: Advanced analytics showing spending patterns and trends
- **Personalized Experience**: Different behaviors based on user financial segments

### User Segments
- **Beginner**: Just starting their financial journey
- **Saver**: Focused on building savings and emergency funds  
- **Investor**: Interested in growing wealth through investments
- **Wealthy**: High income users with sophisticated financial needs
- **Recoverer**: Users needing help with debt and budgeting

### AI-Powered Features
- **Conversational Onboarding**: Natural conversation flow to understand user needs
- **Voice Transaction Entry**: Speech-to-text powered expense logging
- **Smart Insights**: AI-generated spending analysis and recommendations
- **Personalized Advice**: Different financial guidance based on user segment

## 🏗️ Architecture

### Project Structure
```
lib/
├── core/                   # Core app functionality
│   ├── constants/         # App constants and configurations
│   ├── error/            # Error handling utilities
│   ├── routes/           # Navigation and routing
│   ├── theme/            # App theming and styling
│   └── utils/            # Common utilities
├── data/                  # Data layer
│   ├── local/            # Local storage (Hive)
│   ├── models/           # Data models and entities
│   ├── remote/           # API services and clients
│   └── repositories/     # Data repositories
├── features/              # Feature modules
│   ├── onboarding/       # User onboarding and segmentation
│   ├── transactions/     # Transaction management
│   ├── insights/         # Analytics and insights
│   ├── chat/             # MoneyCA AI assistant
│   └── dashboard/        # Main dashboard
├── shared/               # Shared UI components and widgets
└── main.dart            # App entry point
```

### Tech Stack
- **Framework**: Flutter 3.8+
- **State Management**: BLoC/Cubit pattern
- **Navigation**: go_router
- **Local Storage**: Hive (offline-first approach)
- **Networking**: Dio with Retrofit
- **AI Integration**: IBM Watson (via custom API server)
- **Media Access**: Camera & Speech-to-Text plugins

### Architecture Patterns
- **Clean Architecture**: Separation of concerns with clear layer boundaries
- **BLoC Pattern**: Reactive state management
- **Repository Pattern**: Abstraction of data sources
- **Feature-First**: Modular organization by features

## 🎨 Design Philosophy

### User Experience
- **Conversational Interface**: Natural language interaction with MoneyCA
- **Offline-First**: Core functionality works without internet connection
- **Progressive Disclosure**: Information revealed based on user expertise level
- **Personalized Journey**: Different flows for different user segments

### Visual Design
- **Modern Material Design**: Clean, accessible interface
- **Financial App Aesthetics**: Trust-inspiring color scheme and typography
- **Responsive Layout**: Optimized for various screen sizes
- **Micro-interactions**: Smooth animations for better user engagement

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.8+
- Dart 3.0+
- iOS 12.0+ / Android API 21+
- IBM Watson API credentials (for AI features)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/alessiogandelli/moneybuddy-app.git
   cd moneybuddy-app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Set up assets**
   - Add app icons to `assets/icons/`
   - Add logo and branding images to `assets/images/`
   - Add Inter font files to `assets/fonts/`

4. **Configure API endpoints**
   - Update API URLs in `lib/core/constants/api_constants.dart`
   - Add IBM Watson credentials to your environment

5. **Run the app**
   ```bash
   flutter run
   ```

### Environment Setup
Create a `.env` file in the root directory:
```
API_BASE_URL=https://your-api-server.com
IBM_WATSON_API_KEY=your_watson_api_key
IBM_WATSON_URL=your_watson_url
```

## 📱 Features Implementation Status

- [x] App structure and navigation
- [x] User models and data layer
- [x] Local caching with Hive
- [x] Basic UI screens and components
- [x] Theme and styling system
- [ ] IBM Watson API integration
- [ ] Voice transaction entry
- [ ] Camera receipt scanning
- [ ] Advanced analytics and insights
- [ ] Real-time sync with server
- [ ] Push notifications
- [ ] Biometric authentication

## 🧪 Development

### Running Tests
```bash
# Unit tests
flutter test

# Integration tests
flutter test integration_test/
```

### Code Generation
```bash
# Generate model serialization code
flutter packages pub run build_runner build

# Watch for changes
flutter packages pub run build_runner watch
```

### Linting
```bash
flutter analyze
```

## 🤖 AI Integration

### MoneyCA Assistant
MoneyCA is the AI-powered assistant that provides:
- Natural language transaction entry
- Spending pattern analysis
- Personalized financial advice
- Goal tracking and recommendations

### IBM Watson Integration
- **Natural Language Understanding**: For parsing user inputs
- **Text-to-Speech/Speech-to-Text**: For voice interactions
- **Assistant**: For conversational flows
- **Discovery**: For insights generation

## 📊 Analytics and Insights

### Spending Analytics
- Monthly/weekly spending trends
- Category-wise breakdown
- Budget vs actual comparisons
- Spending velocity analysis

### AI-Generated Insights
- Unusual spending pattern detection
- Budget optimization suggestions
- Goal achievement tracking
- Personalized recommendations based on user segment

## 🔒 Privacy and Security

- **Local-First Data**: Sensitive data cached locally
- **Encrypted Storage**: Hive boxes with encryption
- **Secure API Communication**: HTTPS with token authentication
- **Privacy by Design**: Minimal data collection, user consent

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👥 Team

- **Alessio Gandelli** - Main Developer
- **MoneyCA** - AI Assistant (powered by IBM Watson)

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- IBM for Watson AI services and hackathon support
- StartHack 2025 organizing team
- Open source package maintainers

---

**MoneyBuddy** - Making personal finance intelligent and accessible for everyone 💰🤖
