import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:go_router/go_router.dart';
import 'firebase_options.dart';
import 'core/navigation/router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/cart/providers/cart_provider.dart';
import 'features/checkout/providers/checkout_provider.dart';
import 'features/delivery/providers/delivery_provider.dart';
import 'features/notifications/providers/notification_provider.dart';
import 'features/orders/providers/order_provider.dart';
import 'features/profile/provider/user_provider.dart';
import 'features/promos/providers/promo_provider.dart';
import 'features/rating/providers/rating_provider.dart';
import 'features/shop/providers/shop_provider.dart';
import 'features/support/providers/support_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        // Add other providers here as needed
      ],
      child: AdaptiveTheme(
        light: AppTheme.lightTheme,
        dark: AppTheme.darkTheme,
        initial: AdaptiveThemeMode.light,
        builder: (theme, darkTheme) => MaterialApp.router(
          routerConfig: AppRouter.router,
          debugShowCheckedModeBanner: false,
          theme: theme,
          darkTheme: darkTheme,
        ),
      ),
    );
  }
}
