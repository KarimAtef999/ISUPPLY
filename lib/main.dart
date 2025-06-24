import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'features/tracking/screens/splash_screen.dart';
import 'features/tracking/screens/notifications_screen.dart';
import 'features/tracking/provider/order_status_provider.dart';
import 'features/tracking/provider/notification_provider.dart';
import 'core/services/notification_service.dart';
import 'firebase_options.dart';

// Global navigator key to access context in background
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await NotificationService.init((title, body) {
    final context = navigatorKey.currentContext;
    if (context != null) {
      context.read<NotificationProvider>().addNotification(title, body);
    }
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => OrderStatusProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'iSupply',
        navigatorKey: navigatorKey, // Needed for accessing context globally
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: const Color(0xFF1452A5),
        ),
        home: const SplashScreen(),
        routes: {
          '/notifications': (_) => const NotificationsScreen(),
        },
      ),
    );
  }
}
