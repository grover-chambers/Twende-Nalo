class RoutePaths {
  // Auth routes
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String otp = '/otp';
  static const String forgotPassword = '/forgot-password';
  static const String roleSelection = '/role-selection';
  
  // Main app routes
  static const String home = '/home';
  static const String profile = '/profile';
  
  // Shop routes
  static const String shopList = '/shops';
  static const String shopDetail = '/shop/:shopId';
  static const String shopOwner = '/shop-owner';
  static const String addItem = '/shop/add-item';
  
  // Cart routes
  static const String cart = '/cart';
  
  // Checkout routes
  static const String checkout = '/checkout';
  static const String payment = '/payment';
  static const String confirmation = '/confirmation';
  
  // Order routes
  static const String orders = '/orders';
  static const String orderDetail = '/order/:orderId';
  static const String orderHistory = '/order-history';
  
  // Delivery routes
  static const String riderDashboard = '/rider-dashboard';
  static const String deliveryTracking = '/delivery-tracking/:orderId';
  static const String riderTracking = '/rider-tracking';
  
  // Support routes
  static const String supportChat = '/support-chat';
  static const String chat = '/chat/:userId';
  
  // Notification routes
  static const String notifications = '/notifications';
  
  // Promo routes
  static const String promos = '/promos';
  static const String referral = '/referral';
  
  // Rating routes
  static const String rating = '/rating/:orderId';
}
