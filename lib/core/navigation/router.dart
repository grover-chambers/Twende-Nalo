import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

// Auth imports
import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/auth/screens/forgot_password_screen.dart';
import '../../features/auth/screens/profile_screen.dart';
import '../../features/auth/screens/role_selection_screen.dart';

// Shop imports
import '../../features/shop/screens/shop_list_screen.dart';
import '../../features/shop/screens/shop_detail_screen.dart';

// Cart imports
import '../../features/cart/screens/cart_screen.dart';

// Checkout imports
import '../../features/checkout/screens/payment_screen.dart';
import '../../features/checkout/screens/confirmation_screen.dart';

// Order imports
import '../../features/orders/screens/order_history_screen.dart';
import '../../features/orders/screens/order_detail_screen.dart';

// Delivery imports
import '../../features/delivery/screens/rider_dashboard_screen.dart';
import '../../features/delivery/screens/delivery_tracking_screen.dart';

// Support imports
import '../../features/support/screens/support_chat_screen.dart';

// Rating imports
import '../../features/rating/screens/rating_screen.dart';
import '../../features/rating/models/review.dart';

// Notification imports
import '../../features/notifications/screens/notification_screen.dart';

// Promo imports
import '../../features/promos/screens/promo_screen.dart';

// Core imports
import '../screens/splash_screen.dart';
import '../screens/main_navigation_screen.dart';
import '../screens/error_screen.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  static GoRouter get router => _router;

  static final _router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final authProvider = context.read<AuthProvider>();
      final isAuthenticated = authProvider.isAuthenticated;
      final isLoading = authProvider.isLoading;

      // Show splash screen while loading
      if (isLoading && state.matchedLocation == '/splash') {
        return null;
      }

      // Protected routes
      final protectedRoutes = [
        '/home',
        '/shops',
        '/cart',
        '/checkout',
        '/orders',
        '/profile',
        '/delivery',
        '/support',
        '/notifications',
        '/promos',
      ];

      final isProtectedRoute = protectedRoutes.any(
        (route) => state.matchedLocation.startsWith(route),
      );

      // Auth routes
      final authRoutes = ['/login', '/register', '/forgot-password'];
      final isAuthRoute = authRoutes.contains(state.matchedLocation);

      // Redirect logic
      if (!isAuthenticated && isProtectedRoute) {
        return '/login';
      }

      if (isAuthenticated && isAuthRoute) {
        return '/home';
      }

      return null; // No redirect needed
    },
    routes: [
      // Splash Screen
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // Authentication Routes
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        name: 'forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/role-selection',
        name: 'role-selection',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return RoleSelectionScreen(
            email: extra['email'] ?? '',
            name: extra['name'] ?? '',
            phone: extra['phone'] ?? '',
          );
        },
      ),

      // Main Shell with Bottom Navigation
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return MainNavigationScreen(child: child);
        },
        routes: [
          // Home/Shop List
          GoRoute(
            path: '/home',
            name: 'home',
            builder: (context, state) => const ShopListScreen(),
            routes: [
              // Shop Detail
              GoRoute(
                path: 'shop/:shopId',
                name: 'shop-detail',
                builder: (context, state) {
                  final shopId = state.pathParameters['shopId']!;
                  return ShopDetailScreen(shopId: shopId);
                },
              ),
            ],
          ),

          // Cart
          GoRoute(
            path: '/cart',
            name: 'cart',
            builder: (context, state) => const CartScreen(),
            routes: [
              // Checkout Flow
              GoRoute(
                path: 'payment',
                name: 'payment',
                builder: (context, state) => const PaymentScreen(),
                routes: [
                  // Order Confirmation
                  GoRoute(
                    path: 'confirmation/:orderId',
                    name: 'order-confirmation',
                    builder: (context, state) {
                      final orderId = state.pathParameters['orderId']!;
                      return ConfirmationScreen(orderId: orderId);
                    },
                  ),
                ],
              ),
            ],
          ),

          // Orders
          GoRoute(
            path: '/orders',
            name: 'orders',
            builder: (context, state) => const OrderHistoryScreen(),
            routes: [
              // Order Detail
              GoRoute(
                path: ':orderId',
                name: 'order-detail',
                builder: (context, state) {
                  final orderId = state.pathParameters['orderId']!;
                  return OrderDetailScreen(orderId: orderId);
                },
                routes: [
                  // Order Tracking
                  GoRoute(
                    path: 'tracking',
                    name: 'order-tracking',
                    builder: (context, state) {
                      final orderId = state.pathParameters['orderId']!;
                      // For now, use orderId as deliveryId since they may be the same
                      // In a real implementation, we would fetch the deliveryId from the order
                      return DeliveryTrackingScreen(deliveryId: orderId);
                    },
                  ),
                  // Rating
                  GoRoute(
                    path: 'rating',
                    name: 'order-rating',
                    builder: (context, state) {
                      final orderId = state.pathParameters['orderId']!;
                      final extra = state.extra as Map<String, dynamic>? ?? {};
                      final reviewType = _parseReviewType(extra['ratingType'] ?? 'userToShop');
                      final reviewedId = extra['targetId'] ?? '';
                      
                      return RatingScreen(
                        orderId: orderId,
                        reviewedId: reviewedId,
                        reviewType: reviewType,
                      );
                    },
                  ),
                ],
              ),
            ],
          ),

          // Profile
          GoRoute(
            path: '/profile',
            name: 'profile',
            builder: (context, state) => const ProfileScreen(),
          ),

          // Notifications
          GoRoute(
            path: '/notifications',
            name: 'notifications',
            builder: (context, state) => const NotificationScreen(),
          ),
        ],
      ),

      // Role-specific dashboard routes
      GoRoute(
        path: '/customer-dashboard',
        name: 'customer-dashboard',
        builder: (context, state) => const MainNavigationScreen(child: ShopListScreen()),
      ),
      GoRoute(
        path: '/shop-owner-dashboard',
        name: 'shop-owner-dashboard',
        builder: (context, state) => const MainNavigationScreen(child: ShopListScreen()),
      ),
      GoRoute(
        path: '/rider-dashboard',
        name: 'rider-dashboard',
        builder: (context, state) => const RiderDashboardScreen(),
      ),

      // Rider-specific routes (outside main shell)
      GoRoute(
        path: '/delivery',
        name: 'delivery-dashboard',
        builder: (context, state) => const RiderDashboardScreen(),
        routes: [
          GoRoute(
            path: 'tracking/:deliveryId',
            name: 'delivery-tracking-rider',
            builder: (context, state) {
              final deliveryId = state.pathParameters['deliveryId']!;
              return DeliveryTrackingScreen(
                deliveryId: deliveryId,
              );
            },
          ),
        ],
      ),

      // Profile route
      GoRoute(
        path: '/customer-profile',
        name: 'customer-profile',
        builder: (context, state) => const ProfileScreen(),
      ),

      // Support Chat (can be accessed from anywhere)
      GoRoute(
        path: '/support',
        name: 'support-chat',
        builder: (context, state) {
          return const SupportChatScreen();
        },
      ),

      // Promos
      GoRoute(
        path: '/promos',
        name: 'promos',
        builder: (context, state) => const PromoScreen(),
      ),

      // Error Screen
      GoRoute(
        path: '/error',
        name: 'error',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return ErrorScreen(
            errorMessage: extra?['message'] ?? 'An error occurred',
            canRetry: extra?['canRetry'] ?? true,
          );
        },
      ),
    ],
    errorBuilder: (context, state) => ErrorScreen(
      errorMessage: 'Page not found: ${state.matchedLocation}',
      canRetry: false,
    ),
  );

  // Navigation helper methods
  static void goToLogin() {
    _router.goNamed('login');
  }

  static void goToRegister() {
    _router.goNamed('register');
  }

  static void goToHome() {
    _router.goNamed('home');
  }

  static void goToShopDetail(String shopId) {
    _router.goNamed('shop-detail', pathParameters: {'shopId': shopId});
  }

  static void goToCart() {
    _router.goNamed('cart');
  }

  static void goToPayment() {
    _router.goNamed('payment');
  }

  static void goToOrderConfirmation(String orderId) {
    _router.goNamed('order-confirmation', pathParameters: {'orderId': orderId});
  }

  static void goToOrders() {
    _router.goNamed('orders');
  }

  static void goToOrderDetail(String orderId) {
    _router.goNamed('order-detail', pathParameters: {'orderId': orderId});
  }

  static void goToOrderTracking(String orderId) {
    _router.goNamed('order-tracking', pathParameters: {'orderId': orderId});
  }

  static void goToProfile() {
    _router.goNamed('profile');
  }

  static void goToNotifications() {
    _router.goNamed('notifications');
  }

  static void goToSupport({String? orderId, String chatType = 'general'}) {
    _router.goNamed('support-chat', extra: {
      'orderId': orderId,
      'chatType': chatType,
    });
  }

  static void goToRating({
    required String orderId,
    required String ratingType,
    String? targetId,
  }) {
    _router.goNamed('order-rating',
      pathParameters: {'orderId': orderId},
      extra: {
        'ratingType': ratingType,
        'targetId': targetId,
      },
    );
  }

  static void goToDeliveryDashboard() {
    _router.goNamed('delivery-dashboard');
  }

  static void goToDeliveryTracking(String deliveryId, {bool isRiderView = false}) {
    if (isRiderView) {
      _router.goNamed('delivery-tracking-rider',
        pathParameters: {'deliveryId': deliveryId});
    } else {
      _router.goNamed('order-tracking',
        pathParameters: {'orderId': deliveryId});
    }
  }

  static void goToPromos() {
    _router.goNamed('promos');
  }

  static void goToError({required String message, bool canRetry = true}) {
    _router.goNamed('error', extra: {
      'message': message,
      'canRetry': canRetry,
    });
  }

  // Back navigation
  static void goBack() {
    if (_router.canPop()) {
      _router.pop();
    }
  }

  // Replace current route
  static void goReplace(String location) {
    _router.go(location);
  }

  // Push named route
  static void pushNamed(String name, {
    Map<String, String> pathParameters = const {},
    Map<String, dynamic> queryParameters = const {},
    Object? extra,
  }) {
    _router.pushNamed(
      name,
      pathParameters: pathParameters,
      queryParameters: queryParameters,
      extra: extra,
    );
  }

  // Get current location (simplified for GoRouter API)
  static String get currentLocation => _router.routerDelegate.currentConfiguration.uri.toString();

  // Check if we can go back
  static bool get canPop => _router.canPop();

  // Clear navigation stack and go to route
  static void goAndClearStack(String location) {
    while (_router.canPop()) {
      _router.pop();
    }
    _router.go(location);
  }

  // Helper method to parse review type from string
  static ReviewType _parseReviewType(String type) {
    switch (type) {
      case 'userToShop':
        return ReviewType.userToShop;
      case 'userToRider':
        return ReviewType.userToRider;
      case 'shopToUser':
        return ReviewType.shopToUser;
      case 'riderToUser':
        return ReviewType.riderToUser;
      default:
        return ReviewType.userToShop;
    }
  }
}
