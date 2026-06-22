import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter_with_hive/core/app_router.dart';
import 'package:flutter_with_hive/core/themes.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_with_hive/view/home_page/my_profile_screens/profile_model.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

const String _stripePublishableKey = String.fromEnvironment('STRIPE_PUBLISHABLE_KEY', defaultValue: '');

Future<void> main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  debugInvertOversizedImages = true;

  // Keep native splash until app is ready.
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // Initialize services
  await _initializeServices();

  // Apply Stripe publishable key if provided via --dart-define
  if (_stripePublishableKey.isNotEmpty) {
    Stripe.publishableKey = _stripePublishableKey;
  }

  runApp(GlobalLoaderOverlay(child: MyApp()));

  // Initialize AdMob after the Flutter engine is running so the plugin is registered.
  // Calling plugin methods before an attached engine can cause MissingPluginException.
  // Skip on web as MobileAds is not supported on web platform
  if (!kIsWeb) {
    MobileAds.instance.initialize();
  }

  // Remove splash after first frame so UI has drawn
  WidgetsBinding.instance.addPostFrameCallback((_) {
    FlutterNativeSplash.remove();
  });
}

Future<void> _initializeServices() async {
  // Initialize Hive storage
  if (kIsWeb) {
    // On web, Hive uses IndexedDB automatically - no path needed
    Hive.init('hive_db');
  } else {
    // On mobile/desktop, use the documents directory
    final directory = await getApplicationDocumentsDirectory();
    Hive.init(directory.path);
  }

  // Register Hive adapters
  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(ProfileModelAdapter());
  }

  // Pre-open the profile box so it's ready before the profile tab is tapped
  await Hive.openBox<ProfileModel>('profileBox');

  // Add other async inits here (analytics, remote config, etc.)
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final ColorScheme appColors = ColorScheme.fromSeed(seedColor: AppColors.primaryColor);

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp.router(
          //showPerformanceOverlay: true,
          routerDelegate: RouteConfig.routes.routerDelegate,
          routeInformationParser: RouteConfig.routes.routeInformationParser,
          routeInformationProvider: RouteConfig.routes.routeInformationProvider,
          title: "Hive with Flutter",
          theme: ThemeData(
            brightness: Brightness.light,
            primaryColor: Colors.green,
            colorScheme: appColors,
            highlightColor: const Color(0xffFC9D74),
            textSelectionTheme: TextSelectionThemeData(selectionColor: AppColors.bodyText.withValues(alpha: 0.4), cursorColor: AppColors.primaryColor, selectionHandleColor: AppColors.primaryColor),
          ),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
