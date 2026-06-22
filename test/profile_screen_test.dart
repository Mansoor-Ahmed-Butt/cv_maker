import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_with_hive/view/home_page/my_profile_screens/my_profile_screen.dart';
import 'package:flutter_with_hive/view/home_page/my_profile_screens/profile_controller.dart';
import 'package:flutter_with_hive/view/home_page/my_profile_screens/profile_model.dart';
import 'package:hive/hive.dart';
import 'package:get/get.dart';

void main() {
  setUpAll(() async {
    // Initialize Hive with a temporary directory
    final tempDir = Directory.systemTemp.createTempSync();
    Hive.init(tempDir.path);
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(ProfileModelAdapter());
    }
    await Hive.openBox<ProfileModel>('profileBox');
  });

  tearDownAll(() async {
    await Hive.close();
  });

  tearDown(() {
    Get.reset();
  });

  testWidgets('Test ProfileScreen build', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (context, child) => const ProfileScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(ProfileScreen), findsOneWidget);
  });
}
