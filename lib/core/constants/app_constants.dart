class AppConstants {
  // App Information
  static const String appName = 'Twende Nalo';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Multi-Role Delivery Platform';

  // User Roles
  static const String roleCustomer = 'customer';
  static const String roleShopOwner = 'shop_owner';
  static const String roleRider = 'rider';

  // Collection Names (Firebase)
  static const String usersCollection = 'users';
  static const String shopsCollection = 'shops';
  static const String productsCollection = 'products';
  static const String ordersCollection = 'orders';
  static const String cartCollection = 'cart';
  static const String deliveriesCollection = 'deliveries';
  static const String reviewsCollection = 'reviews';
  static const String promosCollection = 'promos';
  static const String notificationsCollection = 'notifications';
  static const String chatsCollection = 'chats';

  // Order Status
  static const String orderPending = 'pending';
  static const String orderConfirmed = 'confirmed';
  static const String orderPreparing = 'preparing';
  static const String orderReadyForPickup = 'ready_for_pickup';
  static const String orderPickedUp = 'picked_up';
  static const String orderInTransit = 'in_transit';
  static const String orderDelivered = 'delivered';
  static const String orderCancelled = 'cancelled';
  static const String orderRefunded = 'refunded';

  // Payment Methods
  static const String paymentMpesa = 'mpesa';
  static const String paymentCard = 'card';
  static const String paymentCash = 'cash';

  // Payment Status
  static const String paymentPending = 'pending';
  static const String paymentCompleted = 'completed';
  static const String paymentFailed = 'failed';
  static const String paymentRefunded = 'refunded';

  // Delivery Status
  static const String deliveryAssigned = 'assigned';
  static const String deliveryAccepted = 'accepted';
  static const String deliveryPickedUp = 'picked_up';
  static const String deliveryInTransit = 'in_transit';
  static const String deliveryCompleted = 'completed';
  static const String deliveryCancelled = 'cancelled';

  // App URLs
  static const String termsOfServiceUrl = 'https://twendenalo.com/terms';
  static const String privacyPolicyUrl = 'https://twendenalo.com/privacy';
  static const String supportEmail = 'support@twendenalo.com';
  static const String supportPhone = '+254700000000';

  // API Endpoints
  static const String baseApiUrl = 'https://api.twendenalo.com';
  static const String mpesaApiUrl = 'https://sandbox.safaricom.co.ke';

  // Storage Keys
  static const String userTokenKey = 'user_token';
  static const String userRoleKey = 'user_role';
  static const String userIdKey = 'user_id';
  static const String themeKey = 'theme_mode';
  static const String languageKey = 'language';
  static const String onboardingCompleted = 'onboarding_completed';

  // Notification Types
  static const String notificationOrderUpdate = 'order_update';
  static const String notificationPromo = 'promo';
  static const String notificationDelivery = 'delivery';
  static const String notificationChat = 'chat';
  static const String notificationSystem = 'system';

  // Limits and Constraints
  static const int maxCartItems = 50;
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB
  static const int minPasswordLength = 8;
  static const int maxNameLength = 50;
  static const int maxDescriptionLength = 500;
  static const int maxReviewLength = 1000;
  static const double minDeliveryRadius = 0.5; // km
  static const double maxDeliveryRadius = 20.0; // km
  static const double deliveryFeePerKm = 50.0; // KES
  static const double minOrderAmount = 100.0; // KES
  static const int orderTimeoutMinutes = 30;

  // Map Settings
  static const double defaultLatitude = -1.2921;
  static const double defaultLongitude = 36.8219; // Nairobi coordinates
  static const double defaultZoom = 12.0;

  // Rating
  static const double minRating = 1.0;
  static const double maxRating = 5.0;

  // Regex Patterns
  static const String emailRegex = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
  static const String phoneRegex = r'^\+254[17]\d{8}$'; // Kenyan phone format
  static const String mpesaRegex = r'^254[17]\d{8}$'; // M-Pesa format

  // Error Messages
  static const String networkError = 'Network connection error';
  static const String unknownError = 'An unknown error occurred';
  static const String authenticationError = 'Authentication failed';
  static const String permissionError = 'Permission denied';
  static const String timeoutError = 'Request timeout';

  // Success Messages
  static const String orderPlacedSuccess = 'Order placed successfully';
  static const String paymentSuccessful = 'Payment completed successfully';
  static const String profileUpdated = 'Profile updated successfully';
  static const String passwordChanged = 'Password changed successfully';

  // Cache Duration
  static const Duration cacheDuration = Duration(minutes: 30);
  static const Duration locationUpdateInterval = Duration(seconds: 30);

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 400);
  static const Duration longAnimation = Duration(milliseconds: 600);
}
