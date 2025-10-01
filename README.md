# 🚚 Twende Nalo - Multi-Role Delivery Platform

A comprehensive Flutter delivery application connecting customers, shop owners, and riders in a seamless ecosystem.

## 🎯 Project Overview

**Twende Nalo** (Swahili for "Let's Go With It") is a production-ready delivery platform that enables:
- **Customers** to order from local shops
- **Shop Owners** to manage inventory and orders
- **Riders** to handle deliveries efficiently

## ✨ Features

### 👥 Multi-Role Authentication
- **Customer**: Browse shops, place orders, track deliveries
- **Shop Owner**: Manage inventory, process orders, view analytics
- **Rider**: Accept delivery tasks, track routes, manage earnings

### 🛍️ Core Features
- **Real-time Order Tracking** with live location updates
- **Secure Payment Processing** with M-Pesa integration
- **Push Notifications** for order status updates
- **In-app Chat Support** between all user types
- **Rating & Review System** for shops and riders
- **Promotional System** with referral codes
- **Multi-language Support** (English & Swahili)

### 🏪 Shop Management
- Product catalog management
- Inventory tracking
- Order processing dashboard
- Sales analytics
- Promotional campaigns

### 🚴 Rider Features
- Delivery task management
- Route optimization
- Earnings tracking
- Customer communication
- Proof of delivery

## 🏗️ Architecture

### Tech Stack
- **Frontend**: Flutter 3.x with Material 3
- **State Management**: Provider pattern
- **Navigation**: GoRouter for declarative routing
- **Backend**: Firebase (Auth, Firestore, Storage, Cloud Messaging)
- **Payment**: M-Pesa API integration
- **Maps**: Google Maps integration
- **Local Storage**: SharedPreferences + Hive

### Project Structure
```
lib/
├── core/                    # Core functionality
│   ├── constants/          # App constants & themes
│   ├── error_handling/    # Error handling & exceptions
│   ├── navigation/        # Routing configuration
│   ├── screens/          # Common screens
│   ├── theme/           # App theming
│   ├── utils/          # Utility functions
│   └── widgets/        # Reusable components
├── features/           # Feature modules
│   ├── auth/          # Authentication & user management
│   ├── cart/          # Shopping cart
│   ├── checkout/      # Checkout & payment
│   ├── delivery/      # Rider delivery system
│   ├── notifications/ # Push notifications
│   ├── orders/        # Order management
│   ├── promos/        # Promotions & referrals
│   ├── rating/        # Review & rating system
│   ├── shop/          # Shop management
│   └── support/       # Customer support chat
└── services/          # External service integrations
```

## 🚀 Getting Started

### Prerequisites
- Flutter 3.0.0 or higher
- Dart 3.0.0 or higher
- Firebase account
- Android Studio / VS Code
- Git

### Installation

1. **Clone the repository**
```bash
git clone https://github.com/yourusername/twende_nalo.git
cd twende_nalo
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Setup Firebase**
```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login to Firebase
firebase login

# Configure Firebase
flutterfire configure
```

4. **Run the app**
```bash
# Development
flutter run --flavor dev -t lib/main_dev.dart

# Staging
flutter run --flavor staging -t lib/main_staging.dart

# Production
flutter run --flavor prod -t lib/main.dart
```

### Environment Configuration

Create `.env` file in the root directory:
```env
# Firebase Configuration
FIREBASE_API_KEY=your_api_key
FIREBASE_AUTH_DOMAIN=your_auth_domain
FIREBASE_PROJECT_ID=your_project_id
FIREBASE_STORAGE_BUCKET=your_storage_bucket
FIREBASE_MESSAGING_SENDER_ID=your_sender_id
FIREBASE_APP_ID=your_app_id

# Payment Configuration
MPESA_CONSUMER_KEY=your_mpesa_key
MPESA_CONSUMER_SECRET=your_mpesa_secret
MPESA_SHORTCODE=your_shortcode
MPESA_PASSKEY=your_passkey

# Map Configuration
GOOGLE_MAPS_API_KEY=your_maps_api_key
```

## 🧪 Testing

### Running Tests
```bash
# Unit tests
flutter test

# Widget tests
flutter test test/widget/

# Integration tests
flutter test integration_test/

# Coverage report
flutter test --coverage
```

### Test Structure
- **Unit Tests**: Services, models, utilities
- **Widget Tests**: UI components, user interactions
- **Integration Tests**: End-to-end workflows

## 📱 Supported Platforms
- ✅ **Android** (API 21+)
- ✅ **iOS** (iOS 11+)
- ✅ **Web** (Modern browsers)
- ✅ **macOS** (macOS 10.14+)
- ✅ **Windows** (Windows 10+)
- ✅ **Linux** (Ubuntu 18.04+)

## 🔧 Development Guidelines

### Code Style
- Follow the [Flutter style guide](https://flutter.dev/docs/development/tools/formatting)
- Use `flutter analyze` for static analysis
- Use `dart format` for code formatting

### Git Workflow
1. Create feature branch: `git checkout -b feature/your-feature`
2. Commit changes: `git commit -m "Add: your feature"`
3. Push to branch: `git push origin feature/your-feature`
4. Create Pull Request

### Branch Naming
- `feature/` - New features
- `fix/` - Bug fixes
- `docs/` - Documentation updates
- `refactor/` - Code refactoring

## 🚀 Deployment

### Android Release
```bash
flutter build appbundle --release
```

### iOS Release
```bash
flutter build ios --release
```

### Web Release
```bash
flutter build web --release
```

## 📊 Performance Monitoring

### Firebase Analytics
- User engagement tracking
- Conversion funnel analysis
- Crash reporting with Crashlytics

### Performance Metrics
- App startup time < 3 seconds
- API response time < 500ms
- Image loading time < 2 seconds
- Offline capability enabled

## 🔐 Security Features

- **Data Encryption**: All sensitive data encrypted at rest
- **Secure Communication**: HTTPS/TLS for all network calls
- **Authentication**: Firebase Auth with multi-factor authentication
- **Input Validation**: Client and server-side validation
- **Rate Limiting**: API rate limiting to prevent abuse

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👥 Team

- **Lead Developer**: [Your Name]
- **UI/UX Designer**: [Designer Name]
- **Backend Developer**: [Backend Name]
- **QA Engineer**: [QA Name]

## 📞 Support

For support, email support@twendenalo.com or join our Slack channel.

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Firebase team for the backend services
- All contributors who helped shape this project

---

**Made with ❤️ by the Twende Nalo Team**
