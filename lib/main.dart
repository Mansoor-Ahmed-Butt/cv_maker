import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter_with_hive/core/app_router.dart';
import 'package:flutter_with_hive/core/themes.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_with_hive/view/home_page/my_profile_screens/profile_model.dart';
import 'package:flutter_with_hive/view/resume_workflow/resume_ai_service.dart';
import 'package:flutter_with_hive/view/resume_workflow/resume_pdf_service.dart';
import 'package:flutter_with_hive/view/resume_workflow/resume_workspace_controller.dart';
import 'package:get/get.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

const String _stripePublishableKey =
    String.fromEnvironment('STRIPE_PUBLISHABLE_KEY', defaultValue: '');

Future<void> main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  debugInvertOversizedImages = true;

  // Load .env file for API keys with error handling
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    print('Warning: Failed to load .env file: $e');
    // App will continue without .env, but AI features may not work
  }

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
  await dotenv.load(fileName: ".env");
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

  // Pre-open the resume drafts box so the controller can load persisted drafts on init
  await Hive.openBox<String>('resume_drafts_v1');

  // Add other async inits here (analytics, remote config, etc.)
  Get.put<ResumeAiService>(ResumeAiService(), permanent: true);
  Get.put<ResumePdfService>(ResumePdfService(), permanent: true);
  Get.put<ResumeWorkspaceController>(
    ResumeWorkspaceController(
      aiService: Get.find<ResumeAiService>(),
      pdfService: Get.find<ResumePdfService>(),
    ),
    permanent: true,
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp.router(
          routerDelegate: RouteConfig.routes.routerDelegate,
          routeInformationParser: RouteConfig.routes.routeInformationParser,
          routeInformationProvider: RouteConfig.routes.routeInformationProvider,
          title: 'CV Maker',
          theme: AppTheme.lightTheme,
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
