import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'core/providers/providers.dart';
import 'features/auth/screens/screens.dart';
import 'features/kyc/screens/screens.dart';
import 'features/home/screens/screens.dart';
import 'features/transfer/screens/screens.dart';

void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize date formatting for Indonesian locale
  await initializeDateFormatting('id_ID', null);

  // Set default locale to Indonesian
  Intl.defaultLocale = 'id_ID';

  runApp(const BeeApp());
}

class BeeApp extends StatelessWidget {
  const BeeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // User state (auth, balance, PIN)
        ChangeNotifierProvider(create: (_) => UserProvider()..initialize()),
        // Contacts for transfer
        ChangeNotifierProvider(create: (_) => ContactProvider()..initialize()),
        // Transaction history
        ChangeNotifierProvider(
          create: (_) => TransactionProvider()..initialize(),
        ),
      ],
      child: MaterialApp(
        title: 'Bee - Smart Finance',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        // Start with Splash Screen
        initialRoute: '/',
        onGenerateRoute: _onGenerateRoute,
      ),
    );
  }

  /// Route generator untuk semua screens
  Route<dynamic>? _onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const SplashScreen());

      case '/welcome':
        return MaterialPageRoute(builder: (_) => const WelcomeScreen());

      case '/register':
        return MaterialPageRoute(builder: (_) => const RegistrationScreen());

      case '/setup-pin':
        return MaterialPageRoute(builder: (_) => const SetupPinScreen());

      case '/confirm-pin':
        return MaterialPageRoute(
          builder: (_) => const ConfirmPinScreen(),
          settings: settings, // Pass arguments
        );

      case '/pin-login':
        return MaterialPageRoute(builder: (_) => const PinLoginScreen());

      case '/kyc-selfie':
        return MaterialPageRoute(builder: (_) => const KycSelfieScreen());

      case '/kyc-success':
        return MaterialPageRoute(builder: (_) => const KycSuccessScreen());

      case '/home':
        return MaterialPageRoute(builder: (_) => const HomeScreen());

      case '/transfer-contacts':
        return MaterialPageRoute(
          builder: (_) => const TransferContactListScreen(),
        );

      case '/transfer-amount':
        return MaterialPageRoute(
          builder: (_) => const TransferAmountScreen(),
          settings: settings,
        );

      case '/transfer-confirmation':
        return MaterialPageRoute(
          builder: (_) => const TransferConfirmationScreen(),
          settings: settings,
        );

      case '/transaction-success':
        return MaterialPageRoute(
          builder: (_) => const TransactionSuccessScreen(),
          settings: settings,
        );

      case '/transaction-detail':
        return MaterialPageRoute(
          builder: (_) => const TransactionDetailScreen(),
          settings: settings,
        );

      case '/top-up':
        return MaterialPageRoute(builder: (_) => const TopUpScreen());

      case '/qris':
        return MaterialPageRoute(builder: (_) => const QrisScreen());

      default:
        // 404 screen
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('Not Found')),
            body: const Center(child: Text('Screen tidak ditemukan')),
          ),
        );
    }
  }
}
