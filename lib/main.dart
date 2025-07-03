import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'providers/monitoring_provider.dart';
import 'services/firestore_service.dart';
import 'screens/splash_screen.dart';
import 'screens/bottom_nav_screen.dart';
import 'screens/monitoring_screen.dart';
import 'screens/statistik_screen.dart';
import 'screens/notifikasi_screen.dart';
import 'screens/rekomendasi_screen.dart';
import 'theme/colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Initialize locale data for Indonesian
  await initializeDateFormatting('id_ID', null);

  // Set preferred device orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const EleconApp());
}

class EleconApp extends StatelessWidget {
  const EleconApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MonitoringProvider()),
        Provider(create: (_) => FirestoreService()),
        Provider(create: (_) => DataModeManager()),
      ],
      child: MaterialApp(
        title: 'ELECON - Sistem Monitoring Listrik Kampus',
        debugShowCheckedModeBanner: false,

        // Add locale support
        locale: const Locale('id', 'ID'),
        supportedLocales: const [
          Locale('id', 'ID'),
          Locale('en', 'US'),
        ],
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],

        theme: _buildAppTheme(),
        home: const SplashScreen(),
        routes: _buildRoutes(),
        onGenerateRoute: (settings) => _generateRoute(settings),
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: const TextScaler.linear(1.0), // Prevent text scaling
            ),
            child: child!,
          );
        },
      ),
    );
  }

  /// Build application theme
  ThemeData _buildAppTheme() {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Roboto',

      // Color scheme
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.bluePrimary,
        brightness: Brightness.light,
        primary: AppColors.bluePrimary,
        secondary: AppColors.blueLight,
        surface: AppColors.lightBackground,
        background: AppColors.lightBackground,
        error: AppColors.error,
      ),

      // Scaffold theme
      scaffoldBackgroundColor: AppColors.lightBackground,

      // AppBar theme
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          fontFamily: 'Roboto',
        ),
        iconTheme: IconThemeData(
          color: AppColors.textPrimary,
          size: 24,
        ),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
      ),

      // Card theme
      cardTheme: CardTheme(
        color: AppColors.cardBackground,
        elevation: 2,
        shadowColor: AppColors.shadow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),

      // Button themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.bluePrimary,
          foregroundColor: Colors.white,
          elevation: 2,
          shadowColor: AppColors.shadow,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Text themes
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 32,
          fontWeight: FontWeight.w700,
        ),
        displayMedium: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 28,
          fontWeight: FontWeight.w600,
        ),
        displaySmall: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 24,
          fontWeight: FontWeight.w600,
        ),
        headlineLarge: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 22,
          fontWeight: FontWeight.w600,
        ),
        headlineMedium: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        headlineSmall: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        titleSmall: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
        bodyMedium: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        bodySmall: TextStyle(
          color: AppColors.textLight,
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
      ),

      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.cardBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.bluePrimary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        contentPadding: const EdgeInsets.all(16),
      ),

      // Divider theme
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: 1,
      ),

      // Bottom navigation bar theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.bluePrimary,
        unselectedItemColor: AppColors.textLight,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
      ),

      // Icon theme
      iconTheme: const IconThemeData(
        color: AppColors.textPrimary,
        size: 24,
      ),

      // Floating action button theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.bluePrimary,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
    );
  }

  /// Build application routes
  Map<String, WidgetBuilder> _buildRoutes() {
    return {
      '/home': (context) => const BottomNavScreen(),
      '/monitoring': (context) => const MonitoringScreen(),
      '/statistik': (context) => const StatistikScreen(),
      '/notifikasi': (context) => const NotifikasiScreen(),
      '/rekomendasi': (context) => const RekomendasiScreen(),
    };
  }

  /// Generate routes for dynamic routing
  Route<dynamic>? _generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/splash':
        return _createRoute(const SplashScreen());
      case '/home':
        return _createRoute(const BottomNavScreen());
      case '/monitoring':
        return _createRoute(const MonitoringScreen());
      case '/statistik':
        return _createRoute(const StatistikScreen());
      case '/notifikasi':
        return _createRoute(const NotifikasiScreen());
      case '/rekomendasi':
        return _createRoute(const RekomendasiScreen());
      default:
        return _createRoute(
          Scaffold(
            appBar: AppBar(title: const Text('Halaman Tidak Ditemukan')),
            body: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppColors.error,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Halaman tidak ditemukan',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Silakan kembali ke halaman sebelumnya',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
    }
  }

  /// Create custom page route with animation
  PageRouteBuilder _createRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
      reverseTransitionDuration: const Duration(milliseconds: 300),
    );
  }
}

class DataModeManager {
  bool isOnline = false;

  Future<void> checkConnectivity() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    isOnline = connectivityResult != ConnectivityResult.none;
  }
}
